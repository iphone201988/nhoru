import SwiftUI

enum AppFontFamily {
    case dmSans
    case nunito
    case system
}

extension Font {
    
    static func appFont(family: AppFontFamily = .dmSans,
                        size: CGFloat = 17,
                        weight: Font.Weight = .regular) -> Font {
        
        let fontName: String
        
        switch family {
        case .dmSans:
            switch weight {
            case .medium:
                fontName = "DMSans-Medium"
            case .semibold:
                fontName = "DMSans-SemiBold"
            case .bold:
                fontName = "DMSans-Bold"
            default:
                fontName = "DMSans-Regular"
            }
            
        case .nunito:
            switch weight {
            case .medium:
                fontName = "Nunito-Medium"
            case .semibold:
                fontName = "Nunito-SemiBold"
            case .bold:
                fontName = "Nunito-Bold"
            default:
                fontName = "Nunito-Regular"
            }
            
        case .system:
            return .system(size: size, weight: weight)
        }
        
        return .custom(fontName, size: size)
    }
}
