import SwiftUI

struct CustomColor
{
    let r: Double
    let g: Double
    let b: Double
    let a: Double
    
    let hex: String
    
    init?(hex: String)
    {
        guard let (r, g, b, a) = Color.rgba(from: hex) else { return nil }

        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.hex = hex
    }
    
    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }
}
