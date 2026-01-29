import Firebase

class LogActivities {
    
    static var shared = LogActivities()
    
    func log(using event: EventLogs) {
        let uid = UserDefaults.standard.value(forKey: "uid") ?? ""
        let uname = UserDefaults.standard.value(forKey: "uname") ?? ""
        let compiled = "\(uname) - (\(uid))"
        let params = ["uid": uid, "uname": compiled]
        Analytics.logEvent(event.rawValue, parameters: params)
    }
    
    fileprivate func mapToDevice(modelCode: String) -> String {
        let modelMap: [String: String] = [
            "iPhone1,1": "iPhone",
            "iPhone1,2": "iPhone 3G",
            "iPhone2,1": "iPhone 3GS",
            "iPhone3,1": "iPhone 4",
            "iPhone3,2": "iPhone 4",
            "iPhone3,3": "iPhone 4",
            "iPhone4,1": "iPhone 4S",
            "iPhone5,1": "iPhone 5",
            "iPhone5,2": "iPhone 5",
            "iPhone5,3": "iPhone 5c",
            "iPhone5,4": "iPhone 5c",
            "iPhone6,1": "iPhone 5s",
            "iPhone6,2": "iPhone 5s",
            "iPhone7,2": "iPhone 6",
            "iPhone7,1": "iPhone 6 Plus",
            "iPhone8,1": "iPhone 6s",
            "iPhone8,2": "iPhone 6s Plus",
            "iPhone8,4": "iPhone SE (1st generation)",
            "iPhone9,1": "iPhone 7",
            "iPhone9,3": "iPhone 7",
            "iPhone9,2": "iPhone 7 Plus",
            "iPhone9,4": "iPhone 7 Plus",
            "iPhone10,1": "iPhone 8",
            "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",
            "iPhone11,8": "iPhone XR",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone12,8": "iPhone SE (2nd generation)",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,6": "iPhone SE (3rd generation)",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            
            "iPad1,1": "iPad",
            "iPad2,1": "iPad 2",
            "iPad2,2": "iPad 2",
            "iPad2,3": "iPad 2",
            "iPad2,4": "iPad 2",
            "iPad3,1": "iPad (3rd generation)",
            "iPad3,2": "iPad (3rd generation)",
            "iPad3,3": "iPad (3rd generation)",
            "iPad3,4": "iPad (4th generation)",
            "iPad3,5": "iPad (4th generation)",
            "iPad3,6": "iPad (4th generation)",
            "iPad6,11": "iPad (5th generation)",
            "iPad6,12": "iPad (5th generation)",
            "iPad7,5": "iPad (6th generation)",
            "iPad7,6": "iPad (6th generation)",
            "iPad7,11": "iPad (7th generation)",
            "iPad7,12": "iPad (7th generation)",
            "iPad11,6": "iPad (8th generation)",
            "iPad11,7": "iPad (8th generation)",
            "iPad12,1": "iPad (9th generation)",
            "iPad12,2": "iPad (9th generation)",
            "iPad13,18": "iPad (10th generation)",
            "iPad13,19": "iPad (10th generation)",
            "iPad4,1": "iPad Air",
            "iPad4,2": "iPad Air",
            "iPad4,3": "iPad Air",
            "iPad5,3": "iPad Air 2",
            "iPad5,4": "iPad Air 2",
            "iPad11,3": "iPad Air (3rd generation)",
            "iPad11,4": "iPad Air (3rd generation)",
            "iPad13,1": "iPad Air (4th generation)",
            "iPad13,2": "iPad Air (4th generation)",
            "iPad13,16": "iPad Air (5th generation)",
            "iPad13,17": "iPad Air (5th generation)",
            
            "iPod1,1": "iPod touch",
            "iPod2,1": "iPod touch (2nd generation)",
            "iPod3,1": "iPod touch (3rd generation)",
            "iPod4,1": "iPod touch (4th generation)",
            "iPod5,1": "iPod touch (5th generation)",
            "iPod7,1": "iPod touch (6th generation)",
            "iPod9,1": "iPod touch (7th generation)"
        ]
        
        return modelMap[modelCode] ?? modelCode
    }
    
    fileprivate func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        
        return mapToDevice(modelCode: modelCode ?? "Unknown")
    }
    
    func fetchPublicIPAddress(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.ipify.org?format=text")!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let ipAddress = String(data: data, encoding: .utf8) {
                completion(ipAddress)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}

struct DeviceInfo: Codable {
    var name: String?
    var systemName: String?
    var systemVersion: String?
    var deviceModel: String?
    var publicIPAddress: String?
}

enum EventLogs: String {
    case onboardingView = "OnboardingView"
    case authView = "AuthView"
    case emailView = "EmailView"
    case authViaGoogle = "Google Login"
    case authViaApple = "Apple Login"
    case authViaEmail = "Email Login"
    case logout = "Logout"
    case chatView = "ChatView"
    case sendMessage = "Send Message"
}
