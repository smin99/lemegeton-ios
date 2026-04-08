//
//  Scenario.swift
//  lemegeton
//
//  Created by Min Hwang on 10/18/25.
//

import Foundation

struct Scenario {
    var name: String
    var characters: [Character]
}

struct ScenarioTemplate: Codable {
    let name: String
    let characters: [String]    // names of the characters
}
