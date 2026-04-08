//
//  GrimoireButtonStyle.swift
//  lemegeton
//
//  Created by 승민 on 3/23/26.
//

import SwiftUI

struct GrimoireButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Georgia-Bold", size: 16))
            .padding()
            .foregroundColor(isDestructive ? .red : .themeSecondary)
            // Adds a "fade" effect when the user taps the button
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
