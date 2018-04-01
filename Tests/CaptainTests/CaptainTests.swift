import Foundation
import XCTest
import CaptainCore
import Tempry
import Files

class CaptainTests: XCTestCase {
    func test() {
        let pathString = try! Tempry.directory()
        // create Captain.config.json
        let folder = try! Folder(path: pathString)
        let configFile = try! folder.createFile(named: "Captain.config.json")
        try! configFile.write(string: "{\"precommit\": \"echo Hello\"}")

        // create .git/hooks dir
        let gitFolder = try! folder.createSubfolder(named: ".git")
        let hooksFolder = try! gitFolder.createSubfolder(named: "hooks")

        let captain = Captain(arguments: ["", "install"], rootDir: pathString)
    }
}
