import Foundation
import PathKit
import Files

public final class Captain {
    public enum Error: Swift.Error, CustomStringConvertible {
        case configNotFound
        case invalidConfigData
        case hookDirNotFound
        case createHookFileFailed
        case updateHookFileFailed

        public var description: String {
            switch self {
            case .configNotFound:
                return "config file not founc"
            case .invalidConfigData:
                return "config file data is invalid"
            case .hookDirNotFound:
                return "git hook directory not founc"
            case .createHookFileFailed:
                return "create hook file failed"
            case .updateHookFileFailed:
                return "update hook file failed"
            }
        }
    }

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
                // configファイルを読む
                let configData: Data
                do {
                    configData = try configPath.read()
                } catch {
                    throw Error.configNotFound
                }
                let config: Config
                do {
                    config = try JSONDecoder().decode(Config.self, from: configData)
                } catch {
                    throw Error.invalidConfigData
                }

                // hookを設定する
                if hookDirPath.exists {
                    let folder: Folder
                    do {
                        folder = try Folder(path: hookDirPath.string)
                    } catch {
                        throw Error.hookDirNotFound
                    }
                    // TODO: precommit以外
                    let precommitHookFile: File
                    do {
                       precommitHookFile = try folder.createFileIfNeeded(withName: "precommit")
                    } catch {
                        throw Error.createHookFileFailed
                    }

                    // TODO: 既にprecommitがあったら消す

                    // ファイルに書き込む
                    do {
                        try precommitHookFile.append(string: """
                        ## Captain start
                        \(config.precommit)
                        ## Captain end
                        """)
                    } catch {
                        throw Error.updateHookFileFailed
                    }
                }
            } else {
                assert(false)
            }
        case .uninstall:
            break
        }
    }
}
