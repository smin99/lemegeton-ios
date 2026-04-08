//
//  GrimoireTextStyle.swift
//  lemegeton
//
//  Created by 승민 on 3/23/26.
//

import SwiftUI

struct GrimoireText: ViewModifier {
    var size: CGFloat = 18
    var isItalic: Bool = true
    var isBold: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.custom(isBold ? "Georgia-Bold" : isItalic ? "Georgia-Italic" : "Georgia", size: size))
            .foregroundColor(.themePrimary)
    }
}

extension View {
    func grimoireStyle(size: CGFloat = 18, italic: Bool = true) -> some View {
        self.modifier(GrimoireText(size: size, isItalic: italic))
    }
    
    func grimoireBoldStyle(size: CGFloat = 18) -> some View {
        self.modifier(GrimoireText(size: size, isItalic: false, isBold: true))
    }
}
