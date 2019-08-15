import CaptainCore

let main = Captain()

do {
    try main.run()
} catch {
    if let error = error as? Captain.CaptainError {
        print("Error::\(error.description)")
    }
}
