import Foundation
import XCTest
import CaptainCore
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

    func test() {
        try! configFile.write(string: "{\"precommit\": \"echo Hello\"}")

        let captain = Captain(arguments: ["", "install"], rootDir: currentDir.path)
        try! captain.run()

        XCTAssertTrue(hooksFolder.containsFile(named: "precommit"))
        let hookFile = try! hooksFolder.file(named: "precommit")
        let hookFileString = try! hookFile.readAsString()
        let expectString = """
        ## Captain start
        echo Hello
        ## Captain end
        """
        XCTAssertTrue(hookFileString.hasSuffix(expectString))
    }
}
