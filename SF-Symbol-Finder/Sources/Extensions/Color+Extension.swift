//
//  Color+Extension.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/4/24.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
            let red = Double((hex >> 16) & 0xff) / 255.0
            let green = Double((hex >> 8) & 0xff) / 255.0
            let blue = Double(hex & 0xff) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    static let neutral = Color(hex: 0x191919)
    static let primary50 = Color(hex: 0xE2CAFF)
    static let primary100 = Color(hex: 0xCFA8FF)
    static let primary300 = Color(hex: 0xB77DFF)
    static let primary500 = Color(hex: 0x9F51FF)
}
