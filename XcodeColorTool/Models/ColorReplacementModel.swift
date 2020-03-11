import SwiftUI

struct ColorReplacementModel: Identifiable, Equatable
{
    var id = UUID()
    
    let customColor: CustomColor
    let name: String
    
    static func == (lhs: Self, rhs: Self) -> Bool
    {
        return lhs.customColor.r == rhs.customColor.r && lhs.customColor.g == rhs.customColor.g && lhs.customColor.b == rhs.customColor.b
    }
}
