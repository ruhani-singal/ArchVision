// ================================================================
// ArchVision — Complete App (Fixed)
// Paste this ENTIRE file into your ContentView.swift
// Your MyApp.swift stays exactly as Xcode created it (untouched)
// Requires: iOS 16+, Xcode 15+
// Add to Info.plist: NSCameraUsageDescription (any string)
// ================================================================

import SwiftUI
import ARKit
import RealityKit
import Combine

// ================================================================
// MARK: — MODELS
// ================================================================

enum AppScreen { case onboarding, roomSetup, designCanvas, arPreview, suggestions }
enum RoomMode  { case scan, blank }

final class AppState: ObservableObject {
    @Published var screen: AppScreen = .onboarding
    func go(_ s: AppScreen) { withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { screen = s } }
}

enum FurnitureCategory: String, CaseIterable, Identifiable {
    case all="All", seating="Seating", tables="Tables", storage="Storage"
    case lighting="Lighting", decor="Decor", beds="Beds"
    var id: String { rawValue }
    var sfIcon: String {
        switch self {
        case .all:      return "square.grid.2x2"
        case .seating:  return "chair"
        case .tables:   return "rectangle.portrait"
        case .storage:  return "cabinet"
        case .lighting: return "lightbulb"
        case .decor:    return "paintpalette"
        case .beds:     return "bed.double"
        }
    }
}

enum MaterialKind: String, CaseIterable {
    case wood="Wood", metal="Metal", fabric="Fabric", glass="Glass", marble="Marble", leather="Leather"
    var uiColor: UIColor {
        switch self {
        case .wood:    return UIColor(red:0.6,  green:0.4,  blue:0.2,  alpha:1)
        case .metal:   return UIColor(red:0.7,  green:0.7,  blue:0.75, alpha:1)
        case .fabric:  return UIColor(red:0.4,  green:0.5,  blue:0.6,  alpha:1)
        case .glass:   return UIColor(red:0.7,  green:0.85, blue:0.95, alpha:0.7)
        case .marble:  return UIColor(red:0.92, green:0.9,  blue:0.88, alpha:1)
        case .leather: return UIColor(red:0.45, green:0.28, blue:0.15, alpha:1)
        }
    }
    var color: Color { Color(uiColor) }
    var roughness: Float {
        switch self {
        case .wood:    return 0.8
        case .metal:   return 0.3
        case .fabric:  return 0.95
        case .glass:   return 0.05
        case .marble:  return 0.2
        case .leather: return 0.6
        }
    }
    var metallic: Float {
        switch self {
        case .metal:   return 0.9
        case .glass:   return 0.1
        case .marble:  return 0.1
        default:       return 0.0
        }
    }
}

enum FloorKind: String, CaseIterable {
    case hardwood="Hardwood", marble="Marble", concrete="Concrete", carpet="Carpet", tile="Tile"
    var emoji: String {
        switch self {
        case .hardwood: return "🪵"
        case .marble:   return "⬜"
        case .concrete: return "🔲"
        case .carpet:   return "🟫"
        case .tile:     return "🔷"
        }
    }
    var color: Color {
        switch self {
        case .hardwood: return Color(red:0.6,  green:0.4,  blue:0.25)
        case .marble:   return Color(red:0.9,  green:0.88, blue:0.86)
        case .concrete: return Color(red:0.55, green:0.55, blue:0.57)
        case .carpet:   return Color(red:0.45, green:0.38, blue:0.35)
        case .tile:     return Color(red:0.8,  green:0.82, blue:0.85)
        }
    }
}

enum LightPreset: String, CaseIterable {
    case natural="Natural", warm="Warm", cool="Cool", dramatic="Dramatic", studio="Studio"
    var sfIcon: String {
        switch self {
        case .natural:  return "sun.max"
        case .warm:     return "flame"
        case .cool:     return "snowflake"
        case .dramatic: return "moon.stars"
        case .studio:   return "spotlight"
        }
    }
    var tint: Color {
        switch self {
        case .natural:  return Color(red:1.0, green:0.98, blue:0.92)
        case .warm:     return Color(red:1.0, green:0.85, blue:0.6)
        case .cool:     return Color(red:0.8, green:0.9,  blue:1.0)
        case .dramatic: return Color(red:0.3, green:0.2,  blue:0.5)
        case .studio:   return Color(red:0.95,green:0.95, blue:1.0)
        }
    }
}

enum DesignTheme: String, CaseIterable, Identifiable {
    case modern="Modern", minimalist="Minimalist", scandinavian="Scandinavian"
    case industrial="Industrial", bohemian="Bohemian", japandi="Japandi"
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .modern:       return "🏙"
        case .minimalist:   return "◻️"
        case .scandinavian: return "🌿"
        case .industrial:   return "⚙️"
        case .bohemian:     return "🌺"
        case .japandi:      return "🎋"
        }
    }
    var detail: String {
        switch self {
        case .modern:        return "Clean lines, bold accents, contemporary materials"
        case .minimalist:    return "Less is more. Purposeful, calm, uncluttered"
        case .scandinavian:  return "Functional beauty, natural tones, cozy warmth"
        case .industrial:    return "Raw textures, exposed elements, urban edge"
        case .bohemian:      return "Layered patterns, eclectic mix, global soul"
        case .japandi:       return "Japanese-Scandi fusion. Serene, natural, refined"
        }
    }
    var accent: Color {
        switch self {
        case .modern:       return Color(red:0.2, green:0.6, blue:0.9)
        case .minimalist:   return Color(red:0.8, green:0.8, blue:0.8)
        case .scandinavian: return Color(red:0.6, green:0.8, blue:0.65)
        case .industrial:   return Color(red:0.7, green:0.5, blue:0.35)
        case .bohemian:     return Color(red:0.85,green:0.5, blue:0.35)
        case .japandi:      return Color(red:0.55,green:0.65,blue:0.55)
        }
    }
    var wallColor: Color {
        switch self {
        case .modern:       return Color(red:0.95,green:0.95,blue:0.97)
        case .minimalist:   return Color(red:0.98,green:0.98,blue:0.98)
        case .scandinavian: return Color(red:0.96,green:0.94,blue:0.9)
        case .industrial:   return Color(red:0.72,green:0.7, blue:0.68)
        case .bohemian:     return Color(red:0.92,green:0.86,blue:0.78)
        case .japandi:      return Color(red:0.93,green:0.91,blue:0.87)
        }
    }
    var floor: FloorKind {
        switch self {
        case .modern:       return .concrete
        case .minimalist:   return .marble
        case .scandinavian: return .hardwood
        case .industrial:   return .concrete
        case .bohemian:     return .hardwood
        case .japandi:      return .hardwood
        }
    }
    var light: LightPreset {
        switch self {
        case .modern:       return .studio
        case .minimalist:   return .natural
        case .scandinavian: return .warm
        case .industrial:   return .dramatic
        case .bohemian:     return .warm
        case .japandi:      return .natural
        }
    }
}

struct FurnitureItem: Identifiable, Equatable {
    let id = UUID()
    var name: String; var category: FurnitureCategory; var emoji: String
    var color: Color; var position: SIMD3<Float>; var scale: Float; var rotation: Float
    var width: Float; var height: Float; var depth: Float
    var material: MaterialKind; var price: Double
    var isSelected: Bool = false
    static func ==(l: FurnitureItem, r: FurnitureItem) -> Bool { l.id == r.id }

    static let catalog: [FurnitureItem] = [
        .make("Sofa",         .seating, "🛋",  c:.gray,  w:2.2,h:0.85,d:0.9,  m:.fabric,  p:1299),
        .make("Armchair",     .seating, "🪑",  c:.brown, w:0.85,h:0.9,d:0.85, m:.leather, p:599),
        .make("Office Chair", .seating, "💺",  c:.black, w:0.65,h:1.2,d:0.65, m:.fabric,  p:399),
        .make("Bar Stool",    .seating, "🪑",  c:.white, w:0.4, h:0.75,d:0.4, m:.metal,   p:199),
        .make("Bench",        .seating, "🪑",  c:.brown, w:1.4, h:0.45,d:0.4, m:.wood,    p:349),
        .make("Dining Table", .tables,  "🍽",  c:.brown, w:1.8, h:0.75,d:0.9, m:.wood,    p:899),
        .make("Coffee Table", .tables,  "🔲",  c:.black, w:1.2, h:0.4, d:0.6, m:.glass,   p:449),
        .make("Desk",         .tables,  "🖥",  c:.white, w:1.6, h:0.75,d:0.7, m:.wood,    p:599),
        .make("Side Table",   .tables,  "◽",  c:.white, w:0.5, h:0.55,d:0.5, m:.marble,  p:249),
        .make("Bookshelf",    .storage, "📚",  c:.brown, w:1.0, h:1.8, d:0.3, m:.wood,    p:499),
        .make("Wardrobe",     .storage, "🚪",  c:.white, w:1.6, h:2.0, d:0.6, m:.wood,    p:1199),
        .make("TV Cabinet",   .storage, "📺",  c:.gray,  w:1.8, h:0.5, d:0.4, m:.wood,    p:699),
        .make("Floor Lamp",   .lighting,"💡",  c:.yellow,w:0.4, h:1.6, d:0.4, m:.metal,   p:199),
        .make("Table Lamp",   .lighting,"🔦",  c:.yellow,w:0.3, h:0.5, d:0.3, m:.glass,   p:99),
        .make("Plant (L)",    .decor,   "🌿",  c:.green, w:0.6, h:1.5, d:0.6, m:.fabric,  p:129),
        .make("Plant (S)",    .decor,   "🌱",  c:.green, w:0.3, h:0.4, d:0.3, m:.fabric,  p:39),
        .make("Rug",          .decor,   "🟥",  c:.red,   w:2.4, h:0.02,d:1.7, m:.fabric,  p:299),
        .make("Wall Mirror",  .decor,   "🪞",  c:.white, w:0.8, h:1.4, d:0.05,m:.glass,   p:249),
        .make("King Bed",     .beds,    "🛏",  c:.white, w:2.0, h:0.55,d:2.1, m:.fabric,  p:1599),
        .make("Queen Bed",    .beds,    "🛏",  c:.gray,  w:1.6, h:0.55,d:2.1, m:.fabric,  p:1199),
        .make("Nightstand",   .beds,    "◽",  c:.white, w:0.5, h:0.55,d:0.4, m:.wood,    p:199),
    ]

    static func make(_ name: String, _ cat: FurnitureCategory, _ emoji: String,
                     c: Color, w: Float, h: Float, d: Float,
                     m: MaterialKind, p: Double) -> FurnitureItem {
        FurnitureItem(name:name, category:cat, emoji:emoji, color:c,
                      position:.zero, scale:1, rotation:0, width:w, height:h, depth:d,
                      material:m, price:p)
    }
}

// ================================================================
// MARK: — VIEW MODEL
// ================================================================

@MainActor
final class DesignVM: ObservableObject {
    @Published var items: [FurnitureItem] = []
    @Published var selected: FurnitureItem? = nil
    @Published var roomW: Float = 5; @Published var roomL: Float = 4; @Published var roomH: Float = 2.7
    @Published var floor: FloorKind = .hardwood
    @Published var wallColor: Color = Color(red:0.95,green:0.93,blue:0.9)
    @Published var light: LightPreset = .natural
    @Published var filterCat: FurnitureCategory = .all
    @Published var viewMode: ViewMode = .perspective
    @Published var showGrid = true; @Published var showDims = true
    @Published var canvasScale: CGFloat = 1.0
    @Published var budget: Double = 0
    @Published var toast: String = ""; @Published var showToast = false
    @Published var undoStack: [[FurnitureItem]] = []
    let ppm: CGFloat = 60

    enum ViewMode: String, CaseIterable { case perspective="3D View", topDown="Top View", elevation="Elevation" }

    var filtered: [FurnitureItem] { filterCat == .all ? FurnitureItem.catalog : FurnitureItem.catalog.filter { $0.category == filterCat } }

    func add(_ tmpl: FurnitureItem) {
        saveUndo()
        var obj = tmpl
        obj.position = SIMD3<Float>(Float.random(in: -0.8...0.8), 0, Float.random(in: -0.8...0.8))
        items.append(obj)
        select(obj); calcBudget(); popup("✦ \(obj.name) added"); haptic(.medium)
    }
    func remove(_ obj: FurnitureItem) {
        saveUndo(); items.removeAll { $0.id == obj.id }
        if selected?.id == obj.id { selected = nil }; calcBudget(); haptic(.light)
    }
    func select(_ obj: FurnitureItem) {
        for i in items.indices { items[i].isSelected = false }
        if let i = items.firstIndex(where: { $0.id == obj.id }) { items[i].isSelected = true; selected = items[i] }
        hapticSel()
    }
    func deselect() { for i in items.indices { items[i].isSelected = false }; selected = nil }
    func rotate(_ deg: Float) {
        guard let s = selected, let i = items.firstIndex(where:{$0.id==s.id}) else { return }
        items[i].rotation += deg; selected = items[i]; haptic(.light)
    }
    func move(_ obj: FurnitureItem, dx: Float, dz: Float) {
        guard let i = items.firstIndex(where:{$0.id==obj.id}) else { return }
        items[i].position.x += dx; items[i].position.z += dz
        if selected?.id == obj.id { selected = items[i] }
    }
    func setMaterial(_ m: MaterialKind) {
        guard let s = selected, let i = items.firstIndex(where:{$0.id==s.id}) else { return }
        items[i].material = m; selected = items[i]; haptic(.light)
    }
    func applyTheme(_ t: DesignTheme) {
        saveUndo(); wallColor = t.wallColor; floor = t.floor; light = t.light
        for i in items.indices { items[i].color = t.accent }
        popup("🎨 \(t.rawValue) applied"); haptic(.medium)
    }
    func autoArrange() {
        saveUndo()
        var x: Float = -(roomW/2)+0.6; var z: Float = -(roomL/2)+0.6; var rowZ: Float = z
        for i in items.indices {
            if x + items[i].width > (roomW/2)-0.3 { x = -(roomW/2)+0.6; z = rowZ+1.4 }
            items[i].position = SIMD3<Float>(x + items[i].width/2, 0, z + items[i].depth/2)
            x += items[i].width + 0.3; rowZ = max(rowZ, z + items[i].depth)
        }
        popup("✦ Auto-arranged"); haptic(.medium)
    }
    func saveUndo() { undoStack.append(items); if undoStack.count > 20 { undoStack.removeFirst() } }
    func undo() { guard !undoStack.isEmpty else { return }; items = undoStack.removeLast(); calcBudget(); haptic(.medium); popup("↩ Undo") }
    var canUndo: Bool { !undoStack.isEmpty }
    func calcBudget() { budget = items.reduce(0) { $0 + $1.price } }
    func popup(_ msg: String) {
        toast = msg; withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline:.now()+2.5) { withAnimation { self.showToast = false } }
    }
    func haptic(_ s: UIImpactFeedbackGenerator.FeedbackStyle) { UIImpactFeedbackGenerator(style:s).impactOccurred() }
    func hapticSel() { UISelectionFeedbackGenerator().selectionChanged() }
    func hapticNote(_ t: UINotificationFeedbackGenerator.FeedbackType) { UINotificationFeedbackGenerator().notificationOccurred(t) }
}

// ================================================================
// MARK: — ROOT / NAVIGATION
// ================================================================

struct ContentView: View {
    @StateObject var app = AppState()
    @StateObject var vm  = DesignVM()
    var body: some View {
        ZStack {
            switch app.screen {
            case .onboarding:   OnboardingView().transition(.opacity)
            case .roomSetup:    RoomSetupView().transition(.asymmetric(insertion:.move(edge:.trailing),removal:.move(edge:.leading)))
            case .designCanvas: DesignCanvasView().transition(.asymmetric(insertion:.move(edge:.trailing),removal:.move(edge:.leading)))
            case .suggestions:  SuggestionView().transition(.asymmetric(insertion:.move(edge:.trailing),removal:.move(edge:.trailing)))
            case .arPreview:    ARPreviewWrap().transition(.asymmetric(insertion:.move(edge:.bottom),removal:.move(edge:.bottom)))
            }
        }
        .environmentObject(app)
        .environmentObject(vm)
        .preferredColorScheme(.dark)
        .animation(.spring(response:0.5,dampingFraction:0.85), value: app.screen)
    }
}

// ================================================================
// MARK: — SCREEN 1: ONBOARDING
// ================================================================

// Break out the feature card row to help the compiler
private struct FeatureCardRow: View {
    let emoji: String
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 18) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 60, height: 60)
                .background(Color.white.opacity(0.08))
                .cornerRadius(16)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 17, weight: .bold))
                Text(subtitle).font(.system(size: 13)).foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

struct OnboardingView: View {
    @EnvironmentObject var app: AppState
    @State private var glow = false
    @State private var cubeRot: Double = 0
    @State private var show = false
    @State private var featIdx = 0

    let feats: [(String, String, String)] = [
        ("🏗","Design in 3D","Place furniture in real-scale virtual rooms"),
        ("📐","Measure Everything","Real dimensions and real spatial reasoning"),
        ("✨","AR Preview","Walk your design in augmented reality"),
        ("🎨","Smart Themes","Apply design styles with one tap")
    ]

    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    private var purpleAccent: Color { Color(red: 0.5, green: 0.2, blue: 1) }
    private var purpleFade: Color   { Color(red: 0.3, green: 0.5, blue: 1) }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            bgGradient
            GridBG().opacity(0.04).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                cubeSection
                Spacer().frame(height: 28)
                titleSection
                Spacer().frame(height: 44)
                featureSection
                Spacer().frame(height: 44)
                ctaSection
                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response:1.1,dampingFraction:0.7).delay(0.1)) { show = true }
            withAnimation(.easeInOut(duration:3).repeatForever(autoreverses:true)) { glow = true }
            withAnimation(.linear(duration:18).repeatForever(autoreverses:false)) { cubeRot = 360 }
        }
        .onReceive(timer) { _ in
            withAnimation { featIdx = (featIdx + 1) % feats.count }
        }
    }

    private var bgGradient: some View {
        RadialGradient(
            colors: [Color(red:0.15,green:0.05,blue:0.35).opacity(glow ? 0.85 : 0.4), .black],
            center: .center, startRadius: 0, endRadius: 340
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration:3).repeatForever(autoreverses:true), value: glow)
    }

    private var cubeSection: some View {
        ZStack {
            ringCircle(index: 0)
            ringCircle(index: 1)
            ringCircle(index: 2)
            ringCircle(index: 3)
            CubeWire(rot: cubeRot).frame(width: 150, height: 150)
        }
        .frame(height: 230)
        .opacity(show ? 1 : 0)
        .scaleEffect(show ? 1 : 0.6)
    }

    private func ringCircle(index i: Int) -> some View {
        let size = CGFloat(180 + i * 70)
        let opacity = 0.12 - Double(i) * 0.02
        return Circle()
            .stroke(Color(red:0.5,green:0.2,blue:1).opacity(opacity), lineWidth: 1)
            .frame(width: size, height: size)
    }

    private var titleSection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                Text("Arch").font(.system(size: 50, weight: .black))
                Text("Vision")
                    .font(.system(size: 50, weight: .black))
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red:0.7,green:0.4,blue:1), Color(red:0.4,green:0.7,blue:1)],
                        startPoint: .leading, endPoint: .trailing
                    ))
            }
            Text("DESIGN BEFORE YOU BUILD")
                .font(.system(size:12, weight:.semibold, design:.monospaced))
                .foregroundColor(.white.opacity(0.4))
                .tracking(5)
        }
        .opacity(show ? 1 : 0)
        .offset(y: show ? 0 : 30)
    }

    private var featureSection: some View {
        VStack(spacing: 10) {
            ZStack {
                ForEach(feats.indices, id: \.self) { i in
                    FeatureCardRow(emoji: feats[i].0, title: feats[i].1, subtitle: feats[i].2)
                        .opacity(featIdx == i ? 1 : 0)
                        .offset(y: featIdx == i ? 0 : 16)
                        .animation(.spring(response:0.5,dampingFraction:0.8), value: featIdx)
                }
            }
            .frame(height: 80)

            HStack(spacing: 7) {
                ForEach(feats.indices, id: \.self) { i in
                    Capsule()
                        .fill(featIdx == i ? Color(red:0.6,green:0.35,blue:1) : Color.white.opacity(0.2))
                        .frame(width: featIdx == i ? 22 : 6, height: 6)
                        .animation(.spring(response:0.4), value: featIdx)
                }
            }
        }
        .opacity(show ? 1 : 0)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button { app.go(.roomSetup) } label: {
                HStack {
                    Text("Start Designing").font(.system(size:17, weight:.bold))
                    Image(systemName:"arrow.right").font(.system(size:15, weight:.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(LinearGradient(
                    colors: [purpleAccent, purpleFade],
                    startPoint: .leading, endPoint: .trailing
                ))
                .cornerRadius(16)
                .shadow(color: Color(red:0.4,green:0.2,blue:0.9).opacity(0.5), radius:20, y:8)
            }

            Button { app.go(.designCanvas) } label: {
                Text("View Demo")
                    .font(.system(size:16, weight:.medium))
                    .foregroundColor(.white.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius:16).stroke(Color.white.opacity(0.08), lineWidth:1))
            }
        }
        .padding(.horizontal, 28)
        .opacity(show ? 1 : 0)
    }
}

// Break CubeWire into a helper for each layer
private struct CubeLayer: View {
    let index: Int
    let rot: Double
    var body: some View {
        let grad = LinearGradient(
            colors: [
                Color(red:0.7,green:0.4,blue:1).opacity(0.7),
                Color(red:0.4,green:0.6,blue:1).opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        return RoundedRectangle(cornerRadius: 4)
            .stroke(grad, lineWidth: 1.5)
            .frame(width: 88, height: 88)
            .rotationEffect(.degrees(Double(index) * 15 + rot))
            .scaleEffect(1 - Double(index) * 0.08)
            .opacity(1 - Double(index) * 0.1)
    }
}

struct CubeWire: View {
    var rot: Double
    var body: some View {
        ZStack {
            CubeLayer(index: 0, rot: rot)
            CubeLayer(index: 1, rot: rot)
            CubeLayer(index: 2, rot: rot)
            CubeLayer(index: 3, rot: rot)
            CubeLayer(index: 4, rot: rot)
            CubeLayer(index: 5, rot: rot)
            Circle()
                .fill(Color(red:0.7,green:0.4,blue:1))
                .frame(width: 8, height: 8)
                .shadow(color: Color(red:0.5,green:0.2,blue:1), radius: 12)
        }
        .animation(.linear(duration:18).repeatForever(autoreverses:false), value: rot)
    }
}

struct GridBG: View {
    var body: some View {
        GeometryReader { g in
            let cols = Int(g.size.width/44)+1
            let rows = Int(g.size.height/44)+1
            ZStack {
                ForEach(0..<cols, id:\.self) { c in
                    Rectangle().fill(Color.white).frame(width:1)
                        .frame(maxHeight:.infinity)
                        .offset(x: CGFloat(c)*44 - g.size.width/2)
                }
                ForEach(0..<rows, id:\.self) { r in
                    Rectangle().fill(Color.white).frame(height:1)
                        .frame(maxWidth:.infinity)
                        .offset(y: CGFloat(r)*44 - g.size.height/2)
                }
            }
        }
    }
}

// ================================================================
// MARK: — SCREEN 2: ROOM SETUP
// ================================================================

struct RoomSetupView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var vm: DesignVM
    @State private var step = 0
    @State private var roomName = "My Living Room"

    let wallColors: [Color] = [
        Color(red:0.98,green:0.98,blue:0.98), Color(red:0.95,green:0.93,blue:0.9),
        Color(red:0.88,green:0.92,blue:0.95), Color(red:0.92,green:0.95,blue:0.88),
        Color(red:0.95,green:0.88,blue:0.88), Color(red:0.88,green:0.85,blue:0.95),
        Color(red:0.72,green:0.7, blue:0.68), Color(red:0.2, green:0.2, blue:0.22)
    ]

    var body: some View {
        ZStack {
            Color(red:0.06,green:0.06,blue:0.1).ignoresSafeArea()
            LinearGradient(colors:[Color(red:0.12,green:0.05,blue:0.25).opacity(0.5),.clear],startPoint:.top,endPoint:.center).ignoresSafeArea()

            VStack(spacing:0) {
                headerBar
                progressBar
                stepTabs
                ScrollView(showsIndicators:false) {
                    VStack(spacing:18) {
                        if step == 0      { step0Content }
                        else if step == 1 { step1Content }
                        else              { step2Content }
                    }
                    .padding(.horizontal,20).padding(.bottom,120)
                }
            }

            bottomCTA
        }
    }

    private var headerBar: some View {
        HStack {
            BackBtn { app.go(.onboarding) }
            Spacer()
            Text("New Space").font(.system(size:18,weight:.bold))
            Spacer()
            Text("\(step+1)/3")
                .font(.system(size:13,weight:.semibold,design:.monospaced))
                .foregroundColor(.white.opacity(0.4))
                .frame(width:40)
        }
        .padding(.horizontal,20).padding(.top,16).padding(.bottom,10)
    }

    private var progressBar: some View {
        HStack(spacing:6) {
            ForEach(0..<3, id:\.self) { i in
                Capsule()
                    .fill(i <= step ? Color(red:0.5,green:0.25,blue:1) : Color.white.opacity(0.12))
                    .frame(maxWidth:.infinity).frame(height:4)
                    .animation(.spring(response:0.4), value:step)
            }
        }
        .padding(.horizontal,20).padding(.bottom,20)
    }

    private var stepTabs: some View {
        let labels = ["Basics","Dimensions","Style"]
        let icons  = ["house","ruler","paintpalette"]
        return HStack(spacing:0) {
            ForEach(0..<3, id:\.self) { idx in
                Button {
                    withAnimation(.spring(response:0.4)) { step = idx }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack(spacing:5) {
                        Image(systemName: icons[idx]).font(.system(size:12))
                        Text(labels[idx]).font(.system(size:13,weight:.medium))
                    }
                    .foregroundColor(step == idx ? .white : .white.opacity(0.4))
                    .padding(.vertical,10)
                    .frame(maxWidth:.infinity)
                }
            }
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal,20).padding(.bottom,20)
    }

    // MARK: Step 0 – Basics
    private var step0Content: some View {
        VStack(spacing:18) {
            SetupCard2(title:"Room Name", icon:"textformat") {
                TextField("Room name", text:$roomName)
                    .font(.system(size:20,weight:.bold)).foregroundColor(.white)
                    .padding(14).background(Color.white.opacity(0.06)).cornerRadius(12)
            }
            SetupCard2(title:"Wall Color", icon:"paintbrush") {
                LazyVGrid(columns:Array(repeating:.init(.flexible()),count:8),spacing:10) {
                    ForEach(wallColors.indices, id:\.self) { i in
                        wallColorButton(index: i)
                    }
                }
            }
            SetupCard2(title:"Flooring", icon:"square.grid.2x2") {
                VStack(spacing:7) {
                    ForEach(FloorKind.allCases, id:\.self) { f in
                        floorRow(f)
                    }
                }
            }
        }
    }

    private func wallColorButton(index i: Int) -> some View {
        Button {
            vm.wallColor = wallColors[i]
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            ZStack {
                Circle().fill(wallColors[i]).frame(width:36,height:36)
                if vm.wallColor == wallColors[i] {
                    Circle().stroke(Color(red:0.5,green:0.25,blue:1),lineWidth:3).frame(width:36,height:36)
                    Image(systemName:"checkmark").font(.system(size:11,weight:.bold)).foregroundColor(.black)
                }
            }
        }
    }

    private func floorRow(_ f: FloorKind) -> some View {
        Button {
            vm.floor = f
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            HStack(spacing:12) {
                Text(f.emoji).font(.system(size:22)).frame(width:42,height:42)
                    .background(f.color.opacity(0.3)).cornerRadius(10)
                Text(f.rawValue).font(.system(size:15,weight:.medium)).foregroundColor(.white)
                Spacer()
                if vm.floor == f {
                    Image(systemName:"checkmark.circle.fill")
                        .foregroundColor(Color(red:0.5,green:0.25,blue:1))
                        .font(.system(size:20))
                }
            }
            .padding(12)
            .background(vm.floor == f ? Color(red:0.5,green:0.25,blue:1).opacity(0.12) : Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }

    // MARK: Step 1 – Dimensions
    private var step1Content: some View {
        VStack(spacing:18) {
            SetupCard2(title:"Room Preview", icon:"rectangle.3d") {
                RoomPreview(w:vm.roomW, l:vm.roomL).frame(height:180)
            }
            SetupCard2(title:"Width", icon:"arrow.left.and.right") {
                DimSlider(label:"Width",
                          value:Binding(get:{Double(vm.roomW)},set:{vm.roomW=Float($0)}),
                          range:2...15, unit:"m")
            }
            SetupCard2(title:"Length", icon:"arrow.up.and.down") {
                DimSlider(label:"Length",
                          value:Binding(get:{Double(vm.roomL)},set:{vm.roomL=Float($0)}),
                          range:2...15, unit:"m")
            }
            SetupCard2(title:"Ceiling Height", icon:"rectangle.expand.vertical") {
                DimSlider(label:"Height",
                          value:Binding(get:{Double(vm.roomH)},set:{vm.roomH=Float($0)}),
                          range:2.2...5, unit:"m")
            }
            areaDisplay
        }
    }

    private var areaDisplay: some View {
        HStack {
            Spacer()
            VStack(spacing:4) {
                Text("\(String(format:"%.1f", vm.roomW*vm.roomL)) m²")
                    .font(.system(size:34,weight:.black,design:.monospaced))
                    .foregroundStyle(LinearGradient(
                        colors:[Color(red:0.6,green:0.35,blue:1),Color(red:0.35,green:0.6,blue:1)],
                        startPoint:.leading, endPoint:.trailing
                    ))
                Text("Total Floor Area").font(.system(size:13)).foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(22).background(Color.white.opacity(0.04)).cornerRadius(16)
    }

    // MARK: Step 2 – Style
    private var step2Content: some View {
        VStack(spacing:12) {
            Text("Choose a style to pre-configure your room:")
                .font(.system(size:13)).foregroundColor(.white.opacity(0.5))
            ForEach(DesignTheme.allCases) { t in
                themeRow(t)
            }
        }
    }

    private func themeRow(_ t: DesignTheme) -> some View {
        Button { UISelectionFeedbackGenerator().selectionChanged() } label: {
            HStack(spacing:14) {
                Text(t.emoji).font(.system(size:28)).frame(width:54,height:54)
                    .background(t.accent.opacity(0.2)).cornerRadius(14)
                VStack(alignment:.leading,spacing:4) {
                    Text(t.rawValue).font(.system(size:16,weight:.bold)).foregroundColor(.white)
                    Text(t.detail).font(.system(size:12)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(14).background(Color.white.opacity(0.05)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius:16).stroke(Color.white.opacity(0.07),lineWidth:1))
        }
    }

    // MARK: Bottom CTA
    private var bottomCTA: some View {
        VStack {
            Spacer()
            VStack(spacing:0) {
                LinearGradient(colors:[.clear,Color(red:0.06,green:0.06,blue:0.1)],
                               startPoint:.top,endPoint:.bottom).frame(height:36)
                HStack(spacing:12) {
                    if step > 0 {
                        Button {
                            withAnimation(.spring(response:0.4)) { step -= 1 }
                        } label: {
                            Image(systemName:"chevron.left").font(.system(size:17,weight:.bold))
                                .frame(width:54,height:54)
                                .background(Color.white.opacity(0.08)).cornerRadius(16)
                                .foregroundColor(.white)
                        }
                    }
                    Button {
                        UIImpactFeedbackGenerator(style:.medium).impactOccurred()
                        if step == 2 { app.go(.designCanvas) }
                        else { withAnimation(.spring(response:0.4)) { step += 1 } }
                    } label: {
                        HStack {
                            Text(step == 2 ? "Start Designing" : "Continue")
                                .font(.system(size:17,weight:.bold))
                            Image(systemName: step == 2 ? "paintbrush.fill" : "arrow.right")
                        }
                        .frame(maxWidth:.infinity).frame(height:54)
                        .background(LinearGradient(
                            colors:[Color(red:0.5,green:0.2,blue:1),Color(red:0.3,green:0.5,blue:1)],
                            startPoint:.leading, endPoint:.trailing
                        ))
                        .cornerRadius(16).foregroundColor(.white)
                        .shadow(color:Color(red:0.4,green:0.2,blue:0.9).opacity(0.4),radius:16,y:6)
                    }
                }
                .padding(.horizontal,20).padding(.vertical,14)
                .background(Color(red:0.06,green:0.06,blue:0.1))
            }
        }
    }
}

struct SetupCard2<C:View>: View {
    let title:String; let icon:String; @ViewBuilder var content:C
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            HStack(spacing:7) {
                Image(systemName:icon).font(.system(size:13,weight:.semibold)).foregroundColor(Color(red:0.6,green:0.35,blue:1))
                Text(title.uppercased()).font(.system(size:11,weight:.semibold,design:.monospaced)).foregroundColor(.white.opacity(0.35)).tracking(1.5)
            }
            content
        }
        .padding(18).background(Color.white.opacity(0.04)).cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius:18).stroke(Color.white.opacity(0.06),lineWidth:1))
    }
}

struct DimSlider: View {
    let label:String; @Binding var value:Double; let range:ClosedRange<Double>; let unit:String
    var body: some View {
        VStack(spacing:8) {
            HStack {
                Text(label).font(.system(size:14)).foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("\(String(format:"%.1f",value))\(unit)").font(.system(size:20,weight:.black,design:.monospaced))
            }
            Slider(value:$value,in:range,step:0.1).tint(Color(red:0.5,green:0.25,blue:1))
        }
    }
}

struct RoomPreview: View {
    let w:Float; let l:Float
    var body: some View {
        GeometryReader { g in
            let aspect = CGFloat(w)/max(CGFloat(l),0.01)
            let maxW=g.size.width-32; let maxH=g.size.height-32
            let rw=min(maxW,maxH*aspect); let rh=rw/aspect
            ZStack {
                Color.white.opacity(0.04).cornerRadius(12)
                Rectangle()
                    .fill(Color(red:0.5,green:0.25,blue:1).opacity(0.12))
                    .frame(width:rw,height:rh)
                    .overlay(Rectangle().stroke(Color(red:0.5,green:0.25,blue:1).opacity(0.5),lineWidth:2))
                    .overlay(alignment:.bottom) {
                        Text("\(String(format:"%.1f",w))m")
                            .font(.system(size:10,design:.monospaced))
                            .foregroundColor(Color(red:0.6,green:0.35,blue:1))
                            .offset(y:16)
                    }
                    .overlay(alignment:.trailing) {
                        Text("\(String(format:"%.1f",l))m")
                            .font(.system(size:10,design:.monospaced))
                            .foregroundColor(Color(red:0.6,green:0.35,blue:1))
                            .rotationEffect(.degrees(90)).offset(x:18)
                    }
            }
        }
    }
}

// ================================================================
// MARK: — SCREEN 3: DESIGN CANVAS
// ================================================================

struct DesignCanvasView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var vm: DesignVM
    @State private var showCatalog = false
    @State private var showRoom = false
    @State private var showStats = false

    var body: some View {
        ZStack {
            Color(red:0.05,green:0.05,blue:0.08).ignoresSafeArea()
            VStack(spacing:0) {
                topBar
                viewModeBar
                canvasArea
                toolbar
            }

            if showCatalog { CatalogSheet(isPresented:$showCatalog).transition(.move(edge:.bottom).combined(with:.opacity)).zIndex(10) }
            if showRoom    { RoomSheet(isPresented:$showRoom).transition(.move(edge:.bottom).combined(with:.opacity)).zIndex(10) }
        }
        .animation(.spring(response:0.4,dampingFraction:0.85),value:showCatalog)
        .animation(.spring(response:0.4,dampingFraction:0.85),value:showRoom)
        .animation(.spring(response:0.4),value:vm.showToast)
        .animation(.spring(response:0.4),value:vm.selected?.id)
    }

    private var topBar: some View {
        HStack(spacing:10) {
            BackBtn { app.go(.roomSetup) }
            HStack(spacing:5) {
                Image(systemName:"house.fill").font(.system(size:11)).foregroundColor(Color(red:0.6,green:0.35,blue:1))
                Text("My Room").font(.system(size:15,weight:.bold))
            }
            Spacer()
            budgetBadge
            undoButton
            statsButton
            arButton
        }
        .padding(.horizontal,14).padding(.vertical,9)
        .background(Color(red:0.05,green:0.05,blue:0.08))
        .overlay(alignment:.bottom){ Rectangle().fill(Color.white.opacity(0.06)).frame(height:1) }
    }

    private var budgetBadge: some View {
        HStack(spacing:4) {
            Image(systemName:"dollarsign.circle.fill").font(.system(size:12)).foregroundColor(Color(red:0.3,green:0.9,blue:0.5))
            Text("$\(Int(vm.budget))").font(.system(size:13,weight:.bold,design:.monospaced))
        }
        .padding(.horizontal,11).padding(.vertical,6)
        .background(Color.white.opacity(0.08)).cornerRadius(20)
    }

    private var undoButton: some View {
        Button { vm.undo() } label: {
            Image(systemName:"arrow.uturn.backward").font(.system(size:14,weight:.semibold))
                .foregroundColor(vm.canUndo ? .white : .white.opacity(0.25))
                .frame(width:38,height:38).background(Color.white.opacity(0.08)).clipShape(Circle())
        }.disabled(!vm.canUndo)
    }

    private var statsButton: some View {
        Button { showStats.toggle() } label: {
            Image(systemName:"chart.bar.xaxis").font(.system(size:14))
                .foregroundColor(.white.opacity(0.7))
                .frame(width:38,height:38).background(Color.white.opacity(0.08)).clipShape(Circle())
        }
        .popover(isPresented:$showStats) { StatsView() }
    }

    private var arButton: some View {
        Button {
            UIImpactFeedbackGenerator(style:.heavy).impactOccurred()
            app.go(.arPreview)
        } label: {
            HStack(spacing:5) {
                Image(systemName:"arkit").font(.system(size:13,weight:.bold))
                Text("AR").font(.system(size:13,weight:.bold))
            }
            .padding(.horizontal,12).padding(.vertical,9)
            .background(LinearGradient(colors:[Color(red:0.5,green:0.2,blue:1),Color(red:0.3,green:0.5,blue:1)],startPoint:.leading,endPoint:.trailing))
            .cornerRadius(11).foregroundColor(.white)
        }
    }

    private var viewModeBar: some View {
        ScrollView(.horizontal,showsIndicators:false) {
            HStack(spacing:7) {
                ForEach(DesignVM.ViewMode.allCases,id:\.self) { m in
                    Button {
                        vm.viewMode = m
                        UIImpactFeedbackGenerator(style:.light).impactOccurred()
                    } label: {
                        Text(m.rawValue).font(.system(size:13,weight:.semibold))
                            .foregroundColor(vm.viewMode==m ? .white : .white.opacity(0.45))
                            .padding(.horizontal,14).padding(.vertical,8)
                            .background(vm.viewMode==m ? Color(red:0.5,green:0.25,blue:1).opacity(0.22) : Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius:10).stroke(vm.viewMode==m ? Color(red:0.5,green:0.25,blue:1).opacity(0.5) : Color.clear,lineWidth:1))
                    }
                }
                Spacer()
                Toggle("",isOn:$vm.showGrid).labelsHidden().tint(Color(red:0.5,green:0.25,blue:1))
                Text("Grid").font(.system(size:12)).foregroundColor(.white.opacity(0.45))
            }.padding(.horizontal,14).padding(.vertical,7)
        }.background(Color(red:0.06,green:0.06,blue:0.1))
    }

    private var canvasArea: some View {
        ZStack {
            switch vm.viewMode {
            case .perspective: PerspCanvas()
            case .topDown:     TopCanvas()
            case .elevation:   ElevCanvas()
            }
            if let sel = vm.selected {
                HStack { Spacer(); InspectorPanel(item:sel).transition(.move(edge:.trailing).combined(with:.opacity)) }
                    .animation(.spring(response:0.4),value:vm.selected?.id)
            }
            if vm.showToast {
                VStack{Spacer();Toast(msg:vm.toast).padding(.bottom,16)}.transition(.move(edge:.bottom))
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing:0) {
            TBar("plus.circle.fill","Add",Color(red:0.5,green:0.25,blue:1))   { showCatalog=true }
            TBar("house.circle","Room",Color(red:0.3,green:0.7,blue:1))        { showRoom=true }
            TBar("wand.and.stars","Themes",Color(red:1,green:0.6,blue:0.2))   { app.go(.suggestions) }
            TBar("arrow.triangle.2.circlepath","Arrange",Color(red:0.3,green:0.9,blue:0.5)) { vm.autoArrange() }
            TBar("square.and.arrow.up","Export",Color(red:0.9,green:0.4,blue:0.4)) { vm.popup("📤 Export coming soon") }
        }
        .padding(.vertical,6)
        .background(Color(red:0.05,green:0.05,blue:0.08))
        .overlay(alignment:.top){ Rectangle().fill(Color.white.opacity(0.06)).frame(height:1) }
    }
}

struct TBar: View {
    let icon:String; let label:String; let col:Color; let action:()->Void
    init(_ i:String,_ l:String,_ c:Color,_ a:@escaping()->Void){icon=i;label=l;col=c;action=a}
    var body: some View {
        Button { UIImpactFeedbackGenerator(style:.light).impactOccurred(); action() } label: {
            VStack(spacing:3) {
                Image(systemName:icon).font(.system(size:21)).foregroundColor(col)
                Text(label).font(.system(size:10,weight:.medium)).foregroundColor(.white.opacity(0.45))
            }.frame(maxWidth:.infinity).padding(.vertical,7)
        }
    }
}

// MARK: Perspective Canvas
struct PerspCanvas: View {
    @EnvironmentObject var vm: DesignVM
    @State private var camRot: Double = 35
    @State private var camEl: Double  = 30

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red:0.06,green:0.06,blue:0.1)
                Canvas { ctx,sz in drawRoom(ctx:ctx,sz:sz) }
                ForEach(vm.items) { obj in PerspObj(obj:obj,geo:geo,camRot:camRot,camEl:camEl) }
                Color.clear.contentShape(Rectangle()).onTapGesture { vm.deselect() }
                lightingBadge
                hintLabel
            }
            .gesture(DragGesture().onChanged { v in
                camRot += v.translation.width*0.3
                camEl = max(5,min(60,camEl - v.translation.height*0.2))
            })
        }
    }

    private var lightingBadge: some View {
        VStack {
            Spacer()
            HStack {
                Label(vm.light.rawValue, systemImage:vm.light.sfIcon)
                    .font(.system(size:12,weight:.medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal,12).padding(.vertical,6)
                    .background(Color.white.opacity(0.06)).cornerRadius(20)
                Spacer()
            }
            .padding(.horizontal,14).padding(.bottom,10)
        }
    }

    private var hintLabel: some View {
        VStack {
            HStack {
                Spacer()
                Text("Drag to orbit")
                    .font(.system(size:10,design:.monospaced))
                    .foregroundColor(.white.opacity(0.18))
                    .padding(10)
            }
            Spacer()
        }
    }

    func drawRoom(ctx:GraphicsContext,sz:CGSize) {
        let ppm: CGFloat = 52
        let rw=CGFloat(vm.roomW)*ppm; let rl=CGFloat(vm.roomL)*ppm; let rh=CGFloat(vm.roomH)*ppm*0.5
        let cx=sz.width/2; let cy=sz.height/2
        let a=camRot * .pi/180; let el=camEl * .pi/180
        let hw=rw/2; let hl=rl/2

        func proj(_ x:CGFloat,_ y:CGFloat,_ z:CGFloat)->CGPoint {
            let angle = CGFloat(a)
            let rx = x * cos(angle) - y * sin(angle)
            let ry = x * sin(angle) + y * cos(angle)
            return CGPoint(x:cx+rx, y:cy - z*sin(el) + ry*cos(el)*0.4)
        }

        var fl=Path()
        fl.move(to:proj(-hw,-hl,0)); fl.addLine(to:proj(hw,-hl,0))
        fl.addLine(to:proj(hw,hl,0)); fl.addLine(to:proj(-hw,hl,0))
        fl.closeSubpath()
        ctx.fill(fl, with:.color(vm.floor.color.opacity(0.35)))
        ctx.stroke(fl, with:.color(.white.opacity(0.07)),lineWidth:1)

        if vm.showGrid {
            var gx = -hw
            while gx <= hw {
                var ln=Path(); ln.move(to:proj(gx,-hl,0)); ln.addLine(to:proj(gx,hl,0))
                ctx.stroke(ln,with:.color(.white.opacity(0.04)),lineWidth:0.5); gx+=ppm
            }
            var gz = -hl
            while gz <= hl {
                var ln=Path(); ln.move(to:proj(-hw,gz,0)); ln.addLine(to:proj(hw,gz,0))
                ctx.stroke(ln,with:.color(.white.opacity(0.04)),lineWidth:0.5); gz+=ppm
            }
        }

        var lw=Path()
        lw.move(to:proj(-hw,-hl,0)); lw.addLine(to:proj(-hw,hl,0))
        lw.addLine(to:proj(-hw,hl,rh)); lw.addLine(to:proj(-hw,-hl,rh))
        lw.closeSubpath()
        ctx.fill(lw, with:.color(vm.wallColor.opacity(0.22)))
        ctx.stroke(lw, with:.color(.white.opacity(0.06)),lineWidth:1)

        var bw=Path()
        bw.move(to:proj(-hw,-hl,0)); bw.addLine(to:proj(hw,-hl,0))
        bw.addLine(to:proj(hw,-hl,rh)); bw.addLine(to:proj(-hw,-hl,rh))
        bw.closeSubpath()
        ctx.fill(bw, with:.color(vm.wallColor.opacity(0.3)))
        ctx.stroke(bw, with:.color(.white.opacity(0.06)),lineWidth:1)

        ctx.fill(
            Path(CGRect(origin:.zero,size:sz)),
            with:.radialGradient(
                Gradient(colors:[vm.light.tint.opacity(0.12),.clear]),
                center:proj(0,-hl*0.3,rh*0.8),
                startRadius:0,
                endRadius:max(rw,rl)*1.2
            )
        )
    }
}

struct PerspObj: View {
    @EnvironmentObject var vm: DesignVM
    let obj: FurnitureItem; let geo: GeometryProxy; let camRot:Double; let camEl:Double
    @State private var last:CGSize = .zero

    var screenPos: CGPoint {
        let ppm: CGFloat = 52
        let a  = CGFloat(camRot) * .pi / 180
        let el = CGFloat(camEl)  * .pi / 180
        let ox = CGFloat(obj.position.x) * ppm
        let oy = CGFloat(obj.position.z) * ppm
        let rx = ox * cos(a) - oy * sin(a)
        let ry = ox * sin(a) + oy * cos(a)
        return CGPoint(
            x: geo.size.width  / 2 + rx,
            y: geo.size.height / 2 + ry * cos(el) * 0.4
        )
    }

    var ow: CGFloat { max(CGFloat(obj.width)*52*0.72, 28) }
    var oh: CGFloat { max(CGFloat(obj.depth)*52*0.52, 18) }

    var body: some View {
        ZStack {
            Ellipse().fill(Color.black.opacity(0.25)).frame(width:ow*1.1,height:oh*0.38).offset(y:oh*0.38)
            objectBox
            if obj.isSelected { selectionHandles }
        }
        .rotationEffect(.degrees(Double(obj.rotation)))
        .position(screenPos)
        .onTapGesture { vm.select(obj) }
        .gesture(DragGesture().onChanged { v in
            let d = CGSize(width:v.translation.width-last.width, height:v.translation.height-last.height)
            last = v.translation
            vm.move(obj, dx:Float(d.width/52), dz:Float(d.height/52))
        }.onEnded { _ in last = .zero })
    }

    private var objectBox: some View {
        RoundedRectangle(cornerRadius:5)
            .fill(LinearGradient(colors:[obj.color.opacity(0.88),obj.color.opacity(0.55)],startPoint:.top,endPoint:.bottom))
            .frame(width:ow,height:oh)
            .overlay(RoundedRectangle(cornerRadius:5).stroke(
                obj.isSelected ? Color(red:0.5,green:0.25,blue:1) : Color.white.opacity(0.15),
                lineWidth: obj.isSelected ? 2.5 : 1
            ))
            .overlay(Text(obj.emoji).font(.system(size:min(ow,oh)*0.42)))
            .overlay(alignment:.bottom) {
                if vm.showDims {
                    Text("\(String(format:"%.1f",obj.width))×\(String(format:"%.1f",obj.depth))m")
                        .font(.system(size:8,design:.monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal,3).background(Color.black.opacity(0.4)).cornerRadius(3)
                        .offset(y:14)
                }
            }
    }

    private var selectionHandles: some View {
        ZStack {
            Circle().fill(Color(red:0.5,green:0.25,blue:1)).frame(width:9,height:9).offset(x:-ow/2, y:-oh/2)
            Circle().fill(Color(red:0.5,green:0.25,blue:1)).frame(width:9,height:9).offset(x: ow/2, y:-oh/2)
            Circle().fill(Color(red:0.5,green:0.25,blue:1)).frame(width:9,height:9).offset(x:-ow/2, y: oh/2)
            Circle().fill(Color(red:0.5,green:0.25,blue:1)).frame(width:9,height:9).offset(x: ow/2, y: oh/2)
        }
    }
}

// MARK: Top-Down Canvas
struct TopCanvas: View {
    @EnvironmentObject var vm: DesignVM
    var body: some View {
        GeometryReader { geo in
            let sc=vm.canvasScale; let ppm=vm.ppm*sc
            let rw=CGFloat(vm.roomW)*ppm; let rl=CGFloat(vm.roomL)*ppm
            ZStack {
                Color(red:0.06,green:0.07,blue:0.12)
                ScrollView([.horizontal,.vertical],showsIndicators:false) {
                    ZStack {
                        Rectangle().fill(vm.floor.color.opacity(0.3)).frame(width:rw,height:rl)
                            .overlay(Rectangle().stroke(Color.white.opacity(0.18),lineWidth:2))
                            .overlay(Canvas { ctx,sz in
                                if vm.showGrid {
                                    let st=ppm
                                    var x:CGFloat=0
                                    while x<=sz.width {
                                        var l=Path(); l.move(to:CGPoint(x:x,y:0)); l.addLine(to:CGPoint(x:x,y:sz.height))
                                        ctx.stroke(l,with:.color(.white.opacity(0.05)),lineWidth:0.5); x+=st
                                    }
                                    var y:CGFloat=0
                                    while y<=sz.height {
                                        var l=Path(); l.move(to:CGPoint(x:0,y:y)); l.addLine(to:CGPoint(x:sz.width,y:y))
                                        ctx.stroke(l,with:.color(.white.opacity(0.05)),lineWidth:0.5); y+=st
                                    }
                                }
                            })
                        ForEach(vm.items) { obj in TopObj(obj:obj) }
                    }
                    .frame(width:max(rw+80,geo.size.width),height:max(rl+80,geo.size.height))
                }
                zoomControls
            }
        }
    }

    private var zoomControls: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing:1) {
                    Button { withAnimation{vm.canvasScale=min(vm.canvasScale*1.25,3)} } label: {
                        Image(systemName:"plus").frame(width:34,height:34).background(Color.white.opacity(0.1)).foregroundColor(.white)
                    }
                    Button { withAnimation{vm.canvasScale=max(vm.canvasScale*0.8,0.3)} } label: {
                        Image(systemName:"minus").frame(width:34,height:34).background(Color.white.opacity(0.1)).foregroundColor(.white)
                    }
                }.cornerRadius(9).padding(10)
            }
        }
    }
}

struct TopObj: View {
    @EnvironmentObject var vm: DesignVM
    let obj: FurnitureItem
    var body: some View {
        let sc=vm.canvasScale; let ppm=vm.ppm*sc
        let w=CGFloat(obj.width)*ppm; let d=CGFloat(obj.depth)*ppm
        let x=CGFloat(obj.position.x)*ppm; let z=CGFloat(obj.position.z)*ppm
        return ZStack {
            RoundedRectangle(cornerRadius:4).fill(obj.color.opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius:4).stroke(
                    obj.isSelected ? Color(red:0.5,green:0.25,blue:1) : Color.white.opacity(0.25),
                    lineWidth: obj.isSelected ? 2.5 : 1
                ))
                .overlay(Text(obj.emoji).font(.system(size:min(w,d)*0.38)))
        }
        .frame(width:w,height:d).rotationEffect(.degrees(Double(obj.rotation))).offset(x:x,y:z)
        .onTapGesture { vm.select(obj) }
    }
}

// MARK: Elevation Canvas
struct ElevCanvas: View {
    @EnvironmentObject var vm: DesignVM
    var body: some View {
        GeometryReader { geo in
            let sc=vm.canvasScale; let ppm=vm.ppm*sc
            let rw=CGFloat(vm.roomW)*ppm; let rh=CGFloat(vm.roomH)*ppm
            let cx=geo.size.width/2; let cy=geo.size.height/2
            ZStack {
                Color(red:0.06,green:0.07,blue:0.12)
                Rectangle().fill(vm.wallColor.opacity(0.12)).frame(width:rw,height:rh)
                    .overlay(Rectangle().stroke(Color.white.opacity(0.12),lineWidth:1.5)).position(x:cx,y:cy)
                Rectangle().fill(vm.floor.color.opacity(0.4)).frame(width:rw,height:7).position(x:cx,y:cy+rh/2-3.5)
                ForEach(vm.items) { obj in
                    let ow=CGFloat(obj.width)*ppm; let oh=CGFloat(obj.height)*ppm
                    let ox=CGFloat(obj.position.x)*ppm+cx; let oy=cy+rh/2-oh/2
                    ZStack {
                        RoundedRectangle(cornerRadius:3).fill(obj.color.opacity(0.7))
                            .overlay(RoundedRectangle(cornerRadius:3).stroke(Color.white.opacity(0.2),lineWidth:1))
                        Text(obj.emoji).font(.system(size:min(ow,oh)*0.4))
                    }.frame(width:ow,height:oh).position(x:ox,y:oy)
                }
            }
        }
    }
}

// MARK: Inspector Panel
struct InspectorPanel: View {
    @EnvironmentObject var vm: DesignVM
    let item: FurnitureItem
    var body: some View {
        VStack(alignment:.leading,spacing:0) {
            inspectorHeader
            Divider().background(Color.white.opacity(0.07))
            ScrollView(showsIndicators:false) {
                VStack(alignment:.leading,spacing:12) {
                    rotateSection
                    materialSection
                    dimsRow
                    priceRow
                    deleteButton
                }.padding(12)
            }
        }
        .background(Color(red:0.08,green:0.08,blue:0.14))
        .cornerRadius(18, corners:[.topLeft,.bottomLeft])
        .frame(width:220).frame(maxHeight:.infinity)
    }

    private var inspectorHeader: some View {
        HStack {
            Text(item.emoji).font(.system(size:22))
            VStack(alignment:.leading,spacing:2) {
                Text(item.name).font(.system(size:14,weight:.bold))
                Text(item.category.rawValue).font(.system(size:11)).foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            Button { vm.deselect() } label: {
                Image(systemName:"xmark").font(.system(size:11,weight:.bold)).foregroundColor(.white.opacity(0.5))
                    .frame(width:26,height:26).background(Color.white.opacity(0.08)).clipShape(Circle())
            }
        }.padding(14)
    }

    private var rotateSection: some View {
        VStack(alignment:.leading,spacing:7) {
            Label("Rotate",systemImage:"rotate.right")
                .font(.system(size:11,weight:.semibold,design:.monospaced))
                .foregroundColor(.white.opacity(0.3)).tracking(1)
            HStack(spacing:5) {
                ForEach([-90,-45,45,90], id:\.self) { d in
                    Button { vm.rotate(Float(d)) } label: {
                        Text("\(d)°").font(.system(size:10,weight:.semibold,design:.monospaced))
                            .foregroundColor(.white).padding(.horizontal,7).padding(.vertical,5)
                            .background(Color.white.opacity(0.1)).cornerRadius(6)
                    }
                }
            }
        }.inspectorSection()
    }

    private var materialSection: some View {
        VStack(alignment:.leading,spacing:8) {
            Text("MATERIAL").font(.system(size:10,weight:.semibold,design:.monospaced))
                .foregroundColor(.white.opacity(0.3)).tracking(1.5)
            LazyVGrid(columns:Array(repeating:.init(.flexible()),count:3),spacing:6) {
                ForEach(MaterialKind.allCases, id:\.self) { m in
                    Button { vm.setMaterial(m) } label: {
                        VStack(spacing:3) {
                            Circle().fill(m.color).frame(width:26,height:26)
                                .overlay(Circle().stroke(item.material==m ? Color(red:0.5,green:0.25,blue:1) : Color.clear, lineWidth:2))
                            Text(m.rawValue).font(.system(size:9)).foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
        }.inspectorSection()
    }

    private var dimsRow: some View {
        HStack(spacing:6) {
            IBadge("W","\(String(format:"%.1f",item.width))m")
            IBadge("H","\(String(format:"%.1f",item.height))m")
            IBadge("D","\(String(format:"%.1f",item.depth))m")
        }
    }

    private var priceRow: some View {
        HStack {
            Text("Price").font(.system(size:12)).foregroundColor(.white.opacity(0.5))
            Spacer()
            Text("$\(Int(item.price))")
                .font(.system(size:15,weight:.bold,design:.monospaced))
                .foregroundColor(Color(red:0.3,green:0.9,blue:0.5))
        }
        .padding(11).background(Color.white.opacity(0.04)).cornerRadius(10)
    }

    private var deleteButton: some View {
        Button { vm.remove(item) } label: {
            Label("Remove",systemImage:"trash").font(.system(size:13,weight:.semibold))
                .foregroundColor(Color(red:1,green:0.35,blue:0.35))
                .frame(maxWidth:.infinity).padding(.vertical,11)
                .background(Color(red:1,green:0.35,blue:0.35).opacity(0.1)).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius:10).stroke(Color(red:1,green:0.35,blue:0.35).opacity(0.3),lineWidth:1))
        }
    }
}

extension View {
    func inspectorSection() -> some View {
        self.padding(11).background(Color.white.opacity(0.03)).cornerRadius(10)
    }
}

struct IBadge: View {
    let l:String; let v:String
    init(_ l:String,_ v:String){self.l=l;self.v=v}
    var body: some View {
        VStack(spacing:2) {
            Text(l).font(.system(size:9,design:.monospaced)).foregroundColor(.white.opacity(0.3))
            Text(v).font(.system(size:11,weight:.bold,design:.monospaced)).foregroundColor(.white)
        }.frame(maxWidth:.infinity).padding(.vertical,7).background(Color.white.opacity(0.05)).cornerRadius(8)
    }
}

// MARK: Catalog Sheet
struct CatalogSheet: View {
    @EnvironmentObject var vm: DesignVM
    @Binding var isPresented:Bool
    var body: some View {
        VStack(spacing:0) { Spacer()
            VStack(spacing:0) {
                Capsule().fill(Color.white.opacity(0.2)).frame(width:38,height:4).padding(.top,12).padding(.bottom,10)
                HStack {
                    Text("Furniture Catalog").font(.system(size:17,weight:.bold))
                    Spacer()
                    Button { isPresented=false } label: {
                        Image(systemName:"xmark.circle.fill").font(.system(size:22)).foregroundColor(.white.opacity(0.4))
                    }
                }.padding(.horizontal,18).padding(.bottom,12)

                ScrollView(.horizontal,showsIndicators:false) {
                    HStack(spacing:7) {
                        ForEach(FurnitureCategory.allCases) { c in
                            Button {
                                vm.filterCat=c; UISelectionFeedbackGenerator().selectionChanged()
                            } label: {
                                HStack(spacing:4) {
                                    Image(systemName:c.sfIcon).font(.system(size:11))
                                    Text(c.rawValue).font(.system(size:13,weight:.medium))
                                }
                                .foregroundColor(vm.filterCat==c ? .white : .white.opacity(0.5))
                                .padding(.horizontal,13).padding(.vertical,7)
                                .background(vm.filterCat==c ? Color(red:0.5,green:0.25,blue:1) : Color.white.opacity(0.07))
                                .cornerRadius(20)
                            }
                        }
                    }.padding(.horizontal,18)
                }.padding(.bottom,10)

                ScrollView(showsIndicators:false) {
                    LazyVGrid(columns:[.init(.flexible()),.init(.flexible())],spacing:9) {
                        ForEach(vm.filtered) { item in
                            Button { vm.add(item); isPresented=false } label: {
                                HStack(spacing:10) {
                                    Text(item.emoji).font(.system(size:26)).frame(width:48,height:48)
                                        .background(item.color.opacity(0.2)).cornerRadius(11)
                                    VStack(alignment:.leading,spacing:2) {
                                        Text(item.name).font(.system(size:13,weight:.semibold)).foregroundColor(.white).lineLimit(1)
                                        Text("$\(Int(item.price))").font(.system(size:12,weight:.bold)).foregroundColor(Color(red:0.3,green:0.9,blue:0.5))
                                    }
                                    Spacer()
                                    Image(systemName:"plus.circle.fill").font(.system(size:18)).foregroundColor(Color(red:0.5,green:0.25,blue:1))
                                }
                                .padding(11).background(Color.white.opacity(0.05)).cornerRadius(13)
                                .overlay(RoundedRectangle(cornerRadius:13).stroke(Color.white.opacity(0.07),lineWidth:1))
                            }
                        }
                    }.padding(.horizontal,14).padding(.bottom,36)
                }.frame(maxHeight:310)
            }
            .background(Color(red:0.08,green:0.08,blue:0.13)).cornerRadius(22,corners:[.topLeft,.topRight])
        }.ignoresSafeArea()
    }
}

// MARK: Room Sheet
struct RoomSheet: View {
    @EnvironmentObject var vm: DesignVM
    @Binding var isPresented:Bool
    var body: some View {
        VStack(spacing:0) { Spacer()
            VStack(spacing:0) {
                Capsule().fill(Color.white.opacity(0.2)).frame(width:38,height:4).padding(.top,12).padding(.bottom,14)
                HStack {
                    Text("Room Settings").font(.system(size:17,weight:.bold))
                    Spacer()
                    Button { isPresented=false } label: {
                        Image(systemName:"xmark.circle.fill").font(.system(size:22)).foregroundColor(.white.opacity(0.4))
                    }
                }.padding(.horizontal,18).padding(.bottom,14)

                ScrollView(showsIndicators:false) {
                    VStack(spacing:18) {
                        lightingSection
                        flooringSection
                        sizeSection
                    }
                }.frame(maxHeight:380)
            }
            .background(Color(red:0.08,green:0.08,blue:0.13)).cornerRadius(22,corners:[.topLeft,.topRight])
        }.ignoresSafeArea()
    }

    private var lightingSection: some View {
        VStack(alignment:.leading,spacing:10) {
            Text("LIGHTING").font(.system(size:11,weight:.semibold,design:.monospaced))
                .foregroundColor(.white.opacity(0.3)).tracking(1.5).padding(.horizontal,18)
            ScrollView(.horizontal,showsIndicators:false) {
                HStack(spacing:9) {
                    ForEach(LightPreset.allCases,id:\.self) { p in
                        Button { vm.light=p; UIImpactFeedbackGenerator(style:.light).impactOccurred() } label: {
                            VStack(spacing:5) {
                                ZStack {
                                    Circle().fill(p.tint.opacity(0.25)).frame(width:48,height:48)
                                    Image(systemName:p.sfIcon).font(.system(size:20)).foregroundColor(p.tint)
                                }
                                Text(p.rawValue).font(.system(size:11,weight:.medium))
                                    .foregroundColor(vm.light==p ? .white : .white.opacity(0.5))
                            }
                            .padding(.vertical,9).padding(.horizontal,13)
                            .background(vm.light==p ? p.tint.opacity(0.18) : Color.white.opacity(0.05))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius:14).stroke(vm.light==p ? p.tint.opacity(0.4) : Color.clear, lineWidth:1.5))
                        }
                    }
                }.padding(.horizontal,18)
            }
        }
    }

    private var flooringSection: some View {
        VStack(alignment:.leading,spacing:10) {
            Text("FLOORING").font(.system(size:11,weight:.semibold,design:.monospaced))
                .foregroundColor(.white.opacity(0.3)).tracking(1.5).padding(.horizontal,18)
            ScrollView(.horizontal,showsIndicators:false) {
                HStack(spacing:9) {
                    ForEach(FloorKind.allCases,id:\.self) { f in
                        Button { vm.floor=f; UIImpactFeedbackGenerator(style:.light).impactOccurred() } label: {
                            HStack(spacing:7) {
                                Text(f.emoji).font(.system(size:17))
                                Text(f.rawValue).font(.system(size:13,weight:.medium))
                                    .foregroundColor(vm.floor==f ? .white : .white.opacity(0.6))
                            }
                            .padding(.horizontal,13).padding(.vertical,10)
                            .background(vm.floor==f ? f.color.opacity(0.28) : Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius:12).stroke(vm.floor==f ? f.color.opacity(0.5) : Color.clear, lineWidth:1.5))
                        }
                    }
                }.padding(.horizontal,18)
            }
        }
    }

    private var sizeSection: some View {
        HStack(spacing:12) {
            VStack(spacing:4) {
                Text("\(String(format:"%.1f",vm.roomW))m").font(.system(size:22,weight:.black,design:.monospaced))
                Text("Width").font(.system(size:11)).foregroundColor(.white.opacity(0.4))
                Stepper("",value:Binding(get:{Double(vm.roomW)},set:{vm.roomW=Float($0)}),in:2...15,step:0.5).labelsHidden()
            }.frame(maxWidth:.infinity).padding(12).background(Color.white.opacity(0.05)).cornerRadius(12)

            VStack(spacing:4) {
                Text("\(String(format:"%.1f",vm.roomL))m").font(.system(size:22,weight:.black,design:.monospaced))
                Text("Length").font(.system(size:11)).foregroundColor(.white.opacity(0.4))
                Stepper("",value:Binding(get:{Double(vm.roomL)},set:{vm.roomL=Float($0)}),in:2...15,step:0.5).labelsHidden()
            }.frame(maxWidth:.infinity).padding(12).background(Color.white.opacity(0.05)).cornerRadius(12)
        }.padding(.horizontal,18).padding(.bottom,36)
    }
}

// MARK: Stats
struct StatsView: View {
    @EnvironmentObject var vm: DesignVM
    var floorArea: Double { Double(vm.roomW * vm.roomL) }
    var usedArea:  Double { vm.items.reduce(0){$0 + Double($1.width*$1.depth)} }
    var util:      Double { min(usedArea/max(floorArea,0.01)*100, 100) }

    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text("Room Stats").font(.system(size:15,weight:.bold))
            StatR("square.3.layers.3d","Objects","\(vm.items.count)")
            StatR("ruler","Floor Area",String(format:"%.1f m²",floorArea))
            StatR("chart.pie","Space Used",String(format:"%.0f%%",util))
            StatR("dollarsign.circle","Total Budget","$\(Int(vm.budget))")
            utilizationBar
        }.padding(18).background(Color(red:0.08,green:0.08,blue:0.13)).frame(width:230)
    }

    private var utilizationBar: some View {
        VStack(alignment:.leading,spacing:5) {
            Text("Utilization").font(.system(size:12)).foregroundColor(.white.opacity(0.5))
            GeometryReader { g in
                ZStack(alignment:.leading) {
                    RoundedRectangle(cornerRadius:4).fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius:4)
                        .fill(LinearGradient(
                            colors: util > 80 ? [.orange,.red] : [Color(red:0.3,green:0.9,blue:0.5),Color(red:0.2,green:0.7,blue:1)],
                            startPoint:.leading, endPoint:.trailing
                        ))
                        .frame(width: g.size.width * min(util/100, 1))
                }.frame(height:7)
            }.frame(height:7)
        }
    }
}

struct StatR: View {
    let icon:String; let label:String; let value:String
    init(_ i:String,_ l:String,_ v:String){icon=i;label=l;value=v}
    var body: some View {
        HStack {
            Image(systemName:icon).font(.system(size:13)).foregroundColor(Color(red:0.5,green:0.25,blue:1)).frame(width:22)
            Text(label).font(.system(size:13)).foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value).font(.system(size:13,weight:.bold,design:.monospaced))
        }
    }
}

// ================================================================
// MARK: — SCREEN 4: SUGGESTIONS
// ================================================================

struct SuggestionView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var vm: DesignVM
    @State private var selTheme: DesignTheme? = nil
    @State private var tab = 0
    @State private var progress: Double = 0
    @State private var analyzing = false
    @State private var done = false

    var body: some View {
        ZStack {
            Color(red:0.05,green:0.05,blue:0.09).ignoresSafeArea()
            RadialGradient(colors:[Color(red:0.2,green:0.08,blue:0.4).opacity(0.35),.clear],
                           center:UnitPoint(x:0.5,y:0.15),startRadius:0,endRadius:280).ignoresSafeArea()
            VStack(spacing:0) {
                suggestionHeader
                if analyzing || done { analysisBar }
                suggestionTabs
                ScrollView(showsIndicators:false) {
                    VStack(spacing:16) {
                        if tab==0      { themesTab }
                        else if tab==1 { lightingTab }
                        else if tab==2 { tipsTab }
                        else           { palettesTab }
                    }.padding(.horizontal,18).padding(.bottom,40)
                }
                if let t = selTheme { applyBar(t) }
            }
        }
    }

    private var suggestionHeader: some View {
        HStack(spacing:10) {
            BackBtn { app.go(.designCanvas) }
            VStack(alignment:.leading,spacing:2) {
                Text("Smart Design").font(.system(size:19,weight:.bold))
                Text("AI-powered suggestions").font(.system(size:12)).foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            analyzeButton
        }.padding(.horizontal,18).padding(.vertical,12)
    }

    private var analyzeButton: some View {
        Button {
            guard !analyzing else { return }
            analyzing=true; done=false; progress=0
            UIImpactFeedbackGenerator(style:.medium).impactOccurred()
            let steps: [Double] = [15,38,62,80,100]
            for (i,v) in steps.enumerated() {
                DispatchQueue.main.asyncAfter(deadline:.now()+Double(i)*0.45) {
                    withAnimation { progress=v }
                    if v==100 {
                        analyzing=false; done=true
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
            }
        } label: {
            let isFinished = done
            Label(isFinished ? "Done":"Analyze", systemImage: isFinished ? "checkmark":"wand.and.stars")
                .font(.system(size:13,weight:.bold))
                .padding(.horizontal,14).padding(.vertical,9)
                .background(LinearGradient(
                    colors: isFinished ? [Color(red:0.2,green:0.8,blue:0.4),Color(red:0.1,green:0.7,blue:0.5)] : [Color(red:0.5,green:0.2,blue:1),Color(red:0.3,green:0.5,blue:1)],
                    startPoint:.leading, endPoint:.trailing
                ))
                .cornerRadius(11).foregroundColor(.white)
        }
    }

    private var analysisBar: some View {
        VStack(spacing:6) {
            HStack {
                Text(analyzing ? "Analyzing space..." : "Analysis complete")
                    .font(.system(size:12,design:.monospaced)).foregroundColor(.white.opacity(0.45))
                Spacer()
                Text("\(Int(progress))%")
                    .font(.system(size:12,weight:.bold,design:.monospaced))
                    .foregroundColor(Color(red:0.5,green:0.25,blue:1))
            }
            GeometryReader { g in
                ZStack(alignment:.leading) {
                    RoundedRectangle(cornerRadius:3).fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius:3)
                        .fill(LinearGradient(colors:[Color(red:0.5,green:0.25,blue:1),Color(red:0.3,green:0.7,blue:1)],startPoint:.leading,endPoint:.trailing))
                        .frame(width:g.size.width*(progress/100))
                }.frame(height:4)
            }.frame(height:4)
        }.padding(.horizontal,18).padding(.bottom,10)
    }

    private var suggestionTabs: some View {
        let tabNames = ["Themes","Lighting","Tips","Palettes"]
        return HStack(spacing:0) {
            ForEach(0..<4, id:\.self) { i in
                Button {
                    withAnimation(.spring(response:0.35)) { tab=i }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    Text(tabNames[i]).font(.system(size:13,weight:.semibold))
                        .foregroundColor(tab==i ? .white : .white.opacity(0.4))
                        .padding(.horizontal,16).padding(.vertical,9)
                        .background(tab==i ? Color(red:0.5,green:0.25,blue:1) : Color.white.opacity(0.06))
                        .cornerRadius(20)
                }
            }
            Spacer()
        }.padding(.horizontal,18).padding(.bottom,10)
    }

    private func applyBar(_ t: DesignTheme) -> some View {
        VStack(spacing:0) {
            LinearGradient(colors:[.clear,Color(red:0.05,green:0.05,blue:0.09)],startPoint:.top,endPoint:.bottom).frame(height:28)
            HStack(spacing:14) {
                HStack(spacing:8) {
                    Text(t.emoji).font(.system(size:22))
                    VStack(alignment:.leading,spacing:1) {
                        Text(t.rawValue).font(.system(size:15,weight:.bold))
                        Text(t.detail).font(.system(size:11)).foregroundColor(.white.opacity(0.45)).lineLimit(1)
                    }
                }
                Spacer()
                Button { vm.applyTheme(t); app.go(.designCanvas) } label: {
                    Text("Apply").font(.system(size:15,weight:.bold)).foregroundColor(.white)
                        .padding(.horizontal,22).padding(.vertical,13)
                        .background(LinearGradient(
                            colors:[Color(red:0.5,green:0.2,blue:1),Color(red:0.3,green:0.5,blue:1)],
                            startPoint:.leading,endPoint:.trailing
                        ))
                        .cornerRadius(13).shadow(color:Color(red:0.4,green:0.2,blue:0.9).opacity(0.4),radius:12,y:4)
                }
            }.padding(.horizontal,18).padding(.vertical,14).background(Color(red:0.08,green:0.08,blue:0.13))
        }
    }

    // MARK: Themes Tab
    var themesTab: some View {
        VStack(spacing:12) {
            Text("Choose Your Aesthetic").font(.system(size:20,weight:.bold)).frame(maxWidth:.infinity,alignment:.leading)
            ForEach(DesignTheme.allCases) { t in themeCard(t) }
        }
    }

    private func themeCard(_ t: DesignTheme) -> some View {
        let isSelected = selTheme == t
        return Button {
            withAnimation(.spring(response:0.4)) { selTheme = isSelected ? nil : t }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            HStack(spacing:14) {
                themePreview(t)
                VStack(alignment:.leading,spacing:5) {
                    Text(t.rawValue).font(.system(size:16,weight:.bold)).foregroundColor(.white)
                    Text(t.detail).font(.system(size:12)).foregroundColor(.white.opacity(0.5)).multilineTextAlignment(.leading)
                    HStack(spacing:3) {
                        Circle().fill(t.wallColor).frame(width:11,height:11).overlay(Circle().stroke(Color.white.opacity(0.2),lineWidth:0.5))
                        Circle().fill(t.accent).frame(width:11,height:11)
                        Circle().fill(t.floor.color).frame(width:11,height:11)
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill":"circle")
                    .font(.system(size:21))
                    .foregroundColor(isSelected ? Color(red:0.5,green:0.25,blue:1) : .white.opacity(0.18))
            }
            .padding(14)
            .background(isSelected ? Color(red:0.5,green:0.25,blue:1).opacity(0.1) : Color.white.opacity(0.04))
            .cornerRadius(17)
            .overlay(RoundedRectangle(cornerRadius:17).stroke(
                isSelected ? Color(red:0.5,green:0.25,blue:1).opacity(0.35) : Color.white.opacity(0.06),
                lineWidth: isSelected ? 1.5 : 1
            ))
        }
    }

    private func themePreview(_ t: DesignTheme) -> some View {
        let isSelected = selTheme == t
        return ZStack {
            RoundedRectangle(cornerRadius:13).fill(t.wallColor).frame(width:66,height:66)
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius:0).fill(t.floor.color).frame(height:14)
            }.frame(width:66,height:66).clipShape(RoundedRectangle(cornerRadius:13))
            Circle().fill(t.accent).frame(width:18,height:18)
            Text(t.emoji).font(.system(size:18))
        }
        .overlay(RoundedRectangle(cornerRadius:13).stroke(
            isSelected ? Color(red:0.5,green:0.25,blue:1) : Color.white.opacity(0.1),
            lineWidth: isSelected ? 2.5 : 1
        ))
    }

    // MARK: Lighting Tab
    var lightingTab: some View {
        VStack(spacing:12) {
            Text("Lighting Design").font(.system(size:20,weight:.bold)).frame(maxWidth:.infinity,alignment:.leading)
            ForEach(LightPreset.allCases, id:\.self) { p in
                Button { vm.light=p; UIImpactFeedbackGenerator(style:.light).impactOccurred() } label: {
                    HStack(spacing:14) {
                        ZStack {
                            Circle().fill(p.tint.opacity(0.22)).frame(width:52,height:52)
                            Image(systemName:p.sfIcon).font(.system(size:22)).foregroundColor(p.tint)
                        }
                        VStack(alignment:.leading,spacing:4) {
                            Text(p.rawValue).font(.system(size:15,weight:.bold)).foregroundColor(.white)
                            Text(lightDesc(p)).font(.system(size:12)).foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: vm.light==p ? "checkmark.circle.fill":"circle")
                            .font(.system(size:21))
                            .foregroundColor(vm.light==p ? Color(red:0.5,green:0.25,blue:1) : .white.opacity(0.18))
                    }
                    .padding(14)
                    .background(vm.light==p ? p.tint.opacity(0.1) : Color.white.opacity(0.04))
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius:15).stroke(vm.light==p ? p.tint.opacity(0.35):Color.clear,lineWidth:1.5))
                }
            }
        }
    }

    func lightDesc(_ p:LightPreset)->String {
        switch p {
        case .natural:  return "Balanced daylight for living areas"
        case .warm:     return "Golden warmth for bedrooms & dining"
        case .cool:     return "Crisp white for kitchens & offices"
        case .dramatic: return "Low moody ambience for entertainment"
        case .studio:   return "Bright even light for creative work"
        }
    }

    let tips: [(String,String,String)] = [
        ("paintpalette","60-30-10 Rule","60% dominant, 30% secondary, 10% accent color for balance"),
        ("star","Focal Point First","Every room needs an anchor — sofa, fireplace, or statement art"),
        ("rectangle.3d","Float Furniture","Pull pieces away from walls to create intimate conversation zones"),
        ("list.number","Rule of Odd Numbers","Group decor in 3s or 5s — odd numbers feel more natural"),
        ("square.stack.3d.down.right","Layer Rugs","Use rugs to define zones — large enough for all furniture legs"),
        ("arrow.up.and.down","Use Vertical Space","Tall shelves and floor-to-ceiling curtains make rooms feel taller"),
        ("square.grid.3x3","Mix Textures","Smooth + rough + soft + hard = richness even without color"),
        ("figure.walk","Traffic Flow","Leave 90cm for main walkways, 60cm between furniture pieces"),
    ]

    // MARK: Tips Tab
    var tipsTab: some View {
        VStack(spacing:12) {
            Text("Design Principles").font(.system(size:20,weight:.bold)).frame(maxWidth:.infinity,alignment:.leading)
            ForEach(tips.indices, id:\.self) { i in tipRow(i) }
        }
    }

    private func tipRow(_ i: Int) -> some View {
        HStack(alignment:.top,spacing:14) {
            ZStack {
                RoundedRectangle(cornerRadius:11).fill(Color(red:0.5,green:0.25,blue:1).opacity(0.14)).frame(width:42,height:42)
                Image(systemName:tips[i].0).font(.system(size:17)).foregroundColor(Color(red:0.6,green:0.35,blue:1))
            }
            VStack(alignment:.leading,spacing:4) {
                HStack {
                    Text("0\(i+1)").font(.system(size:11,weight:.bold,design:.monospaced)).foregroundColor(Color(red:0.5,green:0.25,blue:1))
                    Text(tips[i].1).font(.system(size:14,weight:.bold)).foregroundColor(.white)
                }
                Text(tips[i].2).font(.system(size:12)).foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(14).background(Color.white.opacity(0.04)).cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius:15).stroke(Color.white.opacity(0.06),lineWidth:1))
    }

    let palettes: [(String,[Color],String)] = [
        ("Nordic Frost",[Color(red:0.95,green:0.95,blue:0.98),Color(red:0.8,green:0.88,blue:0.94),Color(red:0.55,green:0.7,blue:0.85),Color(red:0.35,green:0.45,blue:0.6),Color(red:0.6,green:0.45,blue:0.3)],"Calm, coastal, serene"),
        ("Terracotta",[Color(red:0.97,green:0.93,blue:0.88),Color(red:0.88,green:0.72,blue:0.55),Color(red:0.73,green:0.45,blue:0.3),Color(red:0.52,green:0.32,blue:0.25),Color(red:0.35,green:0.48,blue:0.4)],"Warm, earthy, Mediterranean"),
        ("Midnight Luxe",[Color(red:0.1,green:0.1,blue:0.15),Color(red:0.18,green:0.18,blue:0.25),Color(red:0.4,green:0.3,blue:0.65),Color(red:0.75,green:0.65,blue:0.4),Color(red:0.95,green:0.92,blue:0.85)],"Dramatic, sophisticated"),
        ("Forest",[Color(red:0.92,green:0.9,blue:0.84),Color(red:0.72,green:0.78,blue:0.65),Color(red:0.45,green:0.58,blue:0.42),Color(red:0.32,green:0.42,blue:0.3),Color(red:0.55,green:0.42,blue:0.28)],"Natural, biophilic"),
        ("Tokyo",[Color(red:0.97,green:0.97,blue:0.97),Color(red:0.88,green:0.88,blue:0.88),Color(red:0.55,green:0.55,blue:0.55),Color(red:0.25,green:0.25,blue:0.25),Color(red:0.85,green:0.2,blue:0.2)],"Minimal, refined"),
    ]

    // MARK: Palettes Tab
    var palettesTab: some View {
        VStack(spacing:14) {
            Text("Color Palettes").font(.system(size:20,weight:.bold)).frame(maxWidth:.infinity,alignment:.leading)
            ForEach(palettes, id:\.0) { pal in paletteCard(pal) }
        }
    }

    private func paletteCard(_ pal: (String,[Color],String)) -> some View {
        VStack(alignment:.leading,spacing:10) {
            HStack {
                VStack(alignment:.leading,spacing:2) {
                    Text(pal.0).font(.system(size:15,weight:.bold))
                    Text(pal.2).font(.system(size:12)).foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                Button {
                    vm.popup("🎨 \(pal.0) applied")
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Text("Apply").font(.system(size:13,weight:.bold))
                        .foregroundColor(Color(red:0.6,green:0.35,blue:1))
                        .padding(.horizontal,14).padding(.vertical,7)
                        .background(Color(red:0.5,green:0.25,blue:1).opacity(0.14)).cornerRadius(9)
                }
            }
            HStack(spacing:3) {
                ForEach(pal.1.indices, id:\.self) { i in
                    RoundedRectangle(cornerRadius: i==0 || i==pal.1.count-1 ? 9 : 3)
                        .fill(pal.1[i]).frame(maxWidth:.infinity).frame(height:48)
                }
            }.cornerRadius(9)
        }
        .padding(14).background(Color.white.opacity(0.04)).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius:16).stroke(Color.white.opacity(0.06),lineWidth:1))
    }
}

// ================================================================
// MARK: — SCREEN 5: AR PREVIEW
// ================================================================

struct ARPreviewWrap: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var vm: DesignVM
    @StateObject private var arVM = ARViewModel()
    @State private var showPicker = false
    @State private var selItem: FurnitureItem? = FurnitureItem.catalog.first
    @State private var showUI = true
    @State private var uiTimer: Timer?

    var body: some View {
        ZStack {
            ARContainer(arVM:arVM).ignoresSafeArea()
            RadialGradient(colors:[.clear,.black.opacity(0.35)],center:.center,
                           startRadius:UIScreen.main.bounds.width*0.28,
                           endRadius:UIScreen.main.bounds.width)
                .ignoresSafeArea().allowsHitTesting(false)

            VStack {
                if showUI { arTopBar.transition(.move(edge:.top).combined(with:.opacity)) }
                Spacer()
                ARReticle(tracking:arVM.tracking)
                Spacer()
                if showUI { arBottomControls.transition(.move(edge:.bottom).combined(with:.opacity)) }
            }

            if arVM.showToast {
                VStack{Spacer();Toast(msg:arVM.toastMsg).padding(.bottom,110)}.transition(.move(edge:.bottom))
            }
            if !arVM.tracking { ScanHint().transition(.opacity) }
            if showPicker {
                ARPicker(sel:$selItem,shown:$showPicker)
                    .transition(.move(edge:.bottom).combined(with:.opacity)).zIndex(10)
            }
        }
        .animation(.spring(response:0.4), value:showUI)
        .animation(.spring(response:0.4), value:showPicker)
        .animation(.spring(response:0.4), value:arVM.showToast)
        .animation(.spring(response:0.4), value:arVM.tracking)
        .onTapGesture { withAnimation{showUI.toggle()}; resetTimer() }
        .onAppear { resetTimer() }
        .onDisappear { uiTimer?.invalidate() }
    }

    private var arTopBar: some View {
        HStack(spacing:12) {
            Button { arVM.session?.pause(); app.go(.designCanvas) } label: {
                Image(systemName:"chevron.left").font(.system(size:15,weight:.semibold)).foregroundColor(.white)
                    .frame(width:42,height:42).background(.ultraThinMaterial).clipShape(Circle())
            }
            VStack(alignment:.leading,spacing:2) {
                Text("AR Preview").font(.system(size:16,weight:.bold))
                HStack(spacing:5) {
                    Circle().fill(arVM.tracking ? Color.green : Color.orange).frame(width:6,height:6)
                    Text(arVM.tracking ? "Surface Found" : "Searching…").font(.system(size:11)).foregroundColor(.white.opacity(0.7))
                }
            }
            Spacer()
            HStack(spacing:6) {
                Image(systemName:"square.stack.3d.up").font(.system(size:12)).foregroundColor(.white.opacity(0.7))
                Text("\(arVM.placed)").font(.system(size:13,weight:.bold,design:.monospaced))
            }.padding(.horizontal,12).padding(.vertical,7).background(.ultraThinMaterial).cornerRadius(20)
            Button { arVM.snapshot() } label: {
                Image(systemName:"camera.circle.fill").font(.system(size:30)).foregroundColor(.white).shadow(color:.black.opacity(0.3),radius:8)
            }
            Button { arVM.reset() } label: {
                Image(systemName:"arrow.counterclockwise.circle.fill").font(.system(size:30)).foregroundColor(.white.opacity(0.8))
            }
        }.padding(.horizontal,16).padding(.top,10).padding(.bottom,8)
    }

    private var arBottomControls: some View {
        VStack(spacing:10) {
            if let item = selItem {
                HStack(spacing:12) {
                    Text(item.emoji).font(.system(size:26))
                    VStack(alignment:.leading,spacing:2) {
                        Text(item.name).font(.system(size:14,weight:.bold))
                        Text("\(String(format:"%.1f",item.width))×\(String(format:"%.1f",item.depth))m")
                            .font(.system(size:11,design:.monospaced)).foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Button { showPicker=true } label: {
                        Text("Change").font(.system(size:13,weight:.semibold)).foregroundColor(.white)
                            .padding(.horizontal,13).padding(.vertical,8).background(.ultraThinMaterial).cornerRadius(10)
                    }
                }
                .padding(.horizontal,18).padding(.vertical,13)
                .background(.ultraThinMaterial).cornerRadius(18).padding(.horizontal,16)
            }
            HStack(spacing:14) {
                ARCtrlBtn("rotate.left","Rotate") { arVM.rotateLast(by:-45) }
                placeButton
                ARCtrlBtn("arrow.uturn.backward","Undo") { arVM.removeLast() }
            }.padding(.horizontal,60).padding(.bottom,28)
        }
    }

    private var placeButton: some View {
        Button {
            guard let item = selItem else { return }
            arVM.placeFromCenter(item:item)
            UIImpactFeedbackGenerator(style:.heavy).impactOccurred()
        } label: {
            VStack(spacing:4) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors:[Color(red:0.5,green:0.2,blue:1),Color(red:0.3,green:0.5,blue:1)],startPoint:.topLeading,endPoint:.bottomTrailing))
                        .frame(width:70,height:70)
                        .shadow(color:Color(red:0.4,green:0.2,blue:0.9).opacity(0.6),radius:20)
                    Image(systemName:"plus").font(.system(size:27,weight:.bold)).foregroundColor(.white)
                }
                Text("Place").font(.system(size:11,weight:.semibold)).foregroundColor(.white.opacity(0.65))
            }
        }
    }

    func resetTimer() {
        uiTimer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline:.now()+6) {
            withAnimation { self.showUI = false }
        }
    }
}

struct ARCtrlBtn: View {
    let icon:String; let label:String; let action:()->Void
    init(_ i:String,_ l:String,_ a:@escaping()->Void){icon=i;label=l;action=a}
    var body: some View {
        Button { action(); UIImpactFeedbackGenerator(style:.light).impactOccurred() } label: {
            VStack(spacing:4) {
                Image(systemName:icon).font(.system(size:19)).foregroundColor(.white)
                    .frame(width:50,height:50).background(.ultraThinMaterial).clipShape(Circle())
                Text(label).font(.system(size:10,weight:.medium)).foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

struct ARReticle: View {
    let tracking:Bool
    @State private var pulse=false
    var body: some View {
        let col: Color = tracking ? Color(red:0.5,green:0.25,blue:1) : Color.white.opacity(0.6)
        return ZStack {
            Circle().stroke(tracking ? Color(red:0.5,green:0.25,blue:1).opacity(0.5) : Color.white.opacity(0.3),lineWidth:1.5)
                .frame(width:58,height:58).scaleEffect(pulse ? 1.1:1)
            Rectangle().fill(col).frame(width:18,height:1.5)
            Rectangle().fill(col).frame(width:1.5,height:18)
            Circle().fill(col).frame(width:5,height:5)
        }
        .onAppear { withAnimation(.easeInOut(duration:1.5).repeatForever(autoreverses:true)){pulse=true} }
    }
}

struct ScanHint: View {
    var body: some View {
        VStack(spacing:12) {
            Image(systemName:"viewfinder").font(.system(size:44)).foregroundColor(.white.opacity(0.55))
            Text("Point at a flat surface").font(.system(size:15,weight:.medium)).foregroundColor(.white.opacity(0.75))
            Text("Move slowly to detect floors and tables").font(.system(size:12)).foregroundColor(.white.opacity(0.4))
        }.padding(22).background(.ultraThinMaterial).cornerRadius(18).padding(.horizontal,48)
    }
}

struct ARPicker: View {
    @Binding var sel: FurnitureItem?
    @Binding var shown: Bool
    var body: some View {
        VStack(spacing:0) { Spacer()
            VStack(spacing:0) {
                Capsule().fill(Color.white.opacity(0.2)).frame(width:36,height:4).padding(.vertical,12)
                Text("Select Object").font(.system(size:16,weight:.bold)).padding(.bottom,14)
                ScrollView(.horizontal,showsIndicators:false) {
                    HStack(spacing:11) {
                        ForEach(FurnitureItem.catalog.prefix(18)) { item in
                            Button { sel=item; shown=false; UISelectionFeedbackGenerator().selectionChanged() } label: {
                                VStack(spacing:6) {
                                    Text(item.emoji).font(.system(size:30)).frame(width:62,height:62)
                                        .background(sel?.id==item.id ? Color(red:0.5,green:0.25,blue:1).opacity(0.28) : Color.white.opacity(0.08))
                                        .cornerRadius(13)
                                        .overlay(RoundedRectangle(cornerRadius:13).stroke(sel?.id==item.id ? Color(red:0.5,green:0.25,blue:1) : Color.clear,lineWidth:2))
                                    Text(item.name).font(.system(size:10,weight:.medium)).foregroundColor(.white.opacity(0.65)).lineLimit(1)
                                }.frame(width:70)
                            }
                        }
                    }.padding(.horizontal,18).padding(.bottom,36)
                }
            }
            .background(Color(red:0.08,green:0.08,blue:0.13)).cornerRadius(22,corners:[.topLeft,.topRight])
        }.ignoresSafeArea()
    }
}

// MARK: AR Container (UIViewRepresentable)
struct ARContainer: UIViewRepresentable {
    @ObservedObject var arVM: ARViewModel
    func makeUIView(context:Context) -> ARView {
        let v = ARView(frame:.zero)
        arVM.setup(v)
        let tap = UITapGestureRecognizer(target:context.coordinator,action:#selector(Coordinator.tap(_:)))
        v.addGestureRecognizer(tap)
        return v
    }
    func updateUIView(_ v:ARView,context:Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(arVM:arVM) }
    class Coordinator: NSObject {
        let arVM: ARViewModel
        init(arVM:ARViewModel){self.arVM=arVM}
        @MainActor @objc func tap(_ g: UITapGestureRecognizer) {
            guard let view = g.view as? ARView else { return }
            Task { @MainActor in arVM.handleTap(at:g.location(in:view),in:view) }
        }
    }
}

// MARK: AR View Model
@MainActor
final class ARViewModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var tracking = false
    @Published var placed = 0
    @Published var showToast = false
    @Published var toastMsg = ""

    private var arView: ARView?
    weak var session: ARSession? { arView?.session }
    private var anchors: [(AnchorEntity,FurnitureItem)] = []
    private var lastItem: FurnitureItem? = FurnitureItem.catalog.first

    func setup(_ v: ARView) {
        arView = v; v.session.delegate = self
        let cfg = ARWorldTrackingConfiguration()
        cfg.planeDetection = [.horizontal,.vertical]
        cfg.environmentTexturing = .automatic
        v.session.run(cfg, options:[.resetTracking,.removeExistingAnchors])
        v.environment.lighting.intensityExponent = 1.0
        let co = ARCoachingOverlayView()
        co.goal = .horizontalPlane; co.session = v.session
        co.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        v.addSubview(co)
    }

    func placeFromCenter(item: FurnitureItem) {
        guard let v=arView else{return}
        let c=CGPoint(x:v.bounds.midX,y:v.bounds.midY)
        let results=v.raycast(from:c,allowing:.estimatedPlane,alignment:.horizontal)
        guard let r=results.first else { toast("⚠️ No surface detected"); return }
        doPlace(item:item,transform:r.worldTransform,in:v)
    }

    func handleTap(at pt:CGPoint,in v:ARView) {
        let results=v.raycast(from:pt,allowing:.estimatedPlane,alignment:.horizontal)
        guard let r=results.first,let item=lastItem else{return}
        doPlace(item:item,transform:r.worldTransform,in:v)
        UIImpactFeedbackGenerator(style:.medium).impactOccurred()
    }

    private func doPlace(item:FurnitureItem,transform:simd_float4x4,in v:ARView) {
        lastItem=item
        let anchor=AnchorEntity(world:transform)
        let w=item.width; let h=max(item.height*0.5,0.2); let d=item.depth
        let mesh=MeshResource.generateBox(size:SIMD3<Float>(w,h,d),cornerRadius:item.category == .seating ? 0.05 : 0.01)
        var mat=SimpleMaterial()
        mat.color = .init(tint:item.material.uiColor.withAlphaComponent(0.92))
        mat.roughness = MaterialScalarParameter(floatLiteral:item.material.roughness)
        mat.metallic  = MaterialScalarParameter(floatLiteral:item.material.metallic)
        let ent=ModelEntity(mesh:mesh,materials:[mat])
        ent.position=SIMD3<Float>(0,h/2,0)
        ent.generateCollisionShapes(recursive:true)
        anchor.addChild(ent); v.scene.addAnchor(anchor)
        anchors.append((anchor,item)); placed=anchors.count
        toast("✦ \(item.name) placed")
    }

    func rotateLast(by deg:Float) {
        guard let last=anchors.last else{return}
        last.0.children.first?.transform.rotation *= simd_quatf(angle:deg * .pi/180,axis:SIMD3<Float>(0,1,0))
    }

    func removeLast() {
        guard let last=anchors.last else{return}
        arView?.scene.removeAnchor(last.0); anchors.removeLast(); placed=anchors.count
        UIImpactFeedbackGenerator(style:.medium).impactOccurred(); toast("↩ Removed")
    }

    func reset() {
        for (a,_) in anchors { arView?.scene.removeAnchor(a) }
        anchors.removeAll(); placed=0
        let cfg=ARWorldTrackingConfiguration(); cfg.planeDetection=[.horizontal,.vertical]
        arView?.session.run(cfg,options:[.resetTracking,.removeExistingAnchors])
        tracking=false; UINotificationFeedbackGenerator().notificationOccurred(.success); toast("🔄 Reset")
    }

    func snapshot() {
        guard let arView = arView else { return }
        arView.snapshot(saveToHDR:false) { image in
            guard let image = image else { return }
            UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil)
            DispatchQueue.main.async {
                self.toast("📸 Saved to Photos")
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    func toast(_ msg:String) {
        toastMsg=msg; withAnimation{showToast=true}
        DispatchQueue.main.asyncAfter(deadline:.now()+2.5){ withAnimation{self.showToast=false} }
    }

    nonisolated func session(_ s:ARSession,didAdd anchors:[ARAnchor]) {
        if anchors.contains(where:{$0 is ARPlaneAnchor}) { DispatchQueue.main.async { self.tracking=true } }
    }
    nonisolated func session(_ s:ARSession,didFailWithError e:Error) {
        DispatchQueue.main.async { self.toast("⚠️ AR: \(e.localizedDescription)") }
    }
    nonisolated func sessionInterruptionEnded(_ s:ARSession) {
        let cfg=ARWorldTrackingConfiguration(); cfg.planeDetection=[.horizontal,.vertical]
        s.run(cfg,options:.resetTracking)
    }
}

// ================================================================
// MARK: — SHARED COMPONENTS
// ================================================================

struct BackBtn: View {
    let action: ()->Void
    var body: some View {
        Button { UIImpactFeedbackGenerator(style:.light).impactOccurred(); action() } label: {
            Image(systemName:"chevron.left").font(.system(size:15,weight:.semibold)).foregroundColor(.white.opacity(0.7))
                .frame(width:40,height:40).background(Color.white.opacity(0.08)).clipShape(Circle())
        }
    }
}

struct Toast: View {
    let msg:String
    var body: some View {
        Text(msg).font(.system(size:14,weight:.semibold)).foregroundColor(.white)
            .padding(.horizontal,20).padding(.vertical,12)
            .background(Color(red:0.14,green:0.14,blue:0.2).opacity(0.95)).cornerRadius(30)
            .shadow(color:.black.opacity(0.28),radius:14,y:5)
            .overlay(Capsule().stroke(Color.white.opacity(0.08),lineWidth:1))
    }
}

// Corner radius helper
extension View {
    func cornerRadius(_ r:CGFloat,corners:UIRectCorner)->some View { clipShape(RCorner(r:r,c:corners)) }
}
struct RCorner:Shape {
    let r:CGFloat; let c:UIRectCorner
    func path(in rect:CGRect)->Path { Path(UIBezierPath(roundedRect:rect,byRoundingCorners:c,cornerRadii:CGSize(width:r,height:r)).cgPath) }
}
