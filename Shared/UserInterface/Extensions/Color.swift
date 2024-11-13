//
//  Color.swift
//  Commitment
//
//  Created by Stef Kors on 28/02/2023.
//

import SwiftUI
import AppKit

extension Color {
    fileprivate var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard let hsbColor = NSColor(self).usingColorSpace(NSColorSpace.deviceRGB) else {
            return (r, g, b, o)
        }

        r = hsbColor.redComponent
        g = hsbColor.greenComponent
        b = hsbColor.blueComponent
        o = hsbColor.alphaComponent

        return (r, g, b, o)
    }

    /// Adjust color lighter by percentage e.g. `30` is `30%`
    /// - Parameter percentage: expressed in number
    /// - Returns: Adjusted color
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: abs(percentage) )
    }

    /// Adjust color darker by percentage e.g. `30` is `30%`
    /// - Parameter percentage: expressed in number
    /// - Returns: Adjusted color
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: -1 * abs(percentage) )
    }

    /// Adjust color by percentage e.g. `30` is `30%`. Negative numbers adjust color darker, Positive numbers adjust lighter.
    /// - Parameter percentage: expressed in number
    /// - Returns: Adjusted color
    func adjust(by percentage: CGFloat = 30.0) -> Color {
        return Color(red: min(Double(self.components.red + percentage/100), 1.0),
                     green: min(Double(self.components.green + percentage/100), 1.0),
                     blue: min(Double(self.components.blue + percentage/100), 1.0),
                     opacity: Double(self.components.opacity))
    }
}

extension Color {
    static func generateColor(for text: String) -> Color {
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars{
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256*256*256);
        //let color = UIColor(hue:CGFloat(finalHash)/255.0 , saturation: 0.40, brightness: 0.75, alpha: 1.0)
        return Color(
            red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0,
            blue: CGFloat((finalHash & 0xFF)) / 255.0
        )
    }

    static func generateHSLColor(for text: String) -> Color {
        var hash = 0;
        let colorConstant = 50
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars {
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }

        let hue = hash % 360;

        let finalHue = CGFloat(hue.clamped(to: 0...360))/360
        return Color(
            hue: finalHue,
            saturation: 72/100,
            lightness: 50/100,
            opacity: 1.0
        )
    }

    init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, opacity: CGFloat) {
        precondition(0...1 ~= hue &&
                     0...1 ~= saturation &&
                     0...1 ~= lightness &&
                     0...1 ~= opacity, "input range is out of range 0...1")

        //From HSL TO HSB ---------
        var newSaturation: Double = 0.0

        let brightness = lightness + saturation * min(lightness, 1-lightness)

        if brightness == 0 { newSaturation = 0.0 }
        else {
            newSaturation = 2 * (1 - lightness / brightness)
        }
        //---------

        self.init(hue: hue, saturation: newSaturation, brightness: brightness, opacity: opacity)
    }
}
