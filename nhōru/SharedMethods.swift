import Foundation

struct SharedMethods {
    
    static func debugLog(_ message: String,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line,
                         isLogEnable: Bool = false) {
#if DEBUG
        if isLogEnable {
            let fileName = (file as NSString).lastPathComponent
            print("[\(fileName):\(line)] \(function) - \(message)")
        }
#endif
    }
}
