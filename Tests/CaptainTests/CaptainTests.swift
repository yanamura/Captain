import Foundation
import XCTest
@testable import CaptainCore
import Tempry
import Files

// MARK: - Helper Extensions for Test
extension Captain {
    func extractHookScript(type: HookType, hookFile: File) throws -> [String] {
        let hookFileDataString = try hookFile.readAsString()
        return try NSRegularExpression(pattern: "## Captain start\n(.+)\n## Captain end", options: .dotMatchesLineSeparators).extractMatches(text: hookFileDataString)
    }
}

extension NSRegularExpression {
    func extractMatches(text: String) -> [String] {
        let results = matches(in: text, range: NSRange(text.startIndex..., in: text))
        print(results)
        return results.map {
            return (text as NSString).substring(with: $0.range(at: 1))
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

        configFile = try! currentDir.createFile(named: "Captain.config.json")

        let gitFolder = try! currentDir.createSubfolder(named: ".git")
        hooksFolder = try! gitFolder.createSubfolder(named: "hooks")
    }

    override func tearDown() {
        try! currentDir.delete()
    }

    func test_install_precommit_withStringScript() {
        try! configFile.write(string: "{\"precommit\": \"echo Hello\"}")

        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "precommit"))
        let hookFile = try! hooksFolder.file(named: "precommit")
        let extractStrings = try! captain.extractHookScript(type: .precommit, hookFile: hookFile)
        XCTAssertEqual(extractStrings[0], "echo Hello")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: hookFile.path))
    }

    func test_install_precommit_withArrayScript() {
        try! configFile.write(string: "{\"precommit\": [\"echo Hello\",\"echo World\"]}")

        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "precommit"))
        let hookFile = try! hooksFolder.file(named: "precommit")
        let extractStrings = try! captain.extractHookScript(type: .precommit, hookFile: hookFile)
        XCTAssertEqual(extractStrings[0], "echo Hello\necho World")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: hookFile.path))
    }

    func test_override_install() {
        let hookFile = try! hooksFolder.createFile(named: "precommit")
        try! hookFile.write(string: """
        ## Captain start
        Hello World
        ## Captain end
        """)

        try! configFile.write(string: "{\"precommit\": \"echo Hello\"}")
        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "precommit"))
        let extractStrings = try! captain.extractHookScript(type: .precommit, hookFile: hookFile)
        XCTAssertEqual(extractStrings[0], "echo Hello")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: hookFile.path))
    }
}
