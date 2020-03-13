import SwiftUI

struct ColorReplacementModel: Identifiable
{
    var id = UUID()
    
    let customColor: CustomColor
    let name: String
    
    // TODO: Adopt CIEDE2000
    // http://www2.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf
    
    func isSimilar(r: Double, g: Double, b: Double, delta: Double = 0.0) -> Bool
    {
        let rDelta = abs(r - customColor.r)
        let gDelta = abs(g - customColor.g)
        let bDelta = abs(b - customColor.b)

        return rDelta <= delta && gDelta <= delta && bDelta <= delta
    }
}
