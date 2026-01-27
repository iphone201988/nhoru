import Foundation

struct StoredKeys<Value> {
    
    let name: String
    
    init(_ name: Keyname) {
        self.name = name.rawValue
    }
    
    static var deviceToken: StoredKeys<String> {
        return StoredKeys<String>(Keyname.deviceToken)
    }
    
    static var accessToken: StoredKeys<String> {
        return StoredKeys<String>(Keyname.accessToken)
    }
    
    static var isLogged: StoredKeys<Bool> {
        return StoredKeys<Bool>(Keyname.isLogged)
    }
}
