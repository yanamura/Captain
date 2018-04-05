import Foundation
import PathKit
import Files

public final class Captain {
    public enum Error: Swift.Error, CustomStringConvertible {
        case jsonDecodeFailed
        case configNotFound
        case invalidConfigData
        case hookDirNotFound
        case createHookFileFailed
        case updateHookFileFailed

        public var description: String {
            switch self {
            case .jsonDecodeFailed:
                return "json decode failed"
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

    enum HookType: String {
        case precommit = "pre-commit"
    }

    private enum HookScriptValue: Decodable {
        case string(String)
        case array([String])

        init(from decoder: Decoder) throws {
            if let value = try? decoder.singleValueContainer().decode(String.self)  {
                self = .string(value)
                return
            }
            if let value = try? decoder.singleValueContainer().decode([String].self)  {
                self = .array(value)
                return
            }

            throw Error.jsonDecodeFailed
        }
    }

    private struct Config: Decodable {
        var precommit: HookScriptValue
        // TODO: add other hooks

        func propertyValueForName(name: String) -> String {
            switch name {
            case "precommit":
                switch precommit {
                case let .string(string):
                    return string
                case let .array(array):
                    return array.reduce("") { (joined, string) in
                        return joined + string + "\n"
                    }.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            default:
                return ""
            }
        }
    }

    // MARK: - Private Properties
    private let arguments: [String]
    private let path: Path
    private let commandType: CommandType

    private var configPath: Path {
        return path + "Captain.config.json"
    }

    private var hookDirPath: Path {
        return path + ".git/hooks"
    }

    // MARK: - Public Methods
    public init(arguments: [String] = CommandLine.arguments, rootDir: String = Path.current.string) {
        self.arguments = arguments
        self.path = Path(rootDir)

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
            try install()
        case .uninstall:
            try uninstall()
        }
    }

    // MARK: - Private Methods
    private func install() throws {
        let config = try getConfig()

        // TODO: support other type
        try setHook(type: .precommit, config: config)
    }

    private func uninstall() throws {
        // TODO: support other type
        try clearHooks(type: .precommit)
    }

    private func getConfig() throws -> Config {
        if configPath.exists {
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
            return config
        } else {
            throw Error.configNotFound
        }
    }

    private func setHook(type: HookType, config: Config) throws {
        if hookDirPath.exists {
            let hookFile = try getHookFile(type: type)

            try FileManager.default.changePermission(posixPersmittion: 0o755, path: hookFile.path)

            try clearHooks(type: type)

            do {
                try hookFile.append(string: """
                    ## Captain start
                    \(config.propertyValueForName(name: type.rawValue.replacingOccurrences(of: "-", with: "")))
                    ## Captain end
                    """)
            } catch {
                throw Error.updateHookFileFailed
            }
        } else {
            throw Error.hookDirNotFound
        }
    }

    private func getHookFile(type: HookType) throws -> File {
        let folder: Folder
        do {
            folder = try Folder(path: hookDirPath.string)
        } catch {
            throw Error.hookDirNotFound
        }

        let hookFile: File
        do {
            hookFile = try folder.createFileIfNeeded(withName: type.rawValue)
        } catch {
            throw Error.createHookFileFailed
        }
        return hookFile
    }

    private func clearHooks(type: HookType) throws {
        let hookFile = try getHookFile(type: type)
        let hookFileDataString = try hookFile.readAsString()
        let resultString = removeMatches(regex: "## Captain start\n(.+)\n## Captain end", text: hookFileDataString)
        try hookFile.write(string: resultString)
    }

    private func removeMatches(regex: String, text: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            return regex.stringByReplacingMatches(in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "")
        } catch {
            return text
        }
    }
}

private extension FileManager {
    func changePermission(posixPersmittion: Int, path: String) throws {
        try setAttributes([FileAttributeKey.posixPermissions: posixPersmittion], ofItemAtPath: path)
    }
}
