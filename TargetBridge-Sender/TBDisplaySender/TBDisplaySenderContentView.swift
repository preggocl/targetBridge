import AppKit
import Combine
import SwiftUI

@MainActor
private final class TBDisplaySenderSidePanelController: NSObject, NSWindowDelegate {
    private enum Route: Equatable {
        case general
        case session(UUID)
    }

    static let shared = TBDisplaySenderSidePanelController()

    private weak var parentWindow: NSWindow?
    private var panel: NSPanel?
    private var route: Route?
    private var observers: [NSObjectProtocol] = []

    func toggleGeneral(service: TBDisplaySenderService) {
        toggle(.general, service: service)
    }

    func toggleSession(_ session: TBDisplaySenderSession, service: TBDisplaySenderService) {
        toggle(.session(session.id), service: service)
    }

    private func toggle(_ newRoute: Route, service: TBDisplaySenderService) {
        if route == newRoute, panel?.isVisible == true {
            close()
            return
        }

        guard let parent = NSApp.keyWindow ?? NSApp.mainWindow else { return }
        route = newRoute
        let content: AnyView
        let panelTitle: String
        switch newRoute {
        case .general:
            panelTitle = "TargetBridge Intel Sender — \(generalSettingsTitle(service.language))"
            content = AnyView(TBDisplaySenderSettingsView(service: service))
        case .session(let id):
            guard let session = service.sessions.first(where: { $0.id == id }) else { return }
            panelTitle = service.sessionTitle(for: session)
            content = AnyView(TBDisplaySenderSessionSettingsSheet(service: service, session: session) { [weak self] in
                self?.close()
            })
        }

        show(content, attachedTo: parent)
        panel?.title = panelTitle
    }

    private func generalSettingsTitle(_ language: TBDisplaySenderLanguage) -> String {
        language == .spanish ? "Ajustes" : "Settings"
    }

    private func show(_ content: AnyView, attachedTo parent: NSWindow) {
        let panel = panel ?? makePanel()
        self.panel = panel
        panel.contentViewController = NSHostingController(rootView: content)

        if parentWindow !== parent {
            detachFromParent()
            parentWindow = parent
            parent.addChildWindow(panel, ordered: .above)
            observe(parent)
        }

        positionPanel()
        panel.orderFront(nil)
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 410, height: 700),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.titleVisibility = .visible
        panel.titlebarAppearsTransparent = false
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.isMovableByWindowBackground = false
        panel.minSize = NSSize(width: 440, height: 420)
        panel.maxSize = NSSize(width: 540, height: 1_400)
        panel.delegate = self
        return panel
    }

    private func observe(_ parent: NSWindow) {
        let center = NotificationCenter.default
        for name in [NSWindow.didMoveNotification, NSWindow.didResizeNotification, NSWindow.didChangeScreenNotification] {
            observers.append(center.addObserver(forName: name, object: parent, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.positionPanel() }
            })
        }
    }

    private func positionPanel() {
        guard let parent = parentWindow, let panel, let screen = parent.screen else { return }
        let visible = screen.visibleFrame
        let parentFrame = parent.frame
        let rightSpace = visible.maxX - parentFrame.maxX
        let leftSpace = parentFrame.minX - visible.minX
        let availableSide = max(rightSpace, leftSpace)
        let width = min(510, max(440, availableSide - 8))
        let height = min(parentFrame.height, visible.height)
        let useRight = rightSpace >= width || rightSpace >= leftSpace
        let proposedX = useRight ? parentFrame.maxX + 1 : parentFrame.minX - width - 1
        let x = min(max(proposedX, visible.minX), visible.maxX - width)
        let y = min(parentFrame.maxY, visible.maxY) - height
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }

    func close() {
        panel?.orderOut(nil)
        route = nil
        detachFromParent()
    }

    private func detachFromParent() {
        if let panel, let parentWindow {
            parentWindow.removeChildWindow(panel)
        }
        observers.forEach(NotificationCenter.default.removeObserver)
        observers.removeAll()
        parentWindow = nil
    }

    func windowWillClose(_ notification: Notification) {
        route = nil
        detachFromParent()
    }
}

@MainActor
private final class TBTelemetryPanelController: NSObject, NSWindowDelegate {
    static let shared = TBTelemetryPanelController()
    private var panel: NSPanel?
    private weak var parentWindow: NSWindow?
    private var observers: [NSObjectProtocol] = []

    func toggle(session: TBDisplaySenderSession, service: TBDisplaySenderService) {
        if panel?.isVisible == true {
            close()
            return
        }
        guard let parent = NSApp.keyWindow ?? NSApp.mainWindow else { return }
        let panel = panel ?? NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 820, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "\(service.sessionTitle(for: session)) — Telemetry"
        panel.minSize = NSSize(width: 560, height: 190)
        panel.maxSize = NSSize(width: 1_200, height: 360)
        panel.isReleasedWhenClosed = false
        panel.isMovable = false
        panel.isMovableByWindowBackground = false
        panel.delegate = self
        panel.contentViewController = NSHostingController(rootView: TBTelemetryPanelView(session: session))
        self.panel = panel
        if parentWindow !== parent {
            detachFromParent()
            parentWindow?.removeChildWindow(panel)
            parentWindow = parent
            parent.addChildWindow(panel, ordered: .above)
            observe(parent)
        }
        positionPanel()
        panel.orderFront(nil)
    }

    private func observe(_ parent: NSWindow) {
        let center = NotificationCenter.default
        for name in [NSWindow.didMoveNotification, NSWindow.didResizeNotification, NSWindow.didChangeScreenNotification] {
            observers.append(center.addObserver(forName: name, object: parent, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.positionPanel() }
            })
        }
    }

    private func positionPanel() {
        guard let parent = parentWindow, let panel else { return }
        let visible = parent.screen?.visibleFrame ?? parent.frame
        let width = min(max(parent.frame.width, 680), visible.width)
        let height: CGFloat = 220
        let proposedY = parent.frame.minY - height - 1
        let y = max(visible.minY, proposedY)
        let x = min(max(parent.frame.midX - width / 2, visible.minX), visible.maxX - width)
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }

    func close() {
        panel?.orderOut(nil)
        detachFromParent()
    }

    private func detachFromParent() {
        if let panel, let parentWindow { parentWindow.removeChildWindow(panel) }
        observers.forEach(NotificationCenter.default.removeObserver)
        observers.removeAll()
        parentWindow = nil
    }

    func windowWillClose(_ notification: Notification) { close() }
}

private struct TBTelemetryPanelView: View {
    @ObservedObject var session: TBDisplaySenderSession
    @State private var fpsHistory: [Double] = Array(repeating: 0, count: 60)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 18) {
            metric("FPS", "\(session.senderFPS)", .green)
            metric("Codec", session.menuBarCodecLabel ?? "—", .cyan)
            metric("Bitrate", "\(session.capturePreset.averageBitRate / 1_000_000) Mbps", .orange)
            metric("Stream", "\(session.capturePreset.width) × \(session.capturePreset.height)", .primary)

            VStack(alignment: .leading, spacing: 6) {
                Text("FPS · últimos 60 segundos")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Canvas { context, size in
                    guard fpsHistory.count > 1 else { return }
                    var path = Path()
                    for (index, value) in fpsHistory.enumerated() {
                        let x = size.width * CGFloat(index) / CGFloat(fpsHistory.count - 1)
                        let y = size.height * (1 - CGFloat(min(max(value, 0), 60)) / 60)
                        index == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                    }
                    context.stroke(path, with: .color(.green), lineWidth: 2)
                }
                .background(Color.green.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.25)))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .onReceive(timer) { _ in
            fpsHistory.removeFirst()
            fpsHistory.append(Double(session.senderFPS))
        }
    }

    private func metric(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased()).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
            Text(value).font(.system(.body, design: .rounded, weight: .semibold)).foregroundStyle(color)
        }
        .frame(minWidth: 86, alignment: .leading)
    }
}

struct TBDisplaySenderContentView: View {
    @ObservedObject var service: TBDisplaySenderService
    @State private var showingAbout = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard
                controlDeck

                ForEach(service.sessions) { session in
                    TBDisplaySenderSessionCard(service: service, session: session) {
                        TBDisplaySenderSidePanelController.shared.toggleSession(session, service: service)
                    }
                }

                HStack {
                    Spacer()
                    Text("\(TBDisplaySenderL10n.versionLabel(service.language)) \(TBDisplaySenderBuildInfo.versionDisplay)")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.black.opacity(0.02))
        .task {
            service.refreshLocalInterfaces()
        }
        .sheet(isPresented: $showingAbout) {
            TBDisplaySenderAboutView(service: service)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showingAbout = true
                } label: {
                    Label(aboutToolbarTitle, systemImage: "info.circle")
                }

                Button {
                    TBDisplaySenderSidePanelController.shared.toggleGeneral(service: service)
                } label: {
                    Label(settingsToolbarTitle, systemImage: "slider.horizontal.3")
                }
            }
        }
    }

    private var headerCard: some View {
        SurfaceCard {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.28),
                                    Color.cyan.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "display.2")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(TBDisplaySenderL10n.appName(service.language))
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                        Text("INTEL SENDER")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.green.opacity(0.12)))
                    }
                    Text(TBDisplaySenderL10n.appSubtitle(service.language))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 16)

                VStack(alignment: .trailing, spacing: 8) {
                    statusChip(
                        service.summaryStatusText(),
                        tint: service.anyStreaming ? .green : .secondary
                    )
                    if let activeInterfaceText {
                        Text(activeInterfaceText)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }

    private var controlDeck: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        sectionHeading(TBDisplaySenderL10n.connectionGroup(service.language))
                        Text(TBDisplaySenderL10n.multiSessionHint(service.language))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Button(TBDisplaySenderL10n.addSessionButton(service.language)) {
                            service.addSession()
                        }
                        .buttonStyle(.borderedProminent)

                        Button(TBDisplaySenderL10n.refreshIPButton(service.language)) {
                            service.refreshLocalInterfaces()
                        }
                        .buttonStyle(.bordered)

                        Button(TBDisplaySenderL10n.stopAllButton(service.language)) {
                            service.stopAll()
                        }
                        .buttonStyle(.bordered)
                        .disabled(!service.anyConnected)
                    }
                }

                SurfaceSubcard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(TBDisplaySenderL10n.availableLocalInterfaces(service.language))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(service.localInterfaces) { localInterface in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(activeInterfaceIPs.contains(localInterface.ip) ? Color.green : Color.secondary.opacity(0.45))
                                        .frame(width: 7, height: 7)
                                    Text(localInterface.displayText(service.language))
                                        .font(.system(.body, design: .monospaced))
                                        .textSelection(.enabled)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var activeInterfaceIPs: Set<String> {
        Set(service.sessions.filter { $0.isConnected || $0.isStreaming }.map(\.localInterfaceIP))
    }

    private var activeInterfaceText: String? {
        guard let session = service.sessions.first(where: { $0.isConnected || $0.isStreaming }) else { return nil }
        return service.interfaceDisplayText(for: session.localInterfaceIP)
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(.caption, design: .rounded, weight: .bold))
            .tracking(1.1)
            .foregroundStyle(.secondary)
    }

    private func statusChip(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(.footnote, design: .rounded, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.12))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(tint.opacity(0.28), lineWidth: 1)
            )
    }

    private var settingsToolbarTitle: String {
        switch service.language {
        case .italian: return "Impostazioni"
        case .english, .spanish: return "Settings"
        case .german: return "Einstellungen"
        case .french: return "Réglages"
        case .chinese: return "设置"
        }
    }

    private var aboutToolbarTitle: String {
        switch service.language {
        case .italian: return "About"
        case .english, .spanish: return "About"
        case .german: return "Info"
        case .french: return "À propos"
        case .chinese: return "关于"
        }
    }
}

private struct TBDisplaySenderSessionCard: View {
    @ObservedObject var service: TBDisplaySenderService
    @ObservedObject var session: TBDisplaySenderSession
    let showSettings: () -> Void

    private let summaryColumns = [
        GridItem(.adaptive(minimum: 180), spacing: 12)
    ]

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                topBar
                summaryGrid
                if session.isConnected {
                    brightnessCard
                }
                if session.isConnected && session.audioEnabled {
                    volumeCard
                }
                monitorDetailsCard
            }
        }
    }

    private var topBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.sessionTitle(for: session))
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                    Text(session.statusText)
                        .font(.subheadline)
                        .foregroundStyle(session.isStreaming ? .green : .secondary)
                }

                Spacer(minLength: 12)

                statusChip
            }

            HStack(spacing: 10) {
                Button {
                    if session.isConnected {
                        session.stop()
                    } else {
                        session.connect()
                    }
                } label: {
                    Label(
                        session.isConnected ? TBDisplaySenderL10n.stopButton(service.language) : TBDisplaySenderL10n.connectButton(service.language),
                        systemImage: session.isConnected ? "stop.fill" : "play.fill"
                    )
                    .frame(minWidth: 150)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!session.isConnected && (trimmedReceiverIP.isEmpty || session.localInterfaceIP.isEmpty))

                Button {
                    showSettings()
                } label: {
                    Label(TBDisplaySenderL10n.showSettings(service.language), systemImage: "gearshape.2")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(TBDisplaySenderL10n.removeSessionButton(service.language)) {
                    service.removeSession(session)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(service.sessions.count == 1 || session.isConnected || session.isStreaming)
            }
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: summaryColumns, alignment: .leading, spacing: 12) {
            summaryTile(
                title: transportTitle,
                value: session.transportKind.title(service.language),
                subtitle: service.interfaceDisplayText(for: session.localInterfaceIP)
            )

            summaryTile(
                title: receiverTitle,
                value: session.receiverDisplayName.isEmpty ? TBDisplaySenderL10n.notDetected(service.language) : session.receiverDisplayName,
                subtitle: session.receiverSubtitle
            )

            summaryTile(
                title: sourceTitle,
                value: session.captureSource.title(service.language),
                subtitle: session.streamResolutionText
            )

            telemetryTile
        }
    }

    private var telemetryTile: some View {
        SurfaceSubcard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    sectionHeading(fpsTitle)
                    Spacer()
                    Button {
                        TBTelemetryPanelController.shared.toggle(session: session, service: service)
                    } label: {
                        Image(systemName: "chart.xyaxis.line")
                    }
                    .buttonStyle(.borderless)
                    .help("Open live telemetry")
                }
                Text("\(session.senderFPS)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(session.isStreaming ? .green : .secondary)
                Text(session.isStreaming ? liveSubtitle : idleSubtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var monitorDetailsCard: some View {
        SurfaceSubcard {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeading(sessionMonitorTitle)

                VStack(alignment: .leading, spacing: 8) {
                    infoRow(TBDisplaySenderL10n.receiverLabel(service.language), session.receiverPanelText)
                    infoRow(TBDisplaySenderL10n.virtualDisplayLabel(service.language), session.virtualDisplayText)
                    infoRow(TBDisplaySenderL10n.streamLabel(service.language), session.streamResolutionText)
                    infoRow(TBDisplaySenderL10n.fpsLabel(service.language), "\(session.senderFPS)")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var brightnessCard: some View {
        SurfaceSubcard {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeading(brightnessTitle)
                HStack(spacing: 12) {
                    Image(systemName: "sun.min.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)

                    Slider(value: $session.brightness, in: 0.0...1.0)
                        .tint(.orange)

                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)

                    Text("\(Int((session.brightness * 100).rounded()))%")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 44, alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var volumeCard: some View {
        SurfaceSubcard {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeading(volumeTitle)
                HStack(spacing: 12) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)

                    Slider(value: $session.volume, in: 0.0...1.0)
                        .tint(.blue)

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)

                    Text("\(Int((session.volume * 100).rounded()))%")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 44, alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var trimmedReceiverIP: String {
        session.receiverIP.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var statusChip: some View {
        Text(chipText)
            .font(.system(.footnote, design: .rounded, weight: .bold))
            .foregroundStyle(chipTint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(chipTint.opacity(0.12))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(chipTint.opacity(0.28), lineWidth: 1)
            )
    }

    private var chipText: String {
        if session.isStreaming { return liveTitle }
        if session.isConnected { return connectedTitle }
        return idleTitle
    }

    private var chipTint: Color {
        if session.isStreaming { return .green }
        if session.isConnected { return .orange }
        return .secondary
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(.caption, design: .rounded, weight: .bold))
            .tracking(1.0)
            .foregroundStyle(.secondary)
    }

    private func summaryTile(title: String, value: String, subtitle: String, accent: Color = .primary) -> some View {
        SurfaceSubcard {
            VStack(alignment: .leading, spacing: 8) {
                sectionHeading(title)
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(accent)
                    .lineLimit(2)
                    .textSelection(.enabled)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var transportTitle: String {
        switch service.language {
        case .italian: return "Trasporto"
        case .english, .spanish: return "Transport"
        case .german: return "Transport"
        case .french: return "Transport"
        case .chinese: return "传输"
        }
    }

    private var receiverTitle: String {
        switch service.language {
        case .italian: return "Receiver"
        case .english, .spanish: return "Receiver"
        case .german: return "Empfänger"
        case .french: return "Receiver"
        case .chinese: return "接收端"
        }
    }

    private var sourceTitle: String {
        switch service.language {
        case .italian: return "Modalità"
        case .english, .spanish: return "Mode"
        case .german: return "Modus"
        case .french: return "Mode"
        case .chinese: return "模式"
        }
    }

    private var fpsTitle: String {
        switch service.language {
        case .italian: return "Telemetria"
        case .english, .spanish: return "Telemetry"
        case .german: return "Telemetrie"
        case .french: return "Télémétrie"
        case .chinese: return "遥测"
        }
    }

    private var brightnessTitle: String {
        switch service.language {
        case .italian: return "Luminosità"
        case .english, .spanish: return "Brightness"
        case .german: return "Helligkeit"
        case .french: return "Luminosité"
        case .chinese: return "亮度"
        }
    }

    private var volumeTitle: String {
        switch service.language {
        case .italian: return "Volume"
        case .english, .spanish: return "Volume"
        case .german: return "Lautstärke"
        case .french: return "Volume"
        case .chinese: return "音量"
        }
    }

    private var liveSubtitle: String {
        switch service.language {
        case .italian: return "Frame in invio"
        case .english, .spanish: return "Frames currently sending"
        case .german: return "Frames werden gesendet"
        case .french: return "Images en cours d’envoi"
        case .chinese: return "正在发送画面帧"
        }
    }

    private var idleSubtitle: String {
        switch service.language {
        case .italian: return "Nessuno stream attivo"
        case .english, .spanish: return "No active stream"
        case .german: return "Kein aktiver Stream"
        case .french: return "Aucun flux actif"
        case .chinese: return "当前没有活动流"
        }
    }

    private var sessionMonitorTitle: String {
        switch service.language {
        case .italian: return "Sessione monitor"
        case .english, .spanish: return "Monitor Session"
        case .german: return "Monitor-Sitzung"
        case .french: return "Moniteur de session"
        case .chinese: return "显示会话"
        }
    }

    private var liveTitle: String {
        TBDisplaySenderL10n.statusChipLive(service.language)
    }

    private var connectedTitle: String {
        TBDisplaySenderL10n.statusChipConnected(service.language)
    }

    private var idleTitle: String {
        TBDisplaySenderL10n.statusChipIdle(service.language)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 138, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct TBDisplaySenderSessionSettingsSheet: View {
    @ObservedObject var service: TBDisplaySenderService
    @ObservedObject var session: TBDisplaySenderSession
    let close: () -> Void
    @State private var configurationChecks: [TBConfigurationCheck] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                settingsSection(title: connectionSettingsTitle) {
                    settingRow(TBDisplaySenderL10n.transportKind(service.language), details: transportDetails) {
                        Picker(TBDisplaySenderL10n.transportKind(service.language), selection: $session.transportKind) {
                            ForEach(service.availableTransportKinds) { transportKind in
                                Text(transportKind.title(service.language)).tag(transportKind)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .onChange(of: session.transportKind) { _, _ in
                            service.transportDidChange(for: session)
                        }
                        .disabled(session.isConnected || session.isStreaming)
                    }

                    settingRow(TBDisplaySenderL10n.localInterfaceIP(service.language), details: localInterfaceDetails) {
                        Picker(TBDisplaySenderL10n.localInterfaceIP(service.language), selection: $session.localInterfaceIP) {
                            Text(TBDisplaySenderL10n.notDetected(service.language)).tag("")
                            ForEach(service.availableInterfaces(for: session.transportKind)) { localInterface in
                                Text(localInterface.displayText(service.language)).tag(localInterface.ip)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .disabled(session.isConnected || session.isStreaming)
                    }

                    settingRow(TBDisplaySenderL10n.discoveredReceiver(service.language), details: discoveryDetails) {
                        Picker(TBDisplaySenderL10n.discoveredReceiver(service.language), selection: $session.selectedReceiverID) {
                            Text(TBDisplaySenderL10n.manualReceiverEntry(service.language)).tag("")
                            ForEach(service.discoveredReceivers) { receiver in
                                Text(receiver.displayText).tag(receiver.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .onChange(of: session.selectedReceiverID) { _, newValue in
                            guard let receiver = service.discoveredReceivers.first(where: { $0.id == newValue }) else { return }
                            service.applyDiscoveredReceiver(receiver, to: session)
                        }
                        .disabled(session.isConnected || session.isStreaming)
                    }

                    settingRow(TBDisplaySenderL10n.receiverIP(service.language), details: receiverDetails) {
                        TextField("169.254.x.x / 192.168.x.x", text: $session.receiverIP)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                            .disabled(session.isConnected || session.isStreaming)
                    }
                }

                settingsSection(title: outputSettingsTitle) {
                    settingRow(TBDisplaySenderL10n.displayProfiles(service.language), details: TBDisplaySenderL10n.displayProfilesHint(service.language)) {
                        HStack(spacing: 5) {
                            ForEach(TBDisplayProfile.allCases) { profile in
                                Button(TBDisplaySenderL10n.displayProfileTitle(profile, language: service.language)) {
                                    service.applyDisplayProfile(profile, to: session)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .font(.caption)
                                .fixedSize(horizontal: true, vertical: false)
                                .disabled(session.isConnected || session.isStreaming)
                            }
                        }
                    }
                    settingRow(TBDisplaySenderL10n.captureSource(service.language), details: captureModeDetails) {
                        Picker(TBDisplaySenderL10n.captureSource(service.language), selection: $session.captureSource) {
                            ForEach(TBDisplayCaptureSource.allCases) { source in
                                Text(source.title(service.language)).tag(source)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .disabled(session.isConnected || session.isStreaming)
                    }

                    settingRow(TBDisplaySenderL10n.streamProfile(service.language), details: streamProfileDetails) {
                        Picker(TBDisplaySenderL10n.streamProfile(service.language), selection: $session.capturePreset) {
                            ForEach(TBDisplayCapturePreset.allCases, id: \.self) { preset in
                                Text("\(preset.title(service.language)) · \(preset.description)").tag(preset)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .disabled(session.isConnected || session.isStreaming)
                    }

                    if session.captureSource == .extendedDesktop {
                        settingRow(renderMatchingTitle, details: renderMatchingDetails) {
                            Toggle("", isOn: $session.matchRenderToStream)
                                .labelsHidden()
                                .disabled(session.isConnected || session.isStreaming)
                        }
                    }

                    if service.audioRelayAvailable {
                        settingRow(TBDisplaySenderL10n.streamAudio(service.language), details: audioDetails) {
                            Toggle("", isOn: $session.audioEnabled)
                                .labelsHidden()
                                .disabled(session.isConnected || session.isStreaming)
                        }
                    }

                    settingRow("RAW NV12 (experimental)", details: "Bypasses H.264/HEVC for lower codec latency. Requires Receiver support and about 6.8 Gbit/s at 4K60; disable it if frames drop or the link is unstable.") {
                        Toggle("", isOn: $session.rawNV12Experimental)
                            .labelsHidden()
                            .disabled(session.isConnected || session.isStreaming)
                    }

                    if service.inputDockstationAvailable {
                        settingRow(inputDockstationTitle, details: inputDockstationDetails) {
                            Picker(
                                inputDockstationTitle,
                                selection: Binding(
                                    get: { session.inputControlRole },
                                    set: { service.setInputControlRole($0, for: session) }
                                )
                            ) {
                                ForEach(TBInputControlRole.allCases) { role in
                                    Text(inputControlRoleTitle(role)).tag(role)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .disabled(!session.isConnected)
                        }

                        if session.inputControlRole == .senderMaster {
                            settingRow(inputGestureModeTitle, details: inputGestureModeDetails) {
                                Picker(
                                    inputGestureModeTitle,
                                    selection: $session.inputGestureMode
                                ) {
                                    ForEach(TBInputGestureMode.allCases) { mode in
                                        Text(inputGestureModeOptionTitle(mode)).tag(mode)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .disabled(!session.isConnected)
                            }
                        }

                        if session.inputControlRole == .receiverMaster {
                            SurfaceSubcard {
                                TBInputBindingsView(session: session, language: service.language)
                            }
                        }

                        if session.inputControlRole == .senderMaster, !service.localInputMonitoringTrusted {
                            SurfaceSubcard {
                                permissionWarningCard(
                                    title: localInputMonitoringWarningTitle,
                                    body: localInputMonitoringWarningBody,
                                    actionTitle: openInputMonitoringSettingsTitle,
                                    action: { service.openInputMonitoringSettings() },
                                    statusText: "listen=false"
                                )
                            }
                        }

                        if session.inputControlRole == .senderMaster, session.receiverAccessibilityTrustedHint == false {
                            SurfaceSubcard {
                                permissionWarningCard(
                                    title: receiverAccessibilityWarningTitle,
                                    body: receiverAccessibilityWarningBody,
                                    actionTitle: nil,
                                    action: nil,
                                    statusText: "receiver accessibility=false"
                                )
                            }
                        }

                        if session.inputControlRole == .receiverMaster, !service.localInputInjectionTrusted {
                            SurfaceSubcard {
                                permissionWarningCard(
                                    title: inputPermissionWarningTitle,
                                    body: inputPermissionWarningBody,
                                    actionTitle: openAccessibilitySettingsTitle,
                                    action: { service.openAccessibilitySettings() },
                                    statusText: inputPermissionStatusText
                                )
                            }
                        }

                        if session.inputControlRole == .receiverMaster, session.receiverInputMonitoringTrustedHint == false {
                            SurfaceSubcard {
                                permissionWarningCard(
                                    title: receiverInputMonitoringWarningTitle,
                                    body: receiverInputMonitoringWarningBody,
                                    actionTitle: nil,
                                    action: nil,
                                    statusText: "receiver input-monitoring=false"
                                )
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(TBDisplaySenderL10n.streamHint1(service.language))
                        Text(TBDisplaySenderL10n.streamHint2(service.language))
                            .foregroundStyle(.secondary)

                        if !service.discoveredReceivers.isEmpty {
                            Text(TBDisplaySenderL10n.discoveryHint(service.language))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                }

                settingsSection(title: diagnosticsTitle) {
                    SurfaceSubcard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(TBDisplaySenderL10n.text("sender.diagnostics.guided_title", service.language))
                                        .font(.subheadline.weight(.semibold))
                                    Text(TBDisplaySenderL10n.text("sender.diagnostics.guided_hint", service.language))
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                Button(TBDisplaySenderL10n.text("sender.diagnostics.check_configuration", service.language)) {
                                    configurationChecks = service.configurationChecks(for: session)
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            if !configurationChecks.isEmpty {
                                Divider().overlay(Color.white.opacity(0.08))
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(configurationChecks) { check in
                                        configurationCheckRow(check)
                                    }
                                }
                            }

                            Divider().overlay(Color.white.opacity(0.08))

                            HStack(spacing: 12) {
                                Button(action: {
                                    session.startCableTest()
                                }) {
                                    HStack(spacing: 6) {
                                        if session.isCableTesting {
                                            ProgressView()
                                                .progressViewStyle(.circular)
                                                .controlSize(.small)
                                        }
                                        Text(session.isCableTesting ? TBDisplaySenderL10n.testingButton(service.language) : TBDisplaySenderL10n.cableTestButton(service.language))
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(session.isConnected || session.isStreaming || session.isCableTesting || trimmedReceiverIP.isEmpty || session.localInterfaceIP.isEmpty)

                                Text(cableRateText)
                                    .font(.system(.body, design: .rounded, weight: .semibold))
                                    .foregroundStyle(cableRateColor)

                                Spacer()

                                Button(TBDisplaySenderL10n.restartCaptureButton(service.language)) {
                                    session.restartCaptureNow()
                                }
                                .buttonStyle(.bordered)
                                .disabled(!session.canRestartCapture)
                            }

                            Text(interfaceTestHint)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(service.localInterfaces) { localInterface in
                                    interfacePerformanceRow(localInterface)
                                }
                            }

                            Divider().overlay(Color.white.opacity(0.08))

                            VStack(alignment: .leading, spacing: 8) {
                                infoRow("Capture", session.captureDisplayText)
                                infoRow("State", session.displayStateText)
                            }
                        }
                    }
                }
            }
            .padding(24)
            .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.13, blue: 0.14),
                    Color(red: 0.08, green: 0.09, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        // The panel uses a fixed dark background, so force the dark color scheme:
        // otherwise in system Light mode the semantic text colors (.primary /
        // .secondary) resolve to dark variants and render dark-on-dark.
        .preferredColorScheme(.dark)
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeading(title)
                content()
            }
        }
    }

    private func settingRow<Content: View>(_ label: String, details: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                content()
                    .frame(maxWidth: 350, alignment: .trailing)
            }

            Text(details)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(.caption, design: .rounded, weight: .bold))
            .tracking(1.0)
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func permissionWarningCard(
        title: String,
        body: String,
        actionTitle: String?,
        action: (() -> Void)?,
        statusText: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(title)
                    .font(.subheadline.weight(.semibold))
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
            }

            Text(body)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                if let actionTitle, let action {
                    Button(actionTitle) {
                        action()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Text(statusText)
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var header: some View {
        SurfaceCard {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.28),
                                    Color.cyan.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 6) {
                    Text(service.sessionTitle(for: session))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(settingsSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(TBDisplaySenderL10n.hideSettings(service.language)) {
                    close()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var settingsSubtitle: String {
        switch service.language {
        case .italian: return "Configura trasporto, output e diagnostica senza sporcare la dashboard principale."
        case .english, .spanish: return "Configure transport, output, and diagnostics without cluttering the main dashboard."
        case .german: return "Transport, Ausgabe und Diagnose konfigurieren, ohne das Haupt-Dashboard zu überladen."
        case .french: return "Configurez le transport, la sortie et le diagnostic sans encombrer le tableau de bord principal."
        case .chinese: return "在不干扰主控制面板的情况下配置传输、输出和诊断。"
        }
    }

    private var connectionSettingsTitle: String {
        switch service.language {
        case .italian: return "Connessione"
        case .english, .spanish: return "Connection"
        case .german: return "Verbindung"
        case .french: return "Connexion"
        case .chinese: return "连接"
        }
    }

    private var outputSettingsTitle: String {
        switch service.language {
        case .italian: return "Uscita"
        case .english, .spanish: return "Output"
        case .german: return "Ausgabe"
        case .french: return "Sortie"
        case .chinese: return "输出"
        }
    }

    private var diagnosticsTitle: String {
        switch service.language {
        case .italian: return "Diagnostica"
        case .english, .spanish: return "Diagnostics"
        case .german: return "Diagnose"
        case .french: return "Diagnostic"
        case .chinese: return "诊断"
        }
    }

    private var transportDetails: String {
        switch service.language {
        case .italian: return "Scegli il percorso di rete per questa sessione. Thunderbolt Bridge resta il profilo raccomandato; Network Link e sperimentale."
        case .english, .spanish: return "Choose the network path for this session. Thunderbolt Bridge remains the recommended profile; Network Link is experimental."
        case .german: return "Wähle den Netzwerkpfad für diese Sitzung. Thunderbolt Bridge bleibt die empfohlene Option; Network Link ist experimentell."
        case .french: return "Choisissez le chemin réseau de cette session. Thunderbolt Bridge reste le profil recommandé ; Network Link est expérimental."
        case .chinese: return "为该会话选择网络路径。Thunderbolt Bridge 仍然是推荐模式；Network Link 为实验性功能。"
        }
    }

    private var localInterfaceDetails: String {
        switch service.language {
        case .italian: return "L'interfaccia locale determina da quale indirizzo il sender apre la connessione."
        case .english, .spanish: return "The local interface controls which source address the sender binds before opening the connection."
        case .german: return "Die lokale Schnittstelle bestimmt, an welche Quelladresse der Sender beim Verbindungsaufbau bindet."
        case .french: return "L’interface locale détermine l’adresse source à laquelle le sender se lie avant d’ouvrir la connexion."
        case .chinese: return "本地接口决定 sender 在建立连接前绑定的源地址。"
        }
    }

    private var discoveryDetails: String {
        switch service.language {
        case .italian: return "Seleziona un receiver rilevato automaticamente oppure lascia inserimento manuale."
        case .english, .spanish: return "Select an automatically discovered receiver or keep manual entry."
        case .german: return "Wähle einen automatisch gefundenen Empfänger oder bleibe bei der manuellen Eingabe."
        case .french: return "Sélectionnez un receiver détecté automatiquement ou conservez la saisie manuelle."
        case .chinese: return "选择自动发现的 receiver，或者保持手动输入。"
        }
    }

    private var receiverDetails: String {
        switch service.language {
        case .italian: return "Indirizzo diretto del receiver. Puoi usare IP Thunderbolt o LAN a seconda del trasporto."
        case .english, .spanish: return "Direct receiver address. You can use a Thunderbolt or LAN IP depending on the selected transport."
        case .german: return "Direkte Empfängeradresse. Je nach gewähltem Transport kann eine Thunderbolt- oder LAN-IP verwendet werden."
        case .french: return "Adresse directe du receiver. Vous pouvez utiliser une IP Thunderbolt ou LAN selon le transport sélectionné."
        case .chinese: return "receiver 的直连地址。可以根据所选传输使用 Thunderbolt 或局域网 IP。"
        }
    }

    private var captureModeDetails: String {
        switch service.language {
        case .italian: return "Mirror per duplicare il desktop, Extended per creare un display indipendente."
        case .english, .spanish: return "Mirror duplicates the desktop, Extended creates a separate display."
        case .german: return "Mirror dupliziert den Desktop, Extended erstellt ein separates Display."
        case .french: return "Dupliquer recopie le bureau, Étendu crée un écran distinct."
        case .chinese: return "Mirror 复制桌面，Extended 创建独立显示器。"
        }
    }

    private var streamProfileDetails: String {
        switch service.language {
        case .italian: return "Parti da preset conservativi su Wi-Fi o reti lente, poi sali se la stabilita rimane buona."
        case .english, .spanish: return "Start with conservative presets on Wi-Fi or slower links, then move up if stability stays good."
        case .german: return "Beginne bei WLAN oder langsameren Verbindungen mit konservativen Profilen und wähle höhere Einstellungen, wenn die Verbindung stabil bleibt."
        case .french: return "Commencez avec des préréglages prudents sur Wi-Fi ou les liaisons lentes, puis augmentez-les si la stabilité reste bonne."
        case .chinese: return "在 Wi‑Fi 或较慢链路上先使用保守预设，稳定后再逐步提高。"
        }
    }

    private var audioDetails: String {
        switch service.language {
        case .italian: return "Invia anche l'audio di sistema del sender al receiver per questa sessione."
        case .english, .spanish: return "Also send the sender’s system audio to the receiver for this session."
        case .german: return "Überträgt für diese Sitzung auch den Systemton des Senders an den Empfänger."
        case .french: return "Envoie aussi l’audio système du sender au receiver pour cette session."
        case .chinese: return "同时将 sender 的系统音频传到此会话的 receiver。"
        }
    }

    private var renderMatchingTitle: String {
        switch service.language {
        case .italian: return "Rendering alla risoluzione dello stream"
        case .english, .spanish: return "Match render to stream"
        case .german: return "Rendern in Stream-Auflösung"
        case .french: return "Adapter le rendu au flux"
        case .chinese: return "渲染匹配串流分辨率"
        }
    }

    private var renderMatchingDetails: String {
        let desktop = session.capturePreset.renderMatchedDesktopDescription
        switch service.language {
        case .italian: return "Dimensiona il display virtuale sul profilo dello stream: nessun ridimensionamento in cattura. Il desktop appare come \(desktop) HiDPI."
        case .english, .spanish: return "Sizes the virtual display to the stream profile so capture is 1:1 — no rescale before encoding. Desktop looks like \(desktop) HiDPI."
        case .german: return "Passt das virtuelle Display an das Stream-Profil an, sodass die Aufnahme 1:1 erfolgt. Der Desktop erscheint als \(desktop) HiDPI."
        case .french: return "Dimensionne l’écran virtuel selon le profil de flux pour une capture 1:1, sans redimensionnement avant l’encodage. Le bureau apparaît en \(desktop) HiDPI."
        case .chinese: return "使虚拟显示器匹配串流分辨率，捕获无需缩放。桌面显示为 \(desktop) HiDPI。"
        }
    }

    private var inputDockstationTitle: String {
        switch service.language {
        case .italian: return "Input Dockstation"
        case .english, .spanish: return "Input Dockstation"
        case .german: return "Input Dockstation"
        case .french: return "Station d’accueil des entrées"
        case .chinese: return "输入扩展坞"
        }
    }

    private var inputDockstationDetails: String {
        switch service.language {
        case .italian: return "Definisce il ruolo input di questa sessione. Una sola sessione puo avere un master attivo alla volta: questo Mac puo controllare il receiver, oppure il receiver puo controllare questo Mac. Per uscire rapidamente dal controllo usa Ctrl+Option+Command+K."
        case .english, .spanish: return "Defines the input role for this session. Only one session can have an active master at a time: this Mac can control the receiver, or the receiver can control this Mac. Use Control+Option+Command+K to exit control quickly."
        case .german: return "Legt die Eingaberolle für diese Sitzung fest. Nur eine Sitzung kann gleichzeitig einen aktiven Master haben: Dieser Mac kann den Empfänger steuern oder der Empfänger kann diesen Mac steuern. Mit Ctrl+Option+Command+K beendest du die Steuerung schnell."
        case .french: return "Définit le rôle d’entrée de cette session. Une seule session peut avoir un master actif à la fois : ce Mac peut contrôler le receiver, ou le receiver peut contrôler ce Mac. Utilisez Contrôle+Option+Commande+K pour quitter rapidement le contrôle."
        case .chinese: return "定义此会话的输入角色。同一时间只能有一个活动 master：这台 Mac 可以控制 receiver，或者 receiver 可以控制这台 Mac。按下 Control+Option+Command+K 可以快速退出控制。"
        }
    }

    private var inputGestureModeTitle: String {
        switch service.language {
        case .italian: return "Cambio slave"
        case .english, .spanish: return "Slave switching"
        case .german: return "Slave-Wechsel"
        case .french: return "Changement de slave"
        case .chinese: return "Slave 切换"
        }
    }

    private var inputGestureModeDetails: String {
        switch service.language {
        case .italian:
            return "Decide come passare da uno slave all'altro quando 'Questo Mac e Master' e attivo. In modalita nativa, macOS continua a gestire normalmente il desktop del master. In modalita relay, TargetBridge usa il bordo sinistro/destro dello schermo e le hotkey Ctrl+Option+Freccia Sinistra/Destra per spostare il controllo allo slave precedente o successivo."
        case .english, .spanish:
            return "Chooses how to move control from one slave to another when 'This Mac is Master' is active. In native mode, macOS keeps handling the master's desktop normally. In relay mode, TargetBridge uses the left/right screen edge and the Ctrl+Option+Left/Right hotkeys to move control to the previous or next slave."
        case .german:
            return "Legt fest, wie die Steuerung von einem Slave zum anderen wechselt, wenn 'Dieser Mac ist Master' aktiv ist. Im nativen Modus verwaltet macOS den Desktop des Masters normal weiter. Im Relay-Modus nutzt TargetBridge den linken/rechten Bildschirmrand und die Hotkeys Ctrl+Option+Links/Rechts, um zum vorherigen oder nächsten Slave zu wechseln."
        case .french:
            return "Définit comment déplacer le contrôle d’un slave à l’autre lorsque « Ce Mac est Master » est actif. En mode natif, macOS continue de gérer normalement le bureau du master. En mode relais, TargetBridge utilise les bords gauche et droit de l’écran ainsi que les raccourcis Ctrl+Option+Gauche/Droite pour déplacer le contrôle vers le slave précédent ou suivant."
        case .chinese:
            return "决定在“这台 Mac 是 Master”启用时如何在不同 slave 之间切换控制。原生模式下，macOS 继续正常处理 master 的桌面；relay 模式下，TargetBridge 会使用屏幕左右边缘以及 Ctrl+Option+Left/Right 热键，把控制切换到上一个或下一个 slave。"
        }
    }

    private func inputGestureModeOptionTitle(_ mode: TBInputGestureMode) -> String {
        switch (mode, service.language) {
        case (.native, .italian): return "Lascia il desktop nativo del master"
        case (.native, .english), (.native, .spanish): return "Keep master's desktop native"
        case (.native, .german): return "Desktop des Masters nativ lassen"
        case (.native, .french): return "Conserver le bureau natif du master"
        case (.native, .chinese): return "保留 master 的原生桌面行为"
        case (.relayToSlave, .italian): return "Usa bordi schermo e hotkey per cambiare slave"
        case (.relayToSlave, .english), (.relayToSlave, .spanish): return "Use screen edges and hotkeys to switch slave"
        case (.relayToSlave, .german): return "Bildschirmränder und Hotkeys für Slave-Wechsel nutzen"
        case (.relayToSlave, .french): return "Utiliser les bords de l’écran et les raccourcis pour changer de slave"
        case (.relayToSlave, .chinese): return "使用屏幕边缘和热键切换 slave"
        }
    }

    private func inputControlRoleTitle(_ role: TBInputControlRole) -> String {
        switch (role, service.language) {
        case (.off, .italian): return "Off"
        case (.off, .english), (.off, .spanish): return "Off"
        case (.off, .german): return "Aus"
        case (.off, .french): return "Désactivé"
        case (.off, .chinese): return "关闭"
        case (.senderMaster, .italian): return "Questo Mac e Master"
        case (.senderMaster, .english), (.senderMaster, .spanish): return "This Mac is Master"
        case (.senderMaster, .german): return "Dieser Mac ist Master"
        case (.senderMaster, .french): return "Ce Mac est Master"
        case (.senderMaster, .chinese): return "这台 Mac 是 Master"
        case (.receiverMaster, .italian): return "Receiver e Master"
        case (.receiverMaster, .english), (.receiverMaster, .spanish): return "Receiver is Master"
        case (.receiverMaster, .german): return "Empfänger ist Master"
        case (.receiverMaster, .french): return "Le receiver est Master"
        case (.receiverMaster, .chinese): return "Receiver 是 Master"
        }
    }

    private var inputPermissionWarningTitle: String {
        switch service.language {
        case .italian: return "Il sender non puo ancora iniettare input"
        case .english, .spanish: return "The sender cannot inject input yet"
        case .german: return "Der Sender kann noch keine Eingaben injizieren"
        case .french: return "Le sender ne peut pas encore injecter d’entrées"
        case .chinese: return "Sender 目前还不能注入输入"
        }
    }

    private var inputPermissionWarningBody: String {
        switch service.language {
        case .italian:
            return "Per usare 'Receiver e Master', questa app TargetBridge sul sender deve essere autorizzata in Privacy e Sicurezza > Accessibilita. Apri le impostazioni, abilita l'app che stai usando e poi riapri la sessione. Le scorciatoie configurate richiedono inoltre una sola autorizzazione macOS per controllare System Events."
        case .english, .spanish:
            return "To use 'Receiver is Master', this TargetBridge app on the sender must be allowed under Privacy & Security > Accessibility. Open the settings, enable the app you are actually running, then reopen the session. Configured shortcuts also require a one-time macOS permission to control System Events."
        case .german:
            return "Um 'Empfänger ist Master' zu verwenden, muss diese TargetBridge-App auf dem Sender unter Datenschutz & Sicherheit > Bedienungshilfen erlaubt sein. Öffne die Einstellungen, aktiviere die wirklich verwendete App und öffne dann die Sitzung erneut. Konfigurierte Kurzbefehle benötigen außerdem einmalig die macOS-Erlaubnis, System Events zu steuern."
        case .french:
            return "Pour utiliser « Le receiver est Master », cette app TargetBridge sur le sender doit être autorisée dans Confidentialité et sécurité > Accessibilité. Ouvrez les réglages, activez l’app que vous utilisez réellement, puis rouvrez la session. Les raccourcis configurés exigent aussi une autorisation macOS unique pour contrôler System Events."
        case .chinese:
            return "要使用“Receiver 是 Master”，sender 上这份 TargetBridge 必须在“隐私与安全性 > 辅助功能”中被允许。打开设置，启用你当前运行的这份应用，然后重新打开会话。已配置的快捷键还需要一次性授权 TargetBridge 控制 System Events。"
        }
    }

    private var openAccessibilitySettingsTitle: String {
        switch service.language {
        case .italian: return "Apri Accessibilita"
        case .english, .spanish: return "Open Accessibility"
        case .german: return "Bedienungshilfen öffnen"
        case .french: return "Ouvrir Accessibilité"
        case .chinese: return "打开辅助功能"
        }
    }

    private var inputPermissionStatusText: String {
        service.localInputInjectionTrusted ? "trusted=true" : "trusted=false"
    }

    private var localInputMonitoringWarningTitle: String {
        switch service.language {
        case .italian: return "Manca il monitoraggio input sul sender"
        case .english, .spanish: return "Input Monitoring is missing on the sender"
        case .german: return "Eingabeüberwachung fehlt auf dem Sender"
        case .french: return "La surveillance des entrées manque sur le sender"
        case .chinese: return "sender 缺少输入监控权限"
        }
    }

    private var localInputMonitoringWarningBody: String {
        switch service.language {
        case .italian:
            return "Per usare 'Questo Mac e Master' in modo affidabile anche fuori dalla finestra attiva, il sender deve avere il permesso Monitoraggio input. Senza questo permesso alcuni tasti o movimenti globali possono non essere catturati."
        case .english, .spanish:
            return "To use 'This Mac is Master' reliably outside the active app window, the sender needs Input Monitoring permission. Without it, some keys or global pointer events may not be captured."
        case .german:
            return "Damit 'Dieser Mac ist Master' auch außerhalb des aktiven Fensters zuverlässig funktioniert, braucht der Sender die Berechtigung für Eingabeüberwachung. Ohne diese können einige Tasten oder globale Zeigerereignisse fehlen."
        case .french:
            return "Pour utiliser « Ce Mac est Master » de façon fiable en dehors de la fenêtre active, le sender a besoin de l’autorisation Surveillance des entrées. Sans elle, certaines touches ou certains événements globaux du pointeur peuvent ne pas être capturés."
        case .chinese:
            return "要让“这台 Mac 是 Master”在活动窗口之外也可靠工作，sender 需要“输入监控”权限。没有它，一些按键或全局指针事件可能无法被捕获。"
        }
    }

    private var receiverAccessibilityWarningTitle: String {
        switch service.language {
        case .italian: return "Manca Accessibilita sul receiver"
        case .english, .spanish: return "Accessibility is missing on the receiver"
        case .german: return "Bedienungshilfen fehlen auf dem Empfänger"
        case .french: return "L’accessibilité manque sur le receiver"
        case .chinese: return "receiver 缺少辅助功能权限"
        }
    }

    private var receiverAccessibilityWarningBody: String {
        switch service.language {
        case .italian:
            return "Con 'Questo Mac e Master', il receiver deve poter iniettare click e tastiera. Sul Mac receiver abilita TargetBridge Receiver in Privacy e Sicurezza > Accessibilita."
        case .english, .spanish:
            return "With 'This Mac is Master', the receiver must be allowed to inject clicks and keyboard events. On the receiver Mac, enable TargetBridge Receiver under Privacy & Security > Accessibility."
        case .german:
            return "Bei 'Dieser Mac ist Master' muss der Empfänger Klicks und Tastatureingaben injizieren dürfen. Aktiviere auf dem Empfänger-Mac TargetBridge-Receiver unter Datenschutz & Sicherheit > Bedienungshilfen."
        case .french:
            return "Avec « Ce Mac est Master », le receiver doit pouvoir injecter les clics et les événements clavier. Sur le Mac receiver, activez TargetBridge Receiver dans Confidentialité et sécurité > Accessibilité."
        case .chinese:
            return "在“这台 Mac 是 Master”模式下，receiver 必须被允许注入点击和键盘事件。请在 receiver Mac 的“隐私与安全性 > 辅助功能”中启用 TargetBridge Receiver。"
        }
    }

    private var receiverInputMonitoringWarningTitle: String {
        switch service.language {
        case .italian: return "Manca Monitoraggio input sul receiver"
        case .english, .spanish: return "Input Monitoring is missing on the receiver"
        case .german: return "Eingabeüberwachung fehlt auf dem Empfänger"
        case .french: return "La surveillance des entrées manque sur le receiver"
        case .chinese: return "receiver 缺少输入监控权限"
        }
    }

    private var receiverInputMonitoringWarningBody: String {
        switch service.language {
        case .italian:
            return "Con 'Receiver e Master', il Mac receiver deve poter leggere tastiera e mouse locali. Sul receiver abilita TargetBridge Receiver in Privacy e Sicurezza > Monitoraggio input."
        case .english, .spanish:
            return "With 'Receiver is Master', the receiver Mac must be allowed to read local keyboard and mouse input. On the receiver, enable TargetBridge Receiver under Privacy & Security > Input Monitoring."
        case .german:
            return "Bei 'Empfänger ist Master' muss der Empfänger-Mac lokale Tastatur- und Mauseingaben lesen dürfen. Aktiviere dort TargetBridge-Receiver unter Datenschutz & Sicherheit > Eingabeüberwachung."
        case .french:
            return "Avec « Le receiver est Master », le Mac receiver doit pouvoir lire les entrées clavier et souris locales. Sur le receiver, activez TargetBridge Receiver dans Confidentialité et sécurité > Surveillance des entrées."
        case .chinese:
            return "在“Receiver 是 Master”模式下，receiver Mac 必须被允许读取本地键盘和鼠标输入。请在 receiver 上的“隐私与安全性 > 输入监控”中启用 TargetBridge Receiver。"
        }
    }

    private var openInputMonitoringSettingsTitle: String {
        switch service.language {
        case .italian: return "Apri Monitoraggio input"
        case .english, .spanish: return "Open Settings"
        case .german: return "Einstellungen öffnen"
        case .french: return "Ouvrir les réglages"
        case .chinese: return "打开设置"
        }
    }

    private var trimmedReceiverIP: String {
        session.receiverIP.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cableRateText: String {
        if let rate = session.cableTestResult {
            return String(format: "%.2f Gbits/s", rate)
        }
        return TBDisplaySenderL10n.noTestResult(service.language)
    }

    private var cableRateColor: Color {
        session.cableTestResult == nil ? .secondary : .green
    }

    private var interfaceTestHint: String {
        switch service.language {
        case .spanish:
            return "La prueba usa la interfaz y la IP del receptor elegidas arriba. Selecciona el enlace correcto antes de medir; la app no modifica la red."
        case .italian:
            return "Il test usa l'interfaccia e l'IP del receiver selezionati sopra. Scegli il collegamento corretto prima della misura; l'app non modifica la rete."
        case .german:
            return "Der Test verwendet die oben gewählte Schnittstelle und Receiver-IP. Vor der Messung den richtigen Link wählen; die App ändert keine Netzwerkeinstellungen."
        case .french:
            return "Le test utilise l’interface et l’adresse IP du receiver sélectionnées ci-dessus. Choisissez le bon lien avant la mesure ; l’app ne modifie pas le réseau."
        case .chinese:
            return "测试使用上方选择的接口和接收端 IP。测量前请选择正确链路；应用不会更改网络设置。"
        case .english:
            return "The test uses the interface and Receiver IP selected above. Choose the correct link before measuring; the app does not change network settings."
        }
    }

    @ViewBuilder
    private func interfacePerformanceRow(_ localInterface: TBLocalLinkInterface) -> some View {
        let result = session.interfacePerformanceResults.first { $0.localIP == localInterface.ip }
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(localInterface.ip == session.localInterfaceIP ? Color.green : Color.secondary.opacity(0.45))
                .frame(width: 7, height: 7)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(localInterface.name) · \(localInterface.ip)")
                    .font(.subheadline.weight(.semibold))
                    .textSelection(.enabled)
                Text(localInterface.transportKind.title(service.language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            if let result {
                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "%.2f Gbits/s", result.rateGbps))
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    Text(interfaceRecommendation(result.tier))
                        .font(.caption)
                        .foregroundStyle(interfaceRecommendationColor(result.tier))
                    Text("→ \(result.receiverIP)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            } else {
                Text(interfaceNotMeasured)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }

    private var interfaceNotMeasured: String {
        switch service.language {
        case .spanish: return "Sin medición"
        case .italian: return "Non misurato"
        case .german: return "Nicht gemessen"
        case .french: return "Non mesuré"
        case .chinese: return "未测量"
        case .english: return "Not measured"
        }
    }

    private func interfaceRecommendation(_ tier: TBInterfacePerformanceTier) -> String {
        switch (tier, service.language) {
        case (.rawNV12, .spanish): return "HEVC/H.264 y RAW NV12"
        case (.compressed4K, .spanish): return "Adecuado para HEVC/H.264 4K"
        case (.compressedReduced, .spanish): return "Solo perfiles comprimidos reducidos"
        case (.insufficient, .spanish): return "Ancho de banda insuficiente"
        case (.rawNV12, .italian): return "HEVC/H.264 e RAW NV12"
        case (.compressed4K, .italian): return "Adatto a HEVC/H.264 4K"
        case (.compressedReduced, .italian): return "Solo profili compressi ridotti"
        case (.insufficient, .italian): return "Larghezza di banda insufficiente"
        case (.rawNV12, .german): return "HEVC/H.264 und RAW NV12"
        case (.compressed4K, .german): return "Geeignet für 4K HEVC/H.264"
        case (.compressedReduced, .german): return "Nur reduzierte komprimierte Profile"
        case (.insufficient, .german): return "Unzureichende Bandbreite"
        case (.rawNV12, .french): return "HEVC/H.264 et RAW NV12"
        case (.compressed4K, .french): return "Adapté au HEVC/H.264 4K"
        case (.compressedReduced, .french): return "Profils compressés réduits uniquement"
        case (.insufficient, .french): return "Bande passante insuffisante"
        case (.rawNV12, .chinese): return "HEVC/H.264 和 RAW NV12"
        case (.compressed4K, .chinese): return "适用于 4K HEVC/H.264"
        case (.compressedReduced, .chinese): return "仅适用于较低压缩配置"
        case (.insufficient, .chinese): return "带宽不足"
        case (.rawNV12, .english): return "HEVC/H.264 and RAW NV12"
        case (.compressed4K, .english): return "Suitable for 4K HEVC/H.264"
        case (.compressedReduced, .english): return "Reduced compressed profiles only"
        case (.insufficient, .english): return "Insufficient bandwidth"
        }
    }

    private func interfaceRecommendationColor(_ tier: TBInterfacePerformanceTier) -> Color {
        switch tier {
        case .rawNV12, .compressed4K: return .green
        case .compressedReduced: return .orange
        case .insufficient: return .red
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 138, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func configurationCheckRow(_ check: TBConfigurationCheck) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: configurationCheckIcon(for: check.state))
                .foregroundStyle(configurationCheckColor(for: check.state))
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(TBDisplaySenderL10n.text(check.titleKey, service.language))
                    .font(.footnote.weight(.semibold))
                Text(TBDisplaySenderL10n.text(check.detailKey, service.language, check.values))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func configurationCheckIcon(for state: TBConfigurationCheckState) -> String {
        switch state {
        case .passed: return "checkmark.circle.fill"
        case .attention: return "exclamationmark.triangle.fill"
        case .pending: return "clock.fill"
        }
    }

    private func configurationCheckColor(for state: TBConfigurationCheckState) -> Color {
        switch state {
        case .passed: return .green
        case .attention: return .yellow
        case .pending: return .secondary
        }
    }
}
