import Files
import Foundation
import PathKit

let CAPTAIN_SCRIPTS_START_ID = "## Captain start"
let CAPTAIN_SCRIPTS_END_ID = "## Captain end"

public final class Captain {
    public enum CaptainError: Error, CustomStringConvertible {
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
                return "git hook directory not found"
            case .createHookFileFailed:
                return "create hook file failed"
            case .updateHookFileFailed:
                return "update hook file failed"
            }
        }
    }

    enum HookType: String, CodingKey, CaseIterable {
        case applypatchmsg = "applypatch-msg"
        case preapplypatch = "pre-applypatch"
        case postapplypatch = "post-applypatch"
        case precommit = "pre-commit"
        case preparecommitmsg = "preparecommitmsg"
        case commitmsg = "commit-msg"
        case postcommit = "post-commit"
        case prerebase = "pre-rebase"
        case postcheckout = "post-checkout"
        case postmerge = "post-merge"
        case prepush = "pre-push"
        case prereceive = "pre-receive"
        case update = "update"
        case postreceive = "post-receive"
        case postupdate = "post-update"
        case pushtocheckout = "push-to-checkout"
        case preautogc = "pre-auto-gc"
        case postrewrite = "post-rewrite"
        case sendemailvalidate = "sendemail-validate"
    }

    private enum CommandType {
        case undefined
        case install
        case uninstall
    }

    private enum HookScriptValue: Decodable {
        case string(String)
        case array([String])

        init(from decoder: Decoder) throws {
            if let value = try? decoder.singleValueContainer().decode(String.self) {
                self = .string(value)
                return
            }
            if let value = try? decoder.singleValueContainer().decode([String].self) {
                self = .array(value)
                return
            }

            throw CaptainError.jsonDecodeFailed
        }
    }

    private struct Config: Decodable {
        var applypatchmsg: HookScriptValue?
        var preapplypatch: HookScriptValue?
        var postapplypatch: HookScriptValue?
        var precommit: HookScriptValue?
        var preparecommitmsg: HookScriptValue?
        var commitmsg: HookScriptValue?
        var postcommit: HookScriptValue?
        var prerebase: HookScriptValue?
        var postcheckout: HookScriptValue?
        var postmerge: HookScriptValue?
        var prepush: HookScriptValue?
        var prereceive: HookScriptValue?
        var update: HookScriptValue?
        var postreceive: HookScriptValue?
        var postupdate: HookScriptValue?
        var pushtocheckout: HookScriptValue?
        var preautogc: HookScriptValue?
        var postrewrite: HookScriptValue?
        var sendemailvalidate: HookScriptValue?

        init(from decder: Decoder) throws {
            let container = try decder.container(keyedBy: HookType.self)
            self.applypatchmsg = try? container.decode(HookScriptValue.self, forKey: .applypatchmsg)
            self.preapplypatch = try? container.decode(HookScriptValue.self, forKey: .preapplypatch)
            self.postapplypatch = try? container.decode(
                HookScriptValue.self, forKey: .postapplypatch)
            self.precommit = try? container.decode(HookScriptValue.self, forKey: .precommit)
            self.preparecommitmsg = try? container.decode(
                HookScriptValue.self, forKey: .preparecommitmsg)
            self.commitmsg = try? container.decode(HookScriptValue.self, forKey: .commitmsg)
            self.postcommit = try? container.decode(HookScriptValue.self, forKey: .postcommit)
            self.prerebase = try? container.decode(HookScriptValue.self, forKey: .prerebase)
            self.postcheckout = try? container.decode(HookScriptValue.self, forKey: .postcheckout)
            self.postmerge = try? container.decode(HookScriptValue.self, forKey: .postmerge)
            self.prepush = try? container.decode(HookScriptValue.self, forKey: .prepush)
            self.prereceive = try? container.decode(HookScriptValue.self, forKey: .prereceive)
            self.update = try? container.decode(HookScriptValue.self, forKey: .update)
            self.postreceive = try? container.decode(HookScriptValue.self, forKey: .postreceive)
            self.postupdate = try? container.decode(HookScriptValue.self, forKey: .postupdate)
            self.pushtocheckout = try? container.decode(
                HookScriptValue.self, forKey: .pushtocheckout)
            self.preautogc = try? container.decode(HookScriptValue.self, forKey: .preautogc)
            self.postrewrite = try? container.decode(HookScriptValue.self, forKey: .postrewrite)
            self.sendemailvalidate = try? container.decode(
                HookScriptValue.self, forKey: .sendemailvalidate)
        }

        func propertyValueForName(name: String) -> String {
            let hookScriptValueToString: (HookScriptValue) -> String = {
                    (value: HookScriptValue) -> String in
                    switch value {
                    case let .string(string):
                        return string
                    case let .array(array):
                        return array.reduce("") { (joined, string) in
                            return joined + string + "\n"
                        }.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }

            switch name {
            case "applypatchmsg":
                if let applypatchmsg = applypatchmsg {
                    return hookScriptValueToString(applypatchmsg)
                }
                return ""
            case "preapplypatch":
                if let preapplypatch = preapplypatch {
                    return hookScriptValueToString(preapplypatch)
                }
                return ""
            case "postapplypatch":
                if let postapplypatch = postapplypatch {
                    return hookScriptValueToString(postapplypatch)
                }
                return ""
            case "precommit":
                if let precommit = precommit {
                    return hookScriptValueToString(precommit)
                }
                return ""
            case "preparecommitmsg":
                if let preparecommiting = preparecommitmsg {
                    return hookScriptValueToString(preparecommiting)
                }
                return ""
            case "commitmsg":
                if let commitmsg = commitmsg {
                    return hookScriptValueToString(commitmsg)
                }
                return ""
            case "postcommit":
                if let postcommit = postcommit {
                    return hookScriptValueToString(postcommit)
                }
                return ""
            case "prerebase":
                if let prerebase = prerebase {
                    return hookScriptValueToString(prerebase)
                }
                return ""
            case "postcheckout":
                if let postcheckout = postcheckout {
                    return hookScriptValueToString(postcheckout)
                }
                return ""
            case "postmerge":
                if let postmerge = postmerge {
                    return hookScriptValueToString(postmerge)
                }
                return ""
            case "prepush":
                if let prepush = prepush {
                    return hookScriptValueToString(prepush)
                }
                return ""
            case "prereceive":
                if let prereceive = prereceive {
                    return hookScriptValueToString(prereceive)
                }
                return ""
            case "update":
                if let update = update {
                    return hookScriptValueToString(update)
                }
                return ""
            case "postreceive":
                if let postreceive = postreceive {
                    return hookScriptValueToString(postreceive)
                }
                return ""
            case "postupdate":
                if let postupdate = postupdate {
                    return hookScriptValueToString(postupdate)
                }
                return ""
            case "pushtocheckout":
                if let pushtocheckout = pushtocheckout {
                    return hookScriptValueToString(pushtocheckout)
                }
                return ""
            case "preautogc":
                if let preautogc = preautogc {
                    return hookScriptValueToString(preautogc)
                }
                return ""
            case "postrewrite":
                if let postrewrite = postrewrite {
                    return hookScriptValueToString(postrewrite)
                }
                return ""
            case "sendemailvalidate":
                if let sendemailvalidate = sendemailvalidate {
                    return hookScriptValueToString(sendemailvalidate)
                }
                return ""
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
        } else if let firstArgument = arguments.dropFirst().first, firstArgument == "uninstall" {
            commandType = .uninstall
        } else {
            commandType = .undefined
        }
    }

    public func run() throws {
        switch commandType {
        case .undefined:
            break
        case .install:
            try install()
        case .uninstall:
            try uninstall()
        }
    }

    // MARK: - Private Methods
    private func install() throws {
        let config = try getConfig()

        try HookType.allCases.forEach { (type) in
            try setHook(type: type, config: config)
        }
    }

    private func uninstall() throws {
        try HookType.allCases.forEach { (type) in
            try clearHooks(type: type)
        }
    }

    private func getConfig() throws -> Config {
        if configPath.exists {
            let configData: Data
            do {
                configData = try configPath.read()
            } catch {
                throw CaptainError.configNotFound
            }

            let config: Config
            do {
                config = try JSONDecoder().decode(Config.self, from: configData)
            } catch {
                throw CaptainError.invalidConfigData
            }
            return config
        } else {
            throw CaptainError.configNotFound
        }
    }

    private func setHook(type: HookType, config: Config) throws {
        if hookDirPath.exists {
            let hookFile = try getHookFile(type: type)

            try FileManager.default.changePermission(posixPersmittion: 0o755, path: hookFile.path)

            try clearHooks(type: type)

            do {
                try hookFile.append(
                    string:
                        """
                    \(CAPTAIN_SCRIPTS_START_ID)
                    \(config.propertyValueForName(name: type.rawValue.replacingOccurrences(of: "-", with: "")))
                    \(CAPTAIN_SCRIPTS_END_ID)
                    """
                )
            } catch {
                throw CaptainError.updateHookFileFailed
            }
        } else {
            throw CaptainError.hookDirNotFound
        }
    }

    private func getHookFile(type: HookType) throws -> File {
        let folder: Folder
        do {
            folder = try Folder(path: hookDirPath.string)
        } catch {
            throw CaptainError.hookDirNotFound
        }

        let hookFile: File
        do {
            hookFile = try folder.createFileIfNeeded(withName: type.rawValue)
        } catch {
            throw CaptainError.createHookFileFailed
        }
        return hookFile
    }

    private func clearHooks(type: HookType) throws {
        let hookFile = try getHookFile(type: type)
        let hookFileDataString = try hookFile.readAsString()
        let resultString = removeMatches(
            regex: "\(CAPTAIN_SCRIPTS_START_ID)\n(.+)\n\(CAPTAIN_SCRIPTS_END_ID)",
            options: .dotMatchesLineSeparators, text: hookFileDataString)
        try hookFile.write(string: resultString)
    }

    private func removeMatches(
        regex: String, options: NSRegularExpression.Options = [], text: String
    ) -> String {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: options)
            return regex.stringByReplacingMatches(
                in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "")
        } catch {
            return text
        }
    }
}

extension FileManager {
    fileprivate func changePermission(posixPersmittion: Int, path: String) throws {
        try setAttributes(
            [FileAttributeKey.posixPermissions: NSNumber(value: posixPersmittion)],
            ofItemAtPath: path)
    }
}
