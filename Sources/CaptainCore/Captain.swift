import Foundation
import PathKit
import Files

public final class Captain {
    private let arguments: [String]
    private let path: Path

    var configPath: Path {
        return path + "Captain.config.json"
    }

    var hookDirPath: Path {
        return path + ".git/hooks"
    }

    struct Config: Codable {
        var precommit: String
    }

    public init(arguments: [String] = CommandLine.arguments, rootDir: String = Path.current.string) {
        self.arguments = arguments

        // TODO: move to other method
        if let firstArgument = arguments.dropFirst().first, firstArgument == "install" {
            // install Captain.config.jsonと.gitはカレントディレクトリにあるとする

            // configファイルを読む
            self.path = Path(rootDir)
            print(rootDir)

            if configPath.exists {
                // FIXME: try!
                let data = try! configPath.read()
                let config = try! JSONDecoder().decode(Config.self, from: data)
                print(config)

                // hookを設定する
                if hookDirPath.exists {
                    let folder = try! Folder(path: hookDirPath.string)
                    let precommitHookFile = try! folder.createFileIfNeeded(withName: "precommit")
                    // ファイルに書き込む
                    try! precommitHookFile.write(string: """
                        ## Captain start
                        \(config.precommit)
                        ## Captain end
                    """)
                }
            }
        } else {
            self.path = Path()
        }
    }

    public func run() throws {
        print("Hello")
    }
}
