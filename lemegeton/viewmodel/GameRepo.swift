import Foundation

final class GameRepo {
    static let shared = GameRepo()
    
    private let currentGameFileName = "currentGame.json"
    private let pastGamesFileName = "pastGames.json"
    
    private var documentsURL: URL {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot access documents directory")
        }
        return dir
    }
    
    private var currentGameURL: URL { documentsURL.appendingPathComponent(currentGameFileName) }
    private var pastGamesURL: URL { documentsURL.appendingPathComponent(pastGamesFileName) }
    
    private(set) var currentGame: Game?
    private(set) var pastGames: [Game] = []
    
    private init() {
        loadPastGames()
        loadCurrentGame()
    }
    
    // MARK: - Public API
    func startNewGame() {
        currentGame = Game()
        saveCurrentGame(currentGame: currentGame!)
    }
    
    func endCurrentGame() {
        guard var game = currentGame else { return }
        game.isCompleted = true
        
        // prepend to history (most recent first)
        pastGames.insert(game, at: 0)
        savePastGames()
        
        // clear current
        currentGame = nil
        removeFileIfExists(at: currentGameURL)
    }
    
    func saveCurrentGame(currentGame: Game) {
        self.currentGame = currentGame
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(currentGame)
            try data.write(to: currentGameURL, options: [.atomicWrite])
        } catch {
            print("[GameRepo] Failed to save current game: \(error)")
        }
    }
    
    func loadCurrentGame() {
        guard FileManager.default.fileExists(atPath: currentGameURL.path) else {
            currentGame = nil
            return
        }
        do {
            let data = try Data(contentsOf: currentGameURL)
            let decoder = JSONDecoder()
            currentGame = try decoder.decode(Game.self, from: data)
        } catch {
            print("[GameRepo] Failed to load current game: \(error)")
            currentGame = nil
        }
    }
    
    func savePastGames() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(pastGames)
            try data.write(to: pastGamesURL, options: [.atomicWrite])
        } catch {
            print("[GameRepo] Failed to save past games: \(error)")
        }
    }
    
    func loadPastGames() {
        guard FileManager.default.fileExists(atPath: pastGamesURL.path) else {
            pastGames = []
            return
        }
        do {
            let data = try Data(contentsOf: pastGamesURL)
            let decoder = JSONDecoder()
            pastGames = try decoder.decode([Game].self, from: data)
        } catch {
            print("[GameRepo] Failed to load past games: \(error)")
            pastGames = []
        }
    }
    
    func removePastGames(atOffsets offsets: IndexSet) {
        for offset in offsets.sorted(by: >) {
            guard pastGames.indices.contains(offset) else { continue }
            pastGames.remove(at: offset)
        }
        savePastGames()
    }
    
    // MARK: - Utility
    private func removeFileIfExists(at url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do { try FileManager.default.removeItem(at: url) } catch {
                print("[GameRepo] Failed to remove file: \(error)")
            }
        }
    }
}
