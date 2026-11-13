//
//  VerseLineTests.swift
//  ChakameTests
//

@testable import Chakame
import Testing

@MainActor
struct VerseLineTests {
    @Test func emptyInputGivesNoLines() {
        #expect(VerseLine.lines(from: []).isEmpty)
    }

    @Test func rightThenLeftHemistichBecomeOneCouplet() {
        let lines = VerseLine.lines(from: verses([0, 1, 0, 1]))

        #expect(shapes(lines) == ["couplet 1+2", "couplet 3+4"])
    }

    @Test func unpairedHemistichsStandAlone() {
        // A right hemistich without its left half, then a left one without a right half.
        let lines = VerseLine.lines(from: verses([0, 0, 1, 1]))

        #expect(shapes(lines) == ["single 1", "couplet 2+3", "single 4"])
    }

    @Test func centeredVersesAndParagraphsStandAlone() {
        let lines = VerseLine.lines(from: verses([2, 3, -1, 4]))

        #expect(shapes(lines) == ["single 1", "single 2", "single 3", "single 4"])
    }

    @Test func orderIsKeptAcrossMixedPositions() {
        let lines = VerseLine.lines(from: verses([0, 1, 2, 3, 0, 1]))

        #expect(shapes(lines) == ["couplet 1+2", "single 3", "single 4", "couplet 5+6"])
        #expect(lines.map(\.id) == [1, 3, 4, 5])
    }

    /// Verses with ids 1, 2, 3… in the given positions.
    private func verses(_ positions: [Int]) -> [VerseEntity] {
        positions.enumerated().map { offset, position in
            let verse = VerseEntity(id: offset + 1)
            verse.vOrder = offset + 1
            verse.versePosition = position
            return verse
        }
    }

    private func shapes(_ lines: [VerseLine]) -> [String] {
        lines.map { line in
            switch line {
            case let .couplet(right, left): "couplet \(right.id)+\(left.id)"
            case let .single(verse): "single \(verse.id)"
            }
        }
    }
}
