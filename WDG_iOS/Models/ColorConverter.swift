//
//  ColorConverter.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/30/23.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var toInt: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&toInt)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (toInt >> 8) * 17, (toInt >> 4 & 0xF) * 17, (toInt & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, toInt >> 16, toInt >> 8 & 0xFF, toInt & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (toInt >> 24, toInt >> 16 & 0xFF, toInt >> 8 & 0xFF, toInt & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
