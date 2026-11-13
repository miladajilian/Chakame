//
//  VerseLine.swift
//  Chakame
//

import Foundation

/// One row of a poem in the wide layout: a couplet's two hemistichs side by side,
/// or a line that stands alone (centered verses, paragraphs, unpaired hemistichs).
enum VerseLine: Identifiable {
    /// Ganjoor `versePosition` values for the two halves of a couplet.
    static let rightPosition = 0
    static let leftPosition = 1

    case couplet(right: VerseEntity, left: VerseEntity)
    case single(VerseEntity)

    var id: Int {
        switch self {
        case let .couplet(right, _): right.id
        case let .single(verse): verse.id
        }
    }

    /// Pairs each right hemistich with the left one that directly follows it. Keeps the order.
    static func lines(from verses: [VerseEntity]) -> [VerseLine] {
        var lines: [VerseLine] = []
        var index = verses.startIndex
        while index < verses.endIndex {
            let verse = verses[index]
            let next = index + 1
            if verse.versePosition == rightPosition, next < verses.endIndex,
               verses[next].versePosition == leftPosition {
                lines.append(.couplet(right: verse, left: verses[next]))
                index += 2
            } else {
                lines.append(.single(verse))
                index += 1
            }
        }
        return lines
    }
}
