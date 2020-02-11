import Files
import Foundation
import Tempry
import XCTest

@testable import CaptainCore

// MARK: - Helper Extensions for Test
extension Captain {
    func extractHookScript(type: HookType, hookFile: File) throws -> [String] {
        let hookFileDataString = try hookFile.readAsString()
        return try NSRegularExpression(
            pattern: "\(CAPTAIN_SCRIPTS_START_ID)\n(.+)\n\(CAPTAIN_SCRIPTS_END_ID)", options: .dotMatchesLineSeparators)
            .extractMatches(text: hookFileDataString)
    }
}

extension NSRegularExpression {
    func extractMatches(text: String) -> [String] {
        let results = matches(in: text, range: NSRange(text.startIndex..., in: text))
        return results.map {
            if let range = Range($0.range(at: 1), in: text) {
                return String(text[range.lowerBound..<range.upperBound])
            } else {
                return text
            }
        }
    }
}

// MARK: - Tests
class CaptainTests: XCTestCase {
    var currentDir: Folder!
    var configFile: File!
    var hooksFolder: Folder!

    override func setUp() {
        let pathString = try! Tempry.directory()
        currentDir = try! Folder(path: pathString)

        configFile = try! currentDir.createFile(named: ".captain")

        let gitFolder = try! currentDir.createSubfolder(named: ".git")
        hooksFolder = try! gitFolder.createSubfolder(named: "hooks")
    }

    override func tearDown() {
        try! currentDir.delete()
    }

    func test_install_precommit_withStringScript() {
        try! configFile.write(string: "{\"pre-commit\": \"echo Hello\"}")

        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "pre-commit"))
        let hookFile = try! hooksFolder.file(named: "pre-commit")
        let extractStrings = try! captain.extractHookScript(type: .precommit, hookFile: hookFile)
        XCTAssertEqual(extractStrings[0], "echo Hello")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: hookFile.path))
    }

    func test_install_precommit_withArrayScript() {
        try! configFile.write(string: "{\"pre-commit\": [\"echo Hello\",\"echo World\"]}")

        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "pre-commit"))
        let hookFile = try! hooksFolder.file(named: "pre-commit")
        let extractStrings = try! captain.extractHookScript(type: .precommit, hookFile: hookFile)
        XCTAssertEqual(extractStrings[0], "echo Hello\necho World")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: hookFile.path))
    }

    func test_override_install() {
        let hookFile = try! hooksFolder.createFile(named: "pre-commit")
        try! hookFile.write(
            string:
                """
        \(CAPTAIN_SCRIPTS_START_ID)
        Hello World
        \(CAPTAIN_SCRIPTS_END_ID)
        """
        )

        try! configFile.write(string: "{\"pre-commit\": \"echo Hello\"}")
        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "pre-commit"))
        let extractStrings = try! captain.extractHookScript(type: .precommit, hookFile: hookFile)
        XCTAssertEqual(extractStrings[0], "echo Hello")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: hookFile.path))
    }

    func test_uninstall() {
        let hookFile = try! hooksFolder.createFile(named: "pre-commit")
        try! hookFile.write(
            string:
                """
            \(CAPTAIN_SCRIPTS_START_ID)
            Hello World
            \(CAPTAIN_SCRIPTS_END_ID)
            """
        )

        let captain = Captain(arguments: ["", "uninstall"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "pre-commit"))
        let extractStrings = try! captain.extractHookScript(type: .precommit, hookFile: hookFile)
        XCTAssertEqual(extractStrings.count, 0)
    }

    static var allTests = [
        ("test_install_precommit_withStringScript", test_install_precommit_withStringScript),
        ("test_install_precommit_withArrayScript", test_install_precommit_withArrayScript),
        ("test_override_install", test_override_install),
        ("test_uninstall", test_uninstall),
    ]
}
