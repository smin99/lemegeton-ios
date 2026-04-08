//
//  GlowButtonStyle.swift
//  lemegeton
//
//  Created by 승민 on 3/23/26.
//

import SwiftUI

struct GlowButtonStyle: ButtonStyle {
    @State private var isAnimating = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Georgia-Bold", size: 18))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // The Outer Glow (Pulsing)
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.themeSecondary, lineWidth: 2)
                        .blur(radius: isAnimating ? 6 : 2) // Animates the "spread"
                        .opacity(isAnimating ? 0.8 : 0.4)
                    
                    // The Inner Button Surface
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.themeSecondary.opacity(0.5), lineWidth: 1)
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}
