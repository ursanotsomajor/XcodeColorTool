import SwiftUI

struct ColorReplacementModel: Identifiable, Equatable
{
    var id = UUID()
    
    let color: Color
    let name: String
    
    static func == (lhs: Self, rhs: Self) -> Bool
    {
        return lhs.color == rhs.color
    }
}
