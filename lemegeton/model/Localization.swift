import Foundation

enum L10n {
    static func tr(_ key: String) -> String {
        resolveKoreanParticles(in: NSLocalizedString(key, comment: ""))
    }
    
    static func tr(_ key: String, _ args: CVarArg...) -> String {
        let localized = String(
            format: NSLocalizedString(key, comment: ""),
            locale: Locale.current,
            arguments: args
        )
        return resolveKoreanParticles(in: localized)
    }

    private static func resolveKoreanParticles(in text: String) -> String {
        guard text.contains("#{") else {
            return text
        }

        var result = ""
        var currentIndex = text.startIndex

        while let markerRange = text[currentIndex...].range(of: #"#\{[^}]+\}"#, options: .regularExpression) {
            result += text[currentIndex..<markerRange.lowerBound]

            let markerBody = text[
                text.index(markerRange.lowerBound, offsetBy: 2)..<text.index(before: markerRange.upperBound)
            ]
            result += resolvedParticle(String(markerBody), in: result)
            currentIndex = markerRange.upperBound
        }

        result += text[currentIndex...]
        return result
    }

    private static func resolvedParticle(_ marker: String, in text: String) -> String {
        let parts = marker.split(separator: "/", maxSplits: 1).map(String.init)
        guard parts.count == 2 else {
            return ""
        }

        let previousCharacter = lastMeaningfulCharacter(in: text)
        let useFirstForm = shouldUseConsonantForm(before: previousCharacter, first: parts[0], second: parts[1])
        return useFirstForm ? parts[0] : parts[1]
    }

    private static func lastMeaningfulCharacter(in text: String) -> Swift.Character? {
        for character in text.reversed() where !character.isWhitespace {
            return character
        }
        return nil
    }

    private static func shouldUseConsonantForm(before character: Swift.Character?, first: String, second: String) -> Bool {
        guard let character else {
            return false
        }

        if first == "으로", second == "로" {
            return shouldUseEuroRoConsonantForm(for: character)
        }

        return hasFinalConsonant(character)
    }

    private static func shouldUseEuroRoConsonantForm(for character: Swift.Character) -> Bool {
        guard let syllable = hangulSyllable(for: character) else {
            return hasFinalConsonant(character)
        }

        let jongseong = (syllable - 0xAC00) % 28
        return jongseong != 0 && jongseong != 8
    }

    private static func hasFinalConsonant(_ character: Swift.Character) -> Bool {
        if let syllable = hangulSyllable(for: character) {
            return (syllable - 0xAC00) % 28 != 0
        }

        let characterString = String(character)

        if let digit = Int(characterString) {
            return [0, 1, 3, 6, 7, 8].contains(digit)
        }

        return !"aeiou".contains(characterString.lowercased())
    }

    private static func hangulSyllable(for character: Swift.Character) -> UInt32? {
        let characterString = String(character)
        guard characterString.unicodeScalars.count == 1,
              let scalar = characterString.unicodeScalars.first else {
            return nil
        }

        return (UInt32(0xAC00)...UInt32(0xD7A3)).contains(scalar.value) ? scalar.value : nil
    }
}
