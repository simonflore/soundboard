import SwiftUI

struct GridView: View {
    @Environment(AppState.self) private var appState

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var gridSpacing: CGFloat { horizontalSizeClass == .compact ? 3 : 6 }
    private var gridPadding: CGFloat { horizontalSizeClass == .compact ? 6 : 14 }
    private var sideColumnWidth: CGFloat { horizontalSizeClass == .compact ? 16 : 24 }
    private var topRowHeight: CGFloat { horizontalSizeClass == .compact ? 32 : 40 }
    #else
    private let gridSpacing: CGFloat = 6
    private let gridPadding: CGFloat = 14
    private let sideColumnWidth: CGFloat = 24
    private let topRowHeight: CGFloat = 40
    #endif

    private var dragHintText: Text {
        #if os(macOS)
        Text(appState.isEditMode ? "drag to rearrange" : "⌥ drag to rearrange")
        #else
        Text(appState.isEditMode ? "hold & drag to rearrange" : "")
        #endif
    }

    var body: some View {
        VStack(spacing: gridSpacing) {
            // Top row: 8 control buttons
            topRow
                .frame(height: topRowHeight)

            // Main area: 8x8 grid + optional side column
            HStack(spacing: gridSpacing) {
                // 8x8 pad grid
                padGrid
                    .aspectRatio(1, contentMode: .fit)

                // Side column: dry/wet meter (only when vocal pad exists)
                if appState.vocalPadPosition != nil {
                    sideColumn
                        .frame(width: sideColumnWidth)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: appState.vocalPadPosition != nil)
        }
        .overlay(alignment: .bottomTrailing) {
            dragHintText
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.2))
                .padding(.trailing, 18)
                .padding(.bottom, 4)
        }
        .overlay(alignment: .top) {
            if let active = appState.activeInstrument {
                InstrumentStatusBar(
                    instrumentType: active.type,
                    onExit: { appState.exitInstrumentMode() }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: appState.activeInstrument != nil)
                .padding(.top, topRowHeight + gridSpacing)
            }
        }
        .overlay(alignment: .trailing) {
            if let indicator = appState.sideButtonIndicator {
                SideButtonIndicatorView(indicator: indicator)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .padding(.trailing, 14)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: appState.sideButtonIndicator)
        .padding(gridPadding)
        .background(
            ZStack {
                // Deep dark gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.06, blue: 0.12),
                        Color(red: 0.03, green: 0.03, blue: 0.08),
                        Color(red: 0.02, green: 0.02, blue: 0.05),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Subtle radial highlight in center (stage light feel)
                RadialGradient(
                    colors: [
                        Color.blue.opacity(0.04),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 400
                )

                // Dot grid pattern overlay
                DotGridPattern()
                    .opacity(0.15)
            }
        )
    }

    // MARK: - Top Row

    private var topRow: some View {
        HStack(spacing: gridSpacing) {
            // 0: Up (unused)
            ControlButtonView(
                icon: "chevron.up", label: "Up",
                accentColor: .gray, isEnabled: false
            ) {}

            // 1: Down (unused)
            ControlButtonView(
                icon: "chevron.down", label: "Down",
                accentColor: .gray, isEnabled: false
            ) {}

            // 2: Left — Dry/Wet Down
            ControlButtonView(
                icon: "chevron.left", label: "Dry",
                accentColor: Color(red: 0.2, green: 0.6, blue: 1.0),
                isEnabled: appState.vocalPadPosition != nil
            ) {
                appState.handleTopButton(index: 2)
            }

            // 3: Right — Dry/Wet Up
            ControlButtonView(
                icon: "chevron.right", label: "Wet",
                accentColor: Color(red: 0.2, green: 0.6, blue: 1.0),
                isEnabled: appState.vocalPadPosition != nil
            ) {
                appState.handleTopButton(index: 3)
            }

            // 4: Play/Edit toggle
            ControlButtonView(
                icon: appState.isEditMode ? "pencil" : "play.fill",
                label: appState.isEditMode ? "Edit" : "Play",
                accentColor: appState.isEditMode ? .orange : .green,
                isActive: true
            ) {
                appState.handleTopButton(index: 4)
            }

            // 5: Mic toggle
            ControlButtonView(
                icon: appState.isMicActive ? "mic.fill" : "mic.slash",
                label: "Mic",
                accentColor: .pink,
                isActive: appState.isMicActive,
                isEnabled: appState.vocalPadPosition != nil
            ) {
                appState.handleTopButton(index: 5)
            }

            // 6: Stop All
            ControlButtonView(
                icon: "stop.fill", label: "Stop",
                accentColor: .red
            ) {
                appState.handleTopButton(index: 6)
            }

            // 7: Record / Exit Instrument
            ControlButtonView(
                icon: appState.activeInstrument != nil ? "xmark.circle.fill" : "record.circle",
                label: appState.activeInstrument != nil ? "Exit" : "Rec",
                accentColor: .red,
                isActive: appState.activeInstrument != nil
            ) {
                appState.handleTopButton(index: 7)
            }
        }
    }

    // MARK: - Pad Grid

    private var padGrid: some View {
        VStack(spacing: gridSpacing) {
            ForEach((0..<8).reversed(), id: \.self) { row in
                HStack(spacing: gridSpacing) {
                    ForEach(0..<8, id: \.self) { col in
                        PadView(position: GridPosition(row: row, column: col))
                    }
                }
            }
        }
    }

    // MARK: - Side Column (Dry/Wet Meter)

    private var sideColumn: some View {
        VStack(spacing: gridSpacing) {
            ForEach((0..<8).reversed(), id: \.self) { level in
                SideIndicatorView(
                    level: level,
                    activeStep: appState.dryWetStep,
                    hasVocalPad: appState.vocalPadPosition != nil
                )
            }
        }
    }
}

/// Subtle dot grid pattern for arena/stage floor feel
struct DotGridPattern: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 20
            let dotSize: CGFloat = 1.0

            for x in stride(from: spacing / 2, to: size.width, by: spacing) {
                for y in stride(from: spacing / 2, to: size.height, by: spacing) {
                    let rect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white.opacity(0.3))
                    )
                }
            }
        }
    }
}
