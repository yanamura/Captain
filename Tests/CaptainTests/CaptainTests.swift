import Foundation
import XCTest
@testable import CaptainCore
import Tempry
import Files

class CaptainTests: XCTestCase {
    var currentDir: Folder!
    var configFile: File!
    var hooksFolder: Folder!

    override func setUp() {
        // create temp directory
        let pathString = try! Tempry.directory()
        currentDir = try! Folder(path: pathString)

        // create Captain.config.json
        configFile = try! currentDir.createFile(named: "Captain.config.json")

        // create .git/hooks dir
        let gitFolder = try! currentDir.createSubfolder(named: ".git")
        hooksFolder = try! gitFolder.createSubfolder(named: "hooks")
    }

    override func tearDown() {
        try! currentDir.delete()
    }

    func test_install_precommit() {
        try! configFile.write(string: "{\"precommit\": \"echo Hello\"}")

        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "precommit"))
        let extractStrings = try! captain.extractHookScript(type: .precommit)
        XCTAssertEqual(extractStrings[0], "echo Hello")
        let hookFile = try! hooksFolder.file(named: "precommit")
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
        let extractStrings = try! captain.extractHookScript(type: .precommit)
        XCTAssertEqual(extractStrings[0], "echo Hello")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: hookFile.path))
    }
}
