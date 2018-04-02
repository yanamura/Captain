import Foundation
import PathKit
import Files

public final class Captain {
    private enum CommandType {
        case install
        case uninstall
    }

    private let arguments: [String]
    private let path: Path
    private let commandType: CommandType

    var configPath: Path {
        return path + "Captain.config.json"
    }

    var hookDirPath: Path {
        return path + ".git/hooks"
    }

    struct Config: Codable {
        var precommit: String // TODO: suport array
    }

    public init(arguments: [String] = CommandLine.arguments, rootDir: String = Path.current.string) {
        self.arguments = arguments
        self.path = Path(rootDir)

        // TODO: move to other method
        if let firstArgument = arguments.dropFirst().first, firstArgument == "install" {
            commandType = .install
        } else {
            commandType = .uninstall
        }
    }

    public func run() throws {
        // install Captain.config.jsonと.gitはカレントディレクトリにあるとする
        switch commandType {
        case .install:
            if configPath.exists {
                // FIXME: try!
                // configファイルを読む
                let data = try! configPath.read()
                let config = try! JSONDecoder().decode(Config.self, from: data)

                // hookを設定する
                if hookDirPath.exists {
                    let folder = try! Folder(path: hookDirPath.string)
                    let precommitHookFile = try! folder.createFileIfNeeded(withName: "precommit")
                    // ファイルに書き込む
                    try! precommitHookFile.append(string: """
                        ## Captain start
                        \(config.precommit)
                        ## Captain end
                        """)
                }
            } else {
                assert(false)
            }
        case .uninstall:
            break
        }
    }
}
