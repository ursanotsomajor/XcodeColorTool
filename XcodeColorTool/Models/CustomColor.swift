import SwiftUI

struct CustomColor: Hashable
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
    
    init(r: Double, g: Double, b: Double, a: Double)
    {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        
        self.hex = String(format: "#%06x", Int(r*255) << 16 | Int(g*255) << 8 | Int(b*255) << 0)
    }
    
    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }
}
