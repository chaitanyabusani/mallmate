import Foundation
import SwiftUI

struct FloorDirectory: Decodable, Identifiable {
    let name: String
    let stores: [String]
    var id: String { name }
}

struct StoreEntry: Hashable, Identifiable {
    let name: String
    let floor: String
    var id: String { "\(floor)::\(name)" }
}

struct StoreDirectoryFile: Decodable {
    let mall: String
    let source: String
    let floors: [FloorDirectory]
}

enum StoreFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case shopping = "Shopping"
    case food = "Food"
    case fun = "Fun"
    var id: String { rawValue }
}

struct MallService: Identifiable, Hashable {
    let name: String
    let symbol: String
    var id: String { name }

    static let all: [MallService] = [
        MallService(name: "Lift", symbol: "arrow.up.and.down"),
        MallService(name: "Escalator", symbol: "figure.stairs"),
        MallService(name: "Restroom", symbol: "figure.stand"),
        MallService(name: "Help desk", symbol: "info.circle"),
        MallService(name: "Exit", symbol: "arrow.up.right"),
        MallService(name: "Food court", symbol: "fork.knife"),
        MallService(name: "Accessible route", symbol: "figure.roll"),
        MallService(name: "First aid", symbol: "cross.case"),
        MallService(name: "ATM", symbol: "banknote"),
        MallService(name: "Water refill", symbol: "drop")
    ]
}

struct ServiceMapMarker: Identifiable {
    let name: String
    let symbol: String
    let x: CGFloat
    let y: CGFloat
    var id: String { name }
}

@MainActor
final class MallmateModel: ObservableObject {
    @Published private(set) var directory: StoreDirectoryFile
    @Published var currentFloor = "Upper Ground Floor"
    @Published var selectedFloorFilter = "All Floors"
    @Published var searchText = ""
    @Published var selectedFilter: StoreFilter = .all
    @Published var selectedStore: StoreEntry?
    @Published var selectedService: MallService?
    @Published var showServices = false
    @Published var isNavigating = false
    @Published var savedCarBay: String? {
        didSet {
            if let savedCarBay {
                UserDefaults.standard.set(savedCarBay, forKey: "mallmate.savedCarBay")
            } else {
                UserDefaults.standard.removeObject(forKey: "mallmate.savedCarBay")
            }
        }
    }
    @Published var favorites: Set<String> {
        didSet { UserDefaults.standard.set(Array(favorites), forKey: "mallmate.favorites") }
    }
    @Published var showingWiFiGuide = false

    init() {
        savedCarBay = UserDefaults.standard.string(forKey: "mallmate.savedCarBay")
        favorites = Set(UserDefaults.standard.stringArray(forKey: "mallmate.favorites") ?? [])
        if let url = Bundle.main.url(forResource: "StoreDirectory", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(StoreDirectoryFile.self, from: data) {
            directory = decoded
        } else {
            directory = StoreDirectoryFile(
                mall: "Sarath City Capital Mall",
                source: "https://sarathcitycapitalmall.com/store-directory/",
                floors: []
            )
        }
    }

    var floorNames: [String] { directory.floors.map(\.name) }

    var allStores: [StoreEntry] {
        directory.floors.flatMap { floor in
            floor.stores.map { StoreEntry(name: $0, floor: floor.name) }
        }
    }

    var visibleStores: [StoreEntry] {
        allStores.filter { store in
            (selectedFloorFilter == "All Floors" || store.floor == selectedFloorFilter) &&
            (searchText.isEmpty || store.name.localizedCaseInsensitiveContains(searchText) || store.floor.localizedCaseInsensitiveContains(searchText))
        }
    }

    var favoriteStores: [StoreEntry] {
        allStores.filter { favorites.contains($0.id) }
    }

    func choose(_ store: StoreEntry) {
        selectedStore = store
        selectedService = nil
        currentFloor = store.floor
        showServices = false
        isNavigating = false
    }

    func choose(_ service: MallService) {
        selectedStore = nil
        selectedService = service
        showServices = true
        isNavigating = false
    }

    func clearRoute() {
        selectedStore = nil
        selectedService = nil
        isNavigating = false
    }

    func isFavorite(_ store: StoreEntry) -> Bool {
        favorites.contains(store.id)
    }

    func toggleFavorite(_ store: StoreEntry) {
        if favorites.contains(store.id) {
            favorites.remove(store.id)
        } else {
            favorites.insert(store.id)
        }
    }
}

enum MallmatePalette {
    static let ink = Color(red: 0.09, green: 0.14, blue: 0.11)
    static let muted = Color(red: 0.43, green: 0.48, blue: 0.44)
    static let paper = Color(red: 0.96, green: 0.96, blue: 0.93)
    static let green = Color(red: 0.84, green: 0.96, blue: 0.42)
    static let greenDark = Color(red: 0.31, green: 0.40, blue: 0.18)
    static let coral = Color(red: 0.91, green: 0.47, blue: 0.36)
    static let blue = Color(red: 0.36, green: 0.48, blue: 0.80)
    static let line = Color(red: 0.90, green: 0.91, blue: 0.88)
}
