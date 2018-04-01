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
n
    public init(arguments: [String] = CommandLine.arguments, rootDir: String = Path.current.string) {
        self.arguments = arguments

        // TODO: move to other method
        if let firstArgument = arguments.dropFirst().first, firstArgument == "install" {
            // install Captain.config.jsonと.gitはカレントディレクトリにあるとする

            // configファイルを読む
            self.path = Path(rootDir)

            if configPath.exists {
                // FIXME: try!
                let data = try! configPath.read()
                let config = try! JSONDecoder().decode(Config.self, from: data)
                print(config)

                // hookを設定する
                if hookDirPath.exists {
                    let precommitHook = hookDirPath + "precommit"
                    if (!precommitHook.exists) {
                        // create precommit
                        //let folder =
                    }
                    // ファイルに書き込む
                }
            }
        } else {
            self.path = Path()
        }

        // TODO:
        // "install"の場合
        // configファイルを読む（実行位置直下のみサポート）
        // hookを設定(とりあえずprecommit)
        // hookはCaptain precommitを呼ぶだけ（とりあえず）
        //
        // "precommit"の場合
        // configのprecommitに書かれたコマンドを実行
        //
        // configファイルの仕様
        // とりあえずjsonのみ captain.config.json
        // hooktype : command
        // hooktype : [command, command]
    }

    public func run() throws {
        print("Hello")
    }
}
