//
//  ScenarioCarousel.swift
//  lemegeton
//
//  Created by 승민 on 2/16/26.
//

import SwiftUI

struct ScenarioCarousel: View {
    let onSelected: (Set<Character>) -> Void
    
    var body: some View {
        // Horizontal carousel of scenarios
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CharacterService.scenarios, id: \.name) { scenario in
                    Button(action: {
                        // Update in-game characters to match the scenario
                        let characters = scenario.characters.sorted { $0.type.rawValue < $1.type.rawValue }
                        onSelected(Set(characters))
                    }) {
                        Text(scenario.name)
                            .font(.headline)
                            .foregroundStyle(.themeOnPrimary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.themePrimary))
                    )
                }
            }
        }
    }
}
