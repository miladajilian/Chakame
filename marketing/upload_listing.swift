#!/usr/bin/env swift
// Sends the App Store copy in marketing/AppStoreListing.md to App Store Connect (en-US only):
// name and subtitle, description, keywords, promotional text and What's New.
// It can also create the version, attach an uploaded build and submit for review (used by scripts/release.sh).
//
//   swift marketing/upload_listing.swift                  dry run: shows what would change, sends nothing
//   swift marketing/upload_listing.swift --apply          sends the changes
//
// Options:
//   --version 1.5.0     pick the version (default: the one in "Prepare for Submission")
//   --create            create the --version in App Store Connect if it doesn't exist yet
//   --build 15          wait for this uploaded build to finish processing, then attach it to the version
//   --screenshots       also upload marketing/screenshots/{iphone-6.9,ipad-13} (only sets that changed)
//   --submit            submit the version for App Review (after everything else succeeded)
//   --verbose           print the full old and new text of every changed field
//   --promo-only        send only the promotional text; it goes to the live version if none is being prepared
//                       (Apple lets that one field change on a live version, without review)
//
// Without an editable version, a dry run compares against the live version (read-only).
//
// Credentials stay out of this public repo. ASC_KEY_ID and ASC_ISSUER_ID come from the environment or
// from ~/.config/appstoreconnect.env (KEY=value lines); the key itself from
// ~/.appstoreconnect/private_keys/AuthKey_<ASC_KEY_ID>.p8 (or the path in ASC_KEY_PATH).

import CryptoKit
import Foundation

// MARK: - Configuration

/// Environment first, then ~/.config/appstoreconnect.env.
func credential(_ name: String) -> String {
    if let value = ProcessInfo.processInfo.environment[name], !value.isEmpty { return value }
    let path = NSString(string: "~/.config/appstoreconnect.env").expandingTildeInPath
    let lines = (try? String(contentsOfFile: path, encoding: .utf8))?.components(separatedBy: .newlines) ?? []
    for line in lines {
        let parts = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2, parts[0] == name { return parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }
    }
    print("Missing \(name): set it in the environment or in ~/.config/appstoreconnect.env")
    exit(1)
}

let keyID = credential("ASC_KEY_ID")
let issuerID = credential("ASC_ISSUER_ID")
let bundleID = "milad.ajilian.Chakame"

/// Listing section (the `## ` heading) → App Store locales that get its text.
let sectionLocales: [(section: String, locales: [String])] = [
    ("English (U.S.)", ["en-US"]),
]

/// States in which Apple lets you edit a version or app info.
let editableStates: Set<String> = [
    "PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY",
]

// MARK: - Listing fields

enum Field: String, CaseIterable {
    case name = "Name"
    case subtitle = "Subtitle"
    case keywords = "Keywords"
    case promotionalText = "Promotional Text"
    case description = "Description"
    case whatsNew = "What's New in This Version"

    var limit: Int {
        switch self {
        case .name, .subtitle: 30
        case .keywords: 100
        case .promotionalText: 170
        case .description, .whatsNew: 4000
        }
    }

    /// Attribute name in the App Store Connect API.
    var apiKey: String {
        switch self {
        case .name: "name"
        case .description: "description"
        case .subtitle: "subtitle"
        case .keywords: "keywords"
        case .promotionalText: "promotionalText"
        case .whatsNew: "whatsNew"
        }
    }

    /// Short fields are printed in full in the dry run; long ones only by length.
    var isShort: Bool { limit <= 100 }

    /// Optional fields may be left empty in the listing; an empty value is never sent.
    var isOptional: Bool { self == .promotionalText }
}

/// Reads every `**Field**` followed by a fenced code block, grouped by `## Section`.
func parseListing(_ text: String) -> [String: [Field: String]] {
    var result: [String: [Field: String]] = [:]
    var section: String?
    var field: Field?
    var block: [String]?

    for line in text.components(separatedBy: "\n") {
        if var lines = block {
            if line.hasPrefix("```") {
                if let section, let field {
                    result[section, default: [:]][field] = lines.joined(separator: "\n")
                }
                block = nil
                field = nil
            } else {
                lines.append(line)
                block = lines
            }
        } else if line.hasPrefix("## ") {
            section = line.dropFirst(3).trimmingCharacters(in: .whitespaces)
            field = nil
        } else if line.hasPrefix("**") {
            let label = line.dropFirst(2).components(separatedBy: "**").first ?? ""
            field = Field(rawValue: label)
        } else if line.hasPrefix("```") {
            block = []
        }
    }
    return result
}

// MARK: - App Store Connect API

struct ScriptError: Error, CustomStringConvertible {
    let description: String
}

struct Resource {
    let id: String
    let attributes: [String: Any]

    func string(_ key: String) -> String? { attributes[key] as? String }
}

extension Data {
    var base64URL: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

func loadKey() throws -> P256.Signing.PrivateKey {
    let path = ProcessInfo.processInfo.environment["ASC_KEY_PATH"]
        ?? NSString(string: "~/.appstoreconnect/private_keys/AuthKey_\(keyID).p8").expandingTildeInPath
    guard let pem = try? String(contentsOfFile: path, encoding: .utf8) else {
        throw ScriptError(description: "No API key at \(path)")
    }
    return try P256.Signing.PrivateKey(pemRepresentation: pem)
}

/// A short-lived ES256 token, as App Store Connect requires (at most 20 minutes).
func makeToken(_ key: P256.Signing.PrivateKey) throws -> String {
    let now = Int(Date().timeIntervalSince1970)
    let header = try JSONSerialization.data(withJSONObject: ["alg": "ES256", "kid": keyID, "typ": "JWT"])
    let payload = try JSONSerialization.data(withJSONObject: [
        "iss": issuerID, "iat": now, "exp": now + 10 * 60, "aud": "appstoreconnect-v1",
    ] as [String: Any])
    let signingInput = "\(header.base64URL).\(payload.base64URL)"
    let signature = try key.signature(for: Data(signingInput.utf8)).rawRepresentation
    return "\(signingInput).\(signature.base64URL)"
}

@MainActor func call(_ method: String, _ path: String, body: [String: Any]? = nil) async throws -> [String: Any] {
    var request = URLRequest(url: URL(string: "https://api.appstoreconnect.apple.com" + path)!)
    request.httpMethod = method
    request.setValue("Bearer \(try makeToken(signingKey))", forHTTPHeaderField: "Authorization")
    if let body {
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    let (data, response) = try await URLSession.shared.data(for: request)
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    guard (200..<300).contains(status) else {
        // App Review's refusals list the actual reasons under meta.associatedErrors.
        let errors = (json["errors"] as? [[String: Any]])?
            .map { error in
                let associated = ((error["meta"] as? [String: Any])?["associatedErrors"] as? [String: [[String: Any]]] ?? [:])
                    .values.flatMap { $0 }
                    .map { "\n    • \($0["detail"] ?? $0["title"] ?? "")" }
                    .joined()
                return "\(error["title"] ?? "") – \(error["detail"] ?? "")\(associated)"
            }
            .joined(separator: "; ")
        throw ScriptError(description: "\(method) \(path) failed (\(status)): \(errors ?? String(decoding: data, as: UTF8.self))")
    }
    return json
}

@MainActor func list(_ path: String) async throws -> [Resource] {
    let json = try await call("GET", path)
    return (json["data"] as? [[String: Any]] ?? []).compactMap { item in
        guard let id = item["id"] as? String else { return nil }
        return Resource(id: id, attributes: item["attributes"] as? [String: Any] ?? [:])
    }
}

// MARK: - Syncing localizations

/// One kind of localization: app info (name, subtitle) or version texts.
struct Target {
    let title: String
    let listPath: String
    let type: String
    let fields: [Field]
    let parent: (relationship: String, type: String, id: String)
}

@MainActor func sync(_ target: Target, desired: [String: [Field: String]]) async throws -> Int {
    print("\n\(target.title)")
    let existing = Dictionary(
        try await list(target.listPath).compactMap { r in r.string("locale").map { ($0, r) } },
        uniquingKeysWith: { first, _ in first }
    )
    var changeCount = 0

    for locale in desired.keys.sorted() {
        let wanted = desired[locale]!.filter { target.fields.contains($0.key) }
        let current = existing[locale]
        let changed = target.fields.filter { field in
            guard let value = wanted[field], !(value.isEmpty && field.isOptional) else { return false }
            return current?.string(field.apiKey) ?? "" != value
        }
        guard !changed.isEmpty else {
            print("  \(locale.padding(toLength: 8, withPad: " ", startingAt: 0)) unchanged")
            continue
        }
        changeCount += 1
        print("  \(locale.padding(toLength: 8, withPad: " ", startingAt: 0)) \(current == nil ? "NEW LANGUAGE" : "update")")
        for field in changed {
            let old = current?.string(field.apiKey) ?? ""
            let new = wanted[field]!
            if verbose {
                print("      \(field.rawValue):\n        old: \(old)\n        new: \(new)")
            } else if field.isShort {
                print("      \(field.rawValue): \"\(old)\" → \"\(new)\"")
            } else {
                print("      \(field.rawValue): changed (\(old.count) → \(new.count) characters)")
            }
        }
        guard apply else { continue }

        var attributes: [String: Any] = [:]
        for field in changed { attributes[field.apiKey] = wanted[field] }
        if let current {
            _ = try await call("PATCH", "/v1/\(target.type)/\(current.id)", body: [
                "data": ["type": target.type, "id": current.id, "attributes": attributes],
            ])
        } else {
            attributes["locale"] = locale
            _ = try await call("POST", "/v1/\(target.type)", body: [
                "data": [
                    "type": target.type,
                    "attributes": attributes,
                    "relationships": [
                        target.parent.relationship: ["data": ["type": target.parent.type, "id": target.parent.id]],
                    ],
                ],
            ])
        }
        print("      ✓ sent")
    }
    return changeCount
}

/// App Review requires a support URL and a privacy policy URL in every language; a language added by
/// this script has none, so it gets the English one.
@MainActor func fillLinks(_ listPath: String, type: String, attribute: String) async throws {
    let localizations = try await list(listPath)
    guard let english = localizations.first(where: { $0.string("locale") == "en-US" })?.string(attribute), !english.isEmpty else { return }
    let missing = localizations.filter { ($0.string(attribute) ?? "").isEmpty }
    guard !missing.isEmpty else { return }
    print("\n\(attribute): \(missing.count) language(s) get the English link \(english)")
    guard apply else { return }
    for localization in missing {
        _ = try await call("PATCH", "/v1/\(type)/\(localization.id)", body: [
            "data": ["type": type, "id": localization.id, "attributes": [attribute: english]],
        ])
    }
    print("  ✓ sent")
}

// MARK: - Version, build and review

func versionState(_ version: Resource) -> String {
    version.string("appVersionState") ?? version.string("appStoreState") ?? ""
}

/// The version to update. Returns nil only in a dry run where `--create` would create it.
/// A plain dry run with no editable version compares against the live one, read-only.
@MainActor func findOrCreateVersion() async throws -> Resource? {
    let versions = try await list("/v1/apps/\(appID)/appStoreVersions?filter%5Bplatform%5D=IOS&limit=20")
    let editable = versions.first { editableStates.contains(versionState($0)) }

    if let wantedVersion, let match = versions.first(where: { $0.string("versionString") == wantedVersion }) {
        return match
    }
    if wantedVersion == nil, let editable { return editable }
    if promoOnly || !apply, wantedVersion == nil,
       let live = versions.first(where: { versionState($0) == "READY_FOR_DISTRIBUTION" }) {
        if !promoOnly {
            print("No version is being prepared: comparing with live version \(live.string("versionString") ?? "?") (read-only).")
        }
        return live
    }

    let found = versions.map { "\($0.string("versionString") ?? "?") (\(versionState($0)))" }.joined(separator: ", ")
    guard createVersion, let wantedVersion else {
        throw ScriptError(description: "No matching editable version. Create it in App Store Connect or pass --version x.y.z --create. Versions: \(found)")
    }
    if let editable {
        throw ScriptError(description: "Version \(editable.string("versionString") ?? "?") is already being prepared, and App Store Connect allows only one. Use --version \(editable.string("versionString") ?? "") or delete it.")
    }
    guard apply else {
        print("Version \(wantedVersion) doesn't exist yet: would create it.")
        return nil
    }
    let json = try await call("POST", "/v1/appStoreVersions", body: [
        "data": [
            "type": "appStoreVersions",
            "attributes": ["platform": "IOS", "versionString": wantedVersion],
            "relationships": ["app": ["data": ["type": "apps", "id": appID]]],
        ],
    ])
    guard let data = json["data"] as? [String: Any], let id = data["id"] as? String else {
        throw ScriptError(description: "Creating version \(wantedVersion) returned no id")
    }
    print("Created version \(wantedVersion).")
    return Resource(id: id, attributes: data["attributes"] as? [String: Any] ?? [:])
}

/// Waits until Apple has processed the uploaded build, declares its encryption use, and attaches it.
@MainActor func attachBuild(_ number: String, to version: Resource?, versionString: String) async throws {
    print("\nBuild \(versionString) (\(number))")
    let path = "/v1/builds?filter%5Bapp%5D=\(appID)&filter%5Bversion%5D=\(number)"
        + "&filter%5BpreReleaseVersion.version%5D=\(versionString)&limit=1"
    var build = try await list(path).first
    guard apply, let version else {
        print("  \(build.map { "uploaded (\($0.string("processingState") ?? "?"))" } ?? "not uploaded yet"): would attach it to the version")
        return
    }

    let deadline = Date().addingTimeInterval(60 * 60)
    while build?.string("processingState") != "VALID" {
        let state = build?.string("processingState") ?? "not visible yet"
        if state == "FAILED" || state == "INVALID" {
            throw ScriptError(description: "Apple rejected build \(number) (\(state)). Check your email from App Store Connect.")
        }
        guard Date() < deadline else { throw ScriptError(description: "Build \(number) still not processed after an hour.") }
        print("  waiting for Apple to process it (\(state))…")
        try await Task.sleep(for: .seconds(30))
        build = try await list(path).first
    }
    let buildID = build!.id

    // The app only uses standard HTTPS (Ganjoor API, poet images), which is exempt from export compliance documents.
    if build!.attributes["usesNonExemptEncryption"] as? Bool == nil {
        _ = try await call("PATCH", "/v1/builds/\(buildID)", body: [
            "data": ["type": "builds", "id": buildID, "attributes": ["usesNonExemptEncryption": false]],
        ])
        print("  ✓ export compliance: no non-exempt encryption")
    }
    _ = try await call("PATCH", "/v1/appStoreVersions/\(version.id)/relationships/build", body: [
        "data": ["type": "builds", "id": buildID],
    ])
    print("  ✓ attached to version \(versionString)")
}

@MainActor func submitForReview(_ version: Resource?, versionString: String) async throws {
    print("\nApp Review")
    guard apply, let version else {
        print("  would submit version \(versionString) for review")
        return
    }
    let open = try await list("/v1/reviewSubmissions?filter%5Bapp%5D=\(appID)&filter%5Bplatform%5D=IOS&filter%5Bstate%5D=READY_FOR_REVIEW")
    let submissionID: String
    if let existing = open.first {
        submissionID = existing.id
    } else {
        let json = try await call("POST", "/v1/reviewSubmissions", body: [
            "data": [
                "type": "reviewSubmissions",
                "attributes": ["platform": "IOS"],
                "relationships": ["app": ["data": ["type": "apps", "id": appID]]],
            ],
        ])
        guard let id = (json["data"] as? [String: Any])?["id"] as? String else {
            throw ScriptError(description: "Creating the review submission returned no id")
        }
        submissionID = id
    }
    do {
        _ = try await call("POST", "/v1/reviewSubmissionItems", body: [
            "data": [
                "type": "reviewSubmissionItems",
                "relationships": [
                    "reviewSubmission": ["data": ["type": "reviewSubmissions", "id": submissionID]],
                    "appStoreVersion": ["data": ["type": "appStoreVersions", "id": version.id]],
                ],
            ],
        ])
    } catch {
        // A draft submission that already holds this version rejects adding it again; anything else is a real refusal.
        guard try await !list("/v1/reviewSubmissions/\(submissionID)/items").isEmpty else { throw error }
        print("  (version was already in the open submission)")
    }
    _ = try await call("PATCH", "/v1/reviewSubmissions/\(submissionID)", body: [
        "data": ["type": "reviewSubmissions", "id": submissionID, "attributes": ["submitted": true]],
    ])
    print("  ✓ submitted version \(versionString) for review")
}

// MARK: - Screenshots

/// The sizes App Store Connect requires; it scales them down for smaller devices.
let screenshotTypes = [("APP_IPHONE_67", "iphone-6.9"), ("APP_IPAD_PRO_3GEN_129", "ipad-13")]

/// Replaces each locale's screenshot set when the local PNGs differ from what's uploaded (by MD5).
@MainActor func syncScreenshots(version: Resource) async throws -> Int {
    print("\nScreenshots")
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("screenshots")
    let localizations = try await list("/v1/appStoreVersions/\(version.id)/appStoreVersionLocalizations?limit=200")
    let byLocale = Dictionary(localizations.compactMap { r in r.string("locale").map { ($0, r) } },
                              uniquingKeysWith: { first, _ in first })
    var changeCount = 0

    for locale in desired.keys.sorted() {
        guard let localization = byLocale[locale] else {
            print("  \(locale): not on the version yet (run with --apply first), skipped")
            continue
        }
        let sets = try await list("/v1/appStoreVersionLocalizations/\(localization.id)/appScreenshotSets?limit=50")
        for (displayType, device) in screenshotTypes {
            let label = "\(locale.padding(toLength: 8, withPad: " ", startingAt: 0)) \(device)"
            let directory = root.appendingPathComponent(device)
            let files = ((try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? [])
                .filter { $0.pathExtension == "png" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            guard !files.isEmpty else {
                print("  \(label): no screenshots in marketing/screenshots/\(device), skipped")
                continue
            }
            let images = try files.map { try Data(contentsOf: $0) }
            let checksums = images.map { Insecure.MD5.hash(data: $0).map { String(format: "%02x", $0) }.joined() }
            let set = sets.first { $0.string("screenshotDisplayType") == displayType }
            var existing: [Resource] = []
            if let set { existing = try await list("/v1/appScreenshotSets/\(set.id)/appScreenshots?limit=50") }
            if existing.map({ $0.string("sourceFileChecksum") ?? "" }) == checksums {
                print("  \(label) unchanged")
                continue
            }
            changeCount += 1
            print("  \(label) replace \(existing.count) with \(files.count) screenshots")
            guard apply else { continue }

            let setID: String
            if let set {
                setID = set.id
            } else {
                let json = try await call("POST", "/v1/appScreenshotSets", body: [
                    "data": [
                        "type": "appScreenshotSets",
                        "attributes": ["screenshotDisplayType": displayType],
                        "relationships": [
                            "appStoreVersionLocalization": ["data": ["type": "appStoreVersionLocalizations", "id": localization.id]],
                        ],
                    ],
                ])
                guard let id = (json["data"] as? [String: Any])?["id"] as? String else {
                    throw ScriptError(description: "Creating the \(device) screenshot set for \(locale) returned no id")
                }
                setID = id
            }
            for screenshot in existing {
                _ = try await call("DELETE", "/v1/appScreenshots/\(screenshot.id)")
            }
            for (index, file) in files.enumerated() {
                try await uploadScreenshot(images[index], name: file.lastPathComponent, checksum: checksums[index], setID: setID)
            }
            print("      ✓ uploaded")
        }

        // Older sizes (6.5", 6.3", …) would keep showing old screenshots on those devices; without them
        // App Store Connect scales the 6.9" and 13" sets down.
        let required = Set(screenshotTypes.map(\.0))
        for stale in sets {
            let type = stale.string("screenshotDisplayType") ?? ""
            guard !required.contains(type), type.hasPrefix("APP_IPHONE") || type.hasPrefix("APP_IPAD") else { continue }
            changeCount += 1
            print("  \(locale.padding(toLength: 8, withPad: " ", startingAt: 0)) remove old \(type) set")
            if apply { _ = try await call("DELETE", "/v1/appScreenshotSets/\(stale.id)") }
        }
    }
    return changeCount
}

/// Apple's three-step upload: reserve the file, PUT its bytes where told, then commit with the checksum.
@MainActor func uploadScreenshot(_ data: Data, name: String, checksum: String, setID: String) async throws {
    let json = try await call("POST", "/v1/appScreenshots", body: [
        "data": [
            "type": "appScreenshots",
            "attributes": ["fileName": name, "fileSize": data.count],
            "relationships": ["appScreenshotSet": ["data": ["type": "appScreenshotSets", "id": setID]]],
        ],
    ])
    guard let item = json["data"] as? [String: Any], let id = item["id"] as? String,
          let operations = (item["attributes"] as? [String: Any])?["uploadOperations"] as? [[String: Any]] else {
        throw ScriptError(description: "Reserving \(name) returned no upload instructions")
    }
    for operation in operations {
        guard let urlString = operation["url"] as? String, let url = URL(string: urlString) else { continue }
        var request = URLRequest(url: url)
        request.httpMethod = operation["method"] as? String ?? "PUT"
        for header in operation["requestHeaders"] as? [[String: Any]] ?? [] {
            if let field = header["name"] as? String { request.setValue(header["value"] as? String, forHTTPHeaderField: field) }
        }
        let offset = operation["offset"] as? Int ?? 0
        let length = operation["length"] as? Int ?? data.count
        let (_, response) = try await URLSession.shared.upload(for: request, from: data.subdata(in: offset..<(offset + length)))
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else { throw ScriptError(description: "Uploading \(name) failed (\(status))") }
    }
    _ = try await call("PATCH", "/v1/appScreenshots/\(id)", body: [
        "data": ["type": "appScreenshots", "id": id, "attributes": ["uploaded": true, "sourceFileChecksum": checksum]],
    ])
}

// MARK: - Main

var apply = false
var verbose = false
var createVersion = false
var submit = false
var uploadScreenshots = false
var promoOnly = false
var wantedVersion: String?
var buildNumber: String?
/// Looked up from `bundleID` before anything else is read.
var appID = ""

var arguments = CommandLine.arguments.dropFirst().makeIterator()
while let argument = arguments.next() {
    switch argument {
    case "--apply": apply = true
    case "--verbose": verbose = true
    case "--create": createVersion = true
    case "--submit": submit = true
    case "--screenshots": uploadScreenshots = true
    case "--promo-only": promoOnly = true
    case "--version": wantedVersion = arguments.next()
    case "--build": buildNumber = arguments.next()
    default:
        print("Unknown option \(argument). Options: --apply, --verbose, --promo-only, --version <x.y.z>, --create, --build <n>, --screenshots, --submit")
        exit(2)
    }
}
if createVersion && wantedVersion == nil {
    print("--create needs --version x.y.z")
    exit(2)
}
if promoOnly && (createVersion || submit || uploadScreenshots || buildNumber != nil) {
    print("--promo-only can't be combined with --create, --build, --screenshots or --submit.")
    exit(2)
}

let listingURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("AppStoreListing.md")
let sections = parseListing(try String(contentsOf: listingURL, encoding: .utf8))

// Expand sections to locales and check every field before touching anything.
var desired: [String: [Field: String]] = [:]
var problems: [String] = []
for (section, locales) in sectionLocales {
    guard let fields = sections[section] else {
        problems.append("Missing section \"## \(section)\"")
        continue
    }
    for field in Field.allCases {
        guard let value = fields[field] else {
            problems.append("\(section): missing \(field.rawValue)")
            continue
        }
        if value.isEmpty && !field.isOptional { problems.append("\(section): \(field.rawValue) is empty") }
        if value.count > field.limit {
            problems.append("\(section): \(field.rawValue) is \(value.count)/\(field.limit) characters")
        }
    }
    for locale in locales {
        desired[locale] = promoOnly ? fields.filter { $0.key == .promotionalText } : fields
    }
}
guard problems.isEmpty else {
    print("AppStoreListing.md has problems, nothing was sent:")
    problems.forEach { print("  • \($0)") }
    exit(1)
}

let signingKey: P256.Signing.PrivateKey
do {
    signingKey = try loadKey()
} catch {
    print(error)
    exit(1)
}

print(apply ? "Sending changes to App Store Connect." : "DRY RUN: nothing will be sent. Add --apply to send.")

do {
    guard let id = try await list("/v1/apps?filter%5BbundleId%5D=\(bundleID)").first?.id else {
        throw ScriptError(description: "No app with bundle ID \(bundleID) in App Store Connect")
    }
    appID = id
    let version = try await findOrCreateVersion()
    let versionString = version?.string("versionString") ?? wantedVersion ?? ""
    if let version { print("Version \(versionString) (\(versionState(version)))") }

    var changes = 0
    let appInfos = try await list("/v1/apps/\(appID)/appInfos")
    if let appInfo = appInfos.first(where: { editableStates.contains($0.string("state") ?? $0.string("appStoreState") ?? "") }) {
        changes += try await sync(Target(
            title: "App information (name, subtitle)",
            listPath: "/v1/appInfos/\(appInfo.id)/appInfoLocalizations?limit=200",
            type: "appInfoLocalizations",
            fields: [.name, .subtitle],
            parent: ("appInfo", "appInfos", appInfo.id)
        ), desired: desired)
    } else {
        print("\nApp information: no editable app info right now, so name and subtitle are skipped.")
    }

    if let version {
        changes += try await sync(Target(
            title: "Version \(versionString) (description, keywords, promotional text, What's New)",
            listPath: "/v1/appStoreVersions/\(version.id)/appStoreVersionLocalizations?limit=200",
            type: "appStoreVersionLocalizations",
            fields: [.description, .keywords, .promotionalText, .whatsNew],
            parent: ("appStoreVersion", "appStoreVersions", version.id)
        ), desired: desired)
    } else {
        print("\nVersion \(versionString): would send description, keywords, promotional text and What's New once created.")
    }

    if let appInfo = appInfos.first(where: { editableStates.contains($0.string("state") ?? $0.string("appStoreState") ?? "") }) {
        try await fillLinks("/v1/appInfos/\(appInfo.id)/appInfoLocalizations?limit=200", type: "appInfoLocalizations", attribute: "privacyPolicyUrl")
    }
    if let version {
        try await fillLinks("/v1/appStoreVersions/\(version.id)/appStoreVersionLocalizations?limit=200", type: "appStoreVersionLocalizations", attribute: "supportUrl")
    }

    if uploadScreenshots {
        if let version {
            changes += try await syncScreenshots(version: version)
        } else {
            print("\nScreenshots: would upload the screenshots once the version exists.")
        }
    }

    if let buildNumber { try await attachBuild(buildNumber, to: version, versionString: versionString) }
    if submit { try await submitForReview(version, versionString: versionString) }

    print(apply
        ? "\nDone: \(changes) change(s) sent."
        : "\n\(changes) change(s) would be sent. Run again with --apply to send them.")
} catch {
    print("\nStopped: \(error)")
    exit(1)
}
