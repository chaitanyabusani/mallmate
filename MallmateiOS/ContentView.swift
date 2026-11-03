import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject private var model: MallmateModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MallMapScreen()
            }
            .tabItem { Label("Map", systemImage: "map") }
            .tag(0)

            NavigationStack {
                StoreDirectoryScreen {
                    selectedTab = 0
                }
            }
            .tabItem { Label("Directory", systemImage: "list.bullet") }
            .tag(1)

            NavigationStack {
                ParkingScreen()
            }
            .tabItem { Label("Parking", systemImage: "car") }
            .tag(2)

            NavigationStack {
                SavedPlacesScreen {
                    selectedTab = 0
                }
            }
            .tabItem { Label("Saved", systemImage: "heart") }
            .tag(3)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .alert("Mall Wi-Fi guide", isPresented: $model.showingWiFiGuide) {
            Button("Done", role: .cancel) { }
        } message: {
            Text("Join the mall’s guest network in iPhone Settings → Wi-Fi. Network names and access details need to be confirmed by mall management.")
        }
    }
}

struct MallMapScreen: View {
    @EnvironmentObject private var model: MallmateModel
    @State private var showingOfficialPlan = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                HStack(alignment: .center, spacing: 11) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(MallmatePalette.green).frame(width: 40, height: 40)
                        Text("m").font(.system(size: 25, weight: .black, design: .rounded)).foregroundStyle(MallmatePalette.ink)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("mallmate").font(.system(size: 19, weight: .heavy, design: .rounded)).tracking(-0.8)
                        Text("SARATH CITY CAPITAL MALL").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(1.2).foregroundStyle(MallmatePalette.muted)
                    }
                    Spacer()
                    Button { model.showingWiFiGuide = true } label: {
                        Image(systemName: "wifi").font(.system(size: 16, weight: .semibold)).frame(width: 40, height: 40)
                    }
                    .buttonStyle(.bordered)
                    .tint(MallmatePalette.ink)
                    .accessibilityLabel("Wi-Fi help")
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(MallmatePalette.blue)
                            .frame(width: 35, height: 35)
                            .background(MallmatePalette.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text("YOUR LOCATION").font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(MallmatePalette.muted)
                                Spacer()
                                Text("DEMO").font(.system(size: 8, weight: .heavy)).tracking(0.8).foregroundStyle(MallmatePalette.greenDark).padding(.horizontal, 7).padding(.vertical, 4).background(MallmatePalette.green.opacity(0.32), in: Capsule())
                            }
                            Text("Near Lifestyle · Upper Ground").font(.system(size: 13, weight: .bold)).foregroundStyle(MallmatePalette.ink)
                            Text("Live indoor position is not connected yet").font(.system(size: 10)).foregroundStyle(MallmatePalette.muted)
                        }
                    }
                }
                .padding(13)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(MallmatePalette.line, lineWidth: 1))

                VStack(spacing: 12) {
                    HStack(alignment: .center, spacing: 9) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Explore the mall").font(.system(size: 16, weight: .bold)).foregroundStyle(MallmatePalette.ink)
                            Text("Store list is grouped by floor").font(.system(size: 10)).foregroundStyle(MallmatePalette.muted)
                        }
                        Spacer(minLength: 2)
                        Menu {
                            ForEach(model.floorNames, id: \.self) { floor in
                                Button {
                                    model.currentFloor = floor
                                    model.clearRoute()
                                } label: {
                                    if model.currentFloor == floor {
                                        Label(floor, systemImage: "checkmark")
                                    } else {
                                        Text(floor)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Text(model.currentFloor.replacingOccurrences(of: " Floor", with: ""))
                                    .lineLimit(1)
                                Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
                            }
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 10).padding(.vertical, 9)
                            .foregroundStyle(MallmatePalette.ink)
                            .background(MallmatePalette.paper, in: Capsule())
                        }
                        .accessibilityLabel("Choose floor")
                    }

                    HStack(spacing: 6) {
                        MapModeButton(title: "Shops", icon: "storefront", selected: !model.showServices) { model.showServices = false; model.selectedService = nil }
                        MapModeButton(title: "Services", icon: "figure.roll", selected: model.showServices) { model.showServices = true; model.selectedStore = nil }
                    }
                    MallMapIllustration()
                        .frame(height: 325)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    if let store = model.selectedStore {
                        RoutePreviewCard(title: store.name, subtitle: "\(store.floor) · schematic route preview", isNavigating: model.isNavigating, start: {
                            model.isNavigating.toggle()
                        }, dismiss: model.clearRoute)
                    } else if let service = model.selectedService {
                        RoutePreviewCard(title: "Nearest \(service.name)", subtitle: "\(model.currentFloor) · schematic route preview", isNavigating: model.isNavigating, start: {
                            model.isNavigating.toggle()
                        }, dismiss: model.clearRoute)
                    }

                    HStack(spacing: 7) {
                        Image(systemName: "info.circle")
                        Text("Map is a schematic. Exact shop positions and live indoor location need mall map data.")
                    }
                    .font(.system(size: 9))
                    .foregroundStyle(MallmatePalette.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Button { showingOfficialPlan = true } label: {
                        Label("Open the mall’s official floor plans", systemImage: "map")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .tint(MallmatePalette.greenDark)
                }
                .padding(14)
                .background(.white, in: RoundedRectangle(cornerRadius: 19))
                .overlay(RoundedRectangle(cornerRadius: 19).stroke(MallmatePalette.line, lineWidth: 1))

                VStack(alignment: .leading, spacing: 11) {
                    SectionTitle(title: "Useful nearby", action: "All services", actionTap: { model.showServices = true; model.selectedStore = nil })
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(MallService.all) { service in
                            Button {
                                model.choose(service)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: service.symbol).font(.system(size: 13, weight: .semibold)).foregroundStyle(MallmatePalette.greenDark).frame(width: 21)
                                    Text(service.name).font(.system(size: 10, weight: .medium)).foregroundStyle(MallmatePalette.ink)
                                    Spacer(minLength: 0)
                                }
                                .padding(10)
                                .background(MallmatePalette.paper, in: RoundedRectangle(cornerRadius: 11))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(14)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(MallmatePalette.line, lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.top, 9)
            .padding(.bottom, 24)
        }
        .background(MallmatePalette.paper.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingOfficialPlan) {
            OfficialFloorPlanSheet()
        }
    }
}

struct OfficialFloorPlanSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            OfficialFloorPlanWebView(url: URL(string: "https://sarathcitycapitalmall.com/map/")!)
                .navigationTitle("Official Floor Plans")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
        .presentationDetents([.large])
    }
}

struct OfficialFloorPlanWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) { }
}

struct MallMapIllustration: View {
    @EnvironmentObject private var model: MallmateModel

    private var services: [ServiceMapMarker] {
        [
            ServiceMapMarker(name: "Lift", symbol: "arrow.up.and.down", x: 0.50, y: 0.12),
            ServiceMapMarker(name: "Escalator", symbol: "figure.stairs", x: 0.50, y: 0.88),
            ServiceMapMarker(name: "Restroom", symbol: "figure.stand", x: 0.87, y: 0.51),
            ServiceMapMarker(name: "Help desk", symbol: "info", x: 0.13, y: 0.51),
            ServiceMapMarker(name: "Exit", symbol: "arrow.up.right", x: 0.84, y: 0.81),
            ServiceMapMarker(name: "Food court", symbol: "fork.knife", x: 0.18, y: 0.76),
            ServiceMapMarker(name: "Accessible route", symbol: "figure.roll", x: 0.17, y: 0.28),
            ServiceMapMarker(name: "First aid", symbol: "cross.case", x: 0.83, y: 0.28),
            ServiceMapMarker(name: "ATM", symbol: "banknote", x: 0.65, y: 0.13),
            ServiceMapMarker(name: "Water refill", symbol: "drop", x: 0.65, y: 0.87)
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let routeCrossesFloors = model.selectedStore != nil && model.selectedStore?.floor != "Upper Ground Floor"
            let showCurrentPosition = model.currentFloor == "Upper Ground Floor" || (routeCrossesFloors && model.selectedStore?.floor == model.currentFloor)
            let start = routeCrossesFloors
                ? CGPoint(x: size.width * 0.50, y: size.height * 0.13)
                : CGPoint(x: size.width * 0.20, y: size.height * 0.34)
            let destination = CGPoint(x: size.width * 0.80, y: size.height * 0.68)

            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.94, green: 0.94, blue: 0.90))
                Path { path in
                    path.move(to: CGPoint(x: size.width * 0.20, y: size.height * 0.18))
                    path.addLine(to: CGPoint(x: size.width * 0.80, y: size.height * 0.18))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.88, y: size.height * 0.29), control: CGPoint(x: size.width * 0.88, y: size.height * 0.18))
                    path.addLine(to: CGPoint(x: size.width * 0.88, y: size.height * 0.72))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.80, y: size.height * 0.83), control: CGPoint(x: size.width * 0.88, y: size.height * 0.83))
                    path.addLine(to: CGPoint(x: size.width * 0.20, y: size.height * 0.83))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.12, y: size.height * 0.72), control: CGPoint(x: size.width * 0.12, y: size.height * 0.83))
                    path.addLine(to: CGPoint(x: size.width * 0.12, y: size.height * 0.29))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.20, y: size.height * 0.18), control: CGPoint(x: size.width * 0.12, y: size.height * 0.18))
                }
                .stroke(Color(red: 0.72, green: 0.75, blue: 0.70), style: StrokeStyle(lineWidth: 48, lineCap: .round, lineJoin: .round))
                Path { path in
                    path.move(to: CGPoint(x: size.width * 0.20, y: size.height * 0.18))
                    path.addLine(to: CGPoint(x: size.width * 0.80, y: size.height * 0.18))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.88, y: size.height * 0.29), control: CGPoint(x: size.width * 0.88, y: size.height * 0.18))
                    path.addLine(to: CGPoint(x: size.width * 0.88, y: size.height * 0.72))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.80, y: size.height * 0.83), control: CGPoint(x: size.width * 0.88, y: size.height * 0.83))
                    path.addLine(to: CGPoint(x: size.width * 0.20, y: size.height * 0.83))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.12, y: size.height * 0.72), control: CGPoint(x: size.width * 0.12, y: size.height * 0.83))
                    path.addLine(to: CGPoint(x: size.width * 0.12, y: size.height * 0.29))
                    path.addQuadCurve(to: CGPoint(x: size.width * 0.20, y: size.height * 0.18), control: CGPoint(x: size.width * 0.12, y: size.height * 0.18))
                }
                .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 2, dash: [2, 8]))

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.86, green: 0.89, blue: 0.82))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(red: 0.78, green: 0.83, blue: 0.73), lineWidth: 1))
                    .frame(width: size.width * 0.34, height: size.height * 0.39)
                    .position(x: size.width * 0.50, y: size.height * 0.51)
                VStack(spacing: 4) {
                    Image(systemName: "leaf").font(.system(size: 16))
                    Text("CENTRAL ATRIUM").font(.system(size: 8, weight: .heavy)).tracking(1)
                    Text("open space").font(.system(size: 8))
                }
                .foregroundStyle(Color(red: 0.46, green: 0.53, blue: 0.41))
                .position(x: size.width * 0.50, y: size.height * 0.51)

                mapShopFronts(size: size)

                if model.selectedStore != nil || model.selectedService != nil {
                    Path { path in
                        path.move(to: start)
                        path.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.34))
                        path.addLine(to: CGPoint(x: size.width * 0.76, y: size.height * 0.34))
                        path.addLine(to: destination)
                    }
                    .stroke(MallmatePalette.coral, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round, dash: [7, 7]))
                    Circle().fill(MallmatePalette.coral).frame(width: 12, height: 12).overlay(Circle().stroke(.white, lineWidth: 3)).position(destination)
                    Text(model.selectedStore?.name ?? model.selectedService?.name ?? "Destination")
                        .font(.system(size: 9, weight: .bold)).lineLimit(1).padding(.horizontal, 8).padding(.vertical, 5)
                        .background(.white, in: Capsule()).shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                        .position(x: min(size.width - 76, destination.x), y: max(12, destination.y - 24))
                }

                if showCurrentPosition {
                    Circle().fill(MallmatePalette.blue.opacity(0.16)).frame(width: 36, height: 36).position(start)
                    Circle().fill(MallmatePalette.blue).frame(width: 13, height: 13).overlay(Circle().stroke(.white, lineWidth: 3)).position(start)
                    Text(routeCrossesFloors ? "LIFT" : "YOU")
                        .font(.system(size: 8, weight: .heavy)).foregroundStyle(MallmatePalette.blue).position(x: start.x + 23, y: start.y - 11)
                }

                if model.showServices {
                    ForEach(services) { service in
                        Button {
                            model.choose(MallService(name: service.name, symbol: service.symbol))
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: service.symbol).font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(MallmatePalette.greenDark)
                                    .frame(width: 28, height: 28)
                                    .background(.white, in: Circle())
                                    .overlay(Circle().stroke(MallmatePalette.greenDark.opacity(0.35), lineWidth: 1))
                                Text(service.name.uppercased()).font(.system(size: 6, weight: .heavy)).lineLimit(1).foregroundStyle(MallmatePalette.ink)
                            }
                        }
                        .buttonStyle(.plain)
                        .position(x: size.width * service.x, y: size.height * service.y)
                    }
                } else if model.selectedStore == nil {
                    Text(model.currentFloor).font(.system(size: 8, weight: .bold)).foregroundStyle(MallmatePalette.muted)
                        .padding(.horizontal, 8).padding(.vertical, 5).background(.white.opacity(0.9), in: Capsule())
                        .position(x: size.width * 0.5, y: size.height * 0.27)
                }
            }
            .overlay(alignment: .topLeading) {
                Text(model.currentFloor.replacingOccurrences(of: " Floor", with: ""))
                    .font(.system(size: 9, weight: .heavy)).padding(.horizontal, 9).padding(.vertical, 6)
                    .background(.white.opacity(0.94), in: Capsule()).padding(9)
            }
            .overlay(alignment: .bottomTrailing) {
                HStack(spacing: 5) {
                    Circle().fill(MallmatePalette.blue).frame(width: 6, height: 6)
                    Text(showCurrentPosition ? "DEMO LOCATION" : "SCHEMATIC FLOOR VIEW").font(.system(size: 7, weight: .heavy)).foregroundStyle(MallmatePalette.muted)
                }
                .padding(.horizontal, 8).padding(.vertical, 6).background(.white.opacity(0.94), in: Capsule()).padding(9)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Schematic mall map")
    }

    @ViewBuilder
    private func mapShopFronts(size: CGSize) -> some View {
        ForEach(0..<4, id: \.self) { index in
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(red: 0.77, green: 0.79, blue: 0.74), lineWidth: 1))
                .frame(width: size.width * 0.12, height: size.height * 0.10)
                .position(x: size.width * 0.035 + size.width * 0.06, y: size.height * (0.23 + CGFloat(index) * 0.18))
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(red: 0.77, green: 0.79, blue: 0.74), lineWidth: 1))
                .frame(width: size.width * 0.12, height: size.height * 0.10)
                .position(x: size.width * 0.905, y: size.height * (0.23 + CGFloat(index) * 0.18))
        }
    }
}

struct StoreDirectoryScreen: View {
    @EnvironmentObject private var model: MallmateModel
    let onShowMap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Search every store", text: $model.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(11)
                    .background(MallmatePalette.paper, in: RoundedRectangle(cornerRadius: 11))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        FloorFilterChip(title: "All Floors", selected: model.selectedFloorFilter == "All Floors") {
                            model.selectedFloorFilter = "All Floors"
                        }
                        ForEach(model.floorNames, id: \.self) { floor in
                            FloorFilterChip(title: floor, selected: model.selectedFloorFilter == floor) {
                                model.selectedFloorFilter = floor
                            }
                        }
                    }
                }
                HStack {
                    Text("\(model.visibleStores.count) stores").font(.system(size: 11, weight: .bold))
                    Spacer()
                    Link("Official mall directory ↗", destination: URL(string: "https://sarathcitycapitalmall.com/store-directory/")!)
                        .font(.system(size: 9, weight: .medium)).tint(MallmatePalette.greenDark)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 9)

            List(model.visibleStores) { store in
                StoreRow(store: store, isFavorite: model.isFavorite(store), favoriteTap: { model.toggleFavorite(store) }) {
                    model.choose(store)
                    onShowMap()
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 3, leading: 14, bottom: 3, trailing: 14))
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(MallmatePalette.paper.ignoresSafeArea())
        .navigationTitle("Store directory")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ParkingScreen: View {
    @EnvironmentObject private var model: MallmateModel
    @State private var selectedBay: String?
    private let bays = ["A-108", "A-109", "A-120", "A-127", "A-134", "B-147", "B-167", "B-181", "C-301", "C-341"]
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Find your car").font(.system(size: 25, weight: .bold, design: .rounded)).tracking(-0.8)
                    Text("Tap the bay where you parked to save it on this device.").font(.system(size: 12)).foregroundStyle(MallmatePalette.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ParkingSchematic(savedBay: model.savedCarBay)
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Sample parking bays").font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text("Basement level").font(.system(size: 10)).foregroundStyle(MallmatePalette.muted)
                    }
                    LazyVGrid(columns: columns, spacing: 9) {
                        ForEach(bays, id: \.self) { bay in
                            Button {
                                selectedBay = bay
                            } label: {
                                VStack(spacing: 5) {
                                    Image(systemName: bay == model.savedCarBay ? "car.fill" : "parkingsign.circle")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(bay).font(.system(size: 10, weight: .bold))
                                }
                                .frame(maxWidth: .infinity).frame(height: 62)
                                .foregroundStyle(bay == selectedBay ? MallmatePalette.greenDark : MallmatePalette.ink)
                                .background(bay == selectedBay ? MallmatePalette.green.opacity(0.52) : MallmatePalette.paper, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(bay == selectedBay ? MallmatePalette.greenDark.opacity(0.35) : MallmatePalette.line, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if let selectedBay {
                        Button {
                            model.savedCarBay = selectedBay
                        } label: {
                            Label("Save bay \(selectedBay)", systemImage: "bookmark.fill")
                                .font(.system(size: 12, weight: .bold))
                                .frame(maxWidth: .infinity).padding(13)
                                .foregroundStyle(MallmatePalette.ink)
                                .background(MallmatePalette.green, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    } else if let savedBay = model.savedCarBay {
                        Label("Saved: \(savedBay)", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 11, weight: .semibold)).foregroundStyle(MallmatePalette.greenDark)
                    }
                }
                .padding(15)
                .background(.white, in: RoundedRectangle(cornerRadius: 17))

                HStack(alignment: .top, spacing: 9) {
                    Image(systemName: "info.circle").foregroundStyle(MallmatePalette.greenDark)
                    Text("This is a sample parking layout. A live version needs the mall’s parking plan and the car’s saved bay.")
                        .font(.system(size: 10)).foregroundStyle(MallmatePalette.muted)
                }
            }
            .padding(16)
        }
        .background(MallmatePalette.paper.ignoresSafeArea())
        .navigationTitle("Parking")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SavedPlacesScreen: View {
    @EnvironmentObject private var model: MallmateModel
    let onShowMap: () -> Void

    var body: some View {
        Group {
            if model.favoriteStores.isEmpty {
                ContentUnavailableView("No saved places yet", systemImage: "heart", description: Text("Tap the heart beside a store to keep it here."))
            } else {
                List(model.favoriteStores) { store in
                    StoreRow(store: store, isFavorite: true, favoriteTap: { model.toggleFavorite(store) }) {
                        model.choose(store)
                        onShowMap()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(MallmatePalette.paper.ignoresSafeArea())
        .navigationTitle("Saved places")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StoreRow: View {
    let store: StoreEntry
    let isFavorite: Bool
    let favoriteTap: () -> Void
    let select: () -> Void

    var body: some View {
        HStack(spacing: 9) {
            Button(action: select) {
                HStack(spacing: 11) {
                    Text(String(store.name.prefix(1)))
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(MallmatePalette.greenDark)
                        .frame(width: 37, height: 37)
                        .background(MallmatePalette.green.opacity(0.35), in: RoundedRectangle(cornerRadius: 11))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.name).font(.system(size: 12, weight: .semibold)).foregroundStyle(MallmatePalette.ink)
                        Text(store.floor).font(.system(size: 10)).foregroundStyle(MallmatePalette.muted)
                    }
                    Spacer(minLength: 1)
                    Image(systemName: "arrow.up.right").font(.system(size: 10, weight: .bold)).foregroundStyle(MallmatePalette.muted)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Button(action: favoriteTap) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isFavorite ? MallmatePalette.coral : MallmatePalette.muted)
                    .frame(width: 31, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavorite ? "Remove saved place" : "Save place")
        }
        .padding(9)
        .background(.white, in: RoundedRectangle(cornerRadius: 13))
    }
}

struct MapModeButton: View {
    let title: String
    let icon: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 12).padding(.vertical, 8)
                .foregroundStyle(selected ? MallmatePalette.ink : MallmatePalette.muted)
                .background(selected ? MallmatePalette.green : MallmatePalette.paper, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct RoutePreviewCard: View {
    let title: String
    let subtitle: String
    let isNavigating: Bool
    let start: () -> Void
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                .font(.system(size: 18)).foregroundStyle(MallmatePalette.coral)
            VStack(alignment: .leading, spacing: 3) {
                Text("Route to \(title)").font(.system(size: 11, weight: .bold)).lineLimit(1)
                Text(isNavigating ? "Demo directions are active" : subtitle).font(.system(size: 9)).foregroundStyle(MallmatePalette.muted).lineLimit(2)
            }
            Spacer(minLength: 0)
            Button(isNavigating ? "End" : "Start") { start() }
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 11).padding(.vertical, 8)
                .foregroundStyle(.white).background(MallmatePalette.ink, in: Capsule())
            Button(action: dismiss) {
                Image(systemName: "xmark").font(.system(size: 10, weight: .bold)).foregroundStyle(MallmatePalette.muted)
            }
            .padding(.leading, 2)
            .accessibilityLabel("Clear route")
        }
        .padding(11)
        .background(MallmatePalette.paper, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct FloorFilterChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title).font(.system(size: 9, weight: .semibold))
                .padding(.horizontal, 10).padding(.vertical, 7)
                .foregroundStyle(selected ? MallmatePalette.greenDark : MallmatePalette.muted)
                .background(selected ? MallmatePalette.green.opacity(0.42) : .white, in: Capsule())
                .overlay(Capsule().stroke(selected ? MallmatePalette.greenDark.opacity(0.22) : MallmatePalette.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct ParkingSchematic: View {
    let savedBay: String?

    private let bays = ["A-108", "A-109", "A-120", "A-127", "A-134", "B-147", "B-167", "B-181", "C-301", "C-341"]
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.91, green: 0.90, blue: 0.85))
            VStack(spacing: 12) {
                HStack(spacing: 4) { Image(systemName: "building.2"); Text("MALL LOBBY") }
                    .font(.system(size: 8, weight: .heavy)).padding(.horizontal, 10).padding(.vertical, 6)
                    .foregroundStyle(.white).background(MallmatePalette.ink, in: Capsule())
                LazyVGrid(columns: columns, spacing: 11) {
                    ForEach(bays, id: \.self) { bay in
                        VStack(spacing: 2) {
                            Image(systemName: bay == savedBay ? "car.fill" : "parkingsign.circle")
                                .font(.system(size: 13, weight: .medium))
                            Text(bay).font(.system(size: 7, weight: .bold))
                        }
                        .foregroundStyle(bay == savedBay ? MallmatePalette.greenDark : MallmatePalette.muted)
                        .frame(maxWidth: .infinity).frame(height: 37)
                        .background(bay == savedBay ? MallmatePalette.green.opacity(0.6) : .white.opacity(0.8), in: RoundedRectangle(cornerRadius: 7))
                    }
                }
            }
            .padding(12)
            Path { path in
                path.move(to: CGPoint(x: 25, y: 150)); path.addLine(to: CGPoint(x: 25, y: 126)); path.addLine(to: CGPoint(x: 180, y: 126)); path.addLine(to: CGPoint(x: 225, y: 95))
            }
            .stroke(MallmatePalette.coral, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            .allowsHitTesting(false)
        }
    }
}

struct SectionTitle: View {
    let title: String
    var action: String? = nil
    var actionTap: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title).font(.system(size: 14, weight: .bold))
            Spacer()
            if let action {
                Button(action) { actionTap?() }.font(.system(size: 9, weight: .bold)).foregroundStyle(MallmatePalette.greenDark)
            }
        }
    }
}
