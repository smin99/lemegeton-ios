//
//  CharacterService.swift
//  lemegeton
//
//  Created by Min Hwang on 10/19/25.
//

import Foundation

struct CharacterService {
    static let isSpecialHalloweenEnabled = false
    
    static let availableCharacters: [Character] = {
        let baseCharacters = load([Character].self, fileName: "characters")
        
        guard isSpecialHalloweenEnabled else {
            return baseCharacters
        }
        
        let specialHalloweenCharacters = load([Character].self, fileName: "special_halloween_characters")
        return baseCharacters + specialHalloweenCharacters
    }()
    
    static let scenarios: [Scenario] = load([ScenarioTemplate].self, fileName: "scenario").map { toScenario(template: $0) }
    
    private static func load<T: Decodable>(_ type: T.Type, fileName: String) -> T {
        // Step A: Locate the file in the app bundle
        guard let file = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Couldn't find \(fileName).json in main bundle.")
        }
        
        // Step B: Load the file into raw Data
        let data: Data
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(fileName).json from main bundle:\n\(error)")
        }
        
        // Step C: Decode the Data into the expected type (T, which is [GameCharacter])
        do {
            let decoder = JSONDecoder()
            // Ensure the decoder can handle JSON keys matching Swift camelCase (optional but good practice)
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(fileName).json as \(T.self):\n\(error)")
        }
    }
    
    private static func toScenario(template: ScenarioTemplate) -> Scenario {
        let characters = template.characters.compactMap { name in
            availableCharacters.first(where: { $0.name == name })
        }
        return Scenario(name: template.name, characters: characters)
    }
}
