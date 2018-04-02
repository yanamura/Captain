import Foundation
import XCTest
import CaptainCore
import Tempry
import Files

class CaptainTests: XCTestCase {
    override func setUp() {
    }

    override func tearDown() {
    }

    func test() {
        // SETUP
        let pathString = try! Tempry.directory()
        // create Captain.config.json
        let folder = try! Folder(path: pathString)
        let configFile = try! folder.createFile(named: "Captain.config.json")
        try! configFile.write(string: "{\"precommit\": \"echo Hello\"}")

        // create .git/hooks dir
        let gitFolder = try! folder.createSubfolder(named: ".git")
        let hooksFolder = try! gitFolder.createSubfolder(named: "hooks")

        // EXECUTE
        let captain = Captain(arguments: ["", "install"], rootDir: pathString)

        // VERIFY
        XCTAssertTrue(hooksFolder.containsFile(named: "precommit"))

        let hookFile = try! hooksFolder.file(named: "precommit")
        let hookFileString = try! hookFile.readAsString()
        XCTAssertEqual(hookFileString, """
            ## Captain start
            echo Hello
            ## Captain end
        """)
    }
}
