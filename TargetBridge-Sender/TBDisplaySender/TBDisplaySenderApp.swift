import SwiftUI

@main
struct TBDisplaySenderApp: App {
    @StateObject private var service = TBDisplaySenderService.shared
    private let statusItemController = TBDisplaySenderStatusItemController(service: TBDisplaySenderService.shared)

    var body: some Scene {
        WindowGroup("TargetBridge — Intel Sender", id: "main") {
            TBDisplaySenderContentView(service: service)
                .frame(minWidth: 540)
                .task {
                    statusItemController.activate()
                    TBSenderAutomation.handleLaunchArguments(CommandLine.arguments)
                    service.connectConfiguredSessionsAtLaunch()
                }
                .onOpenURL { url in
                    TBSenderAutomation.handle(url: url)
                }
        }
    }
}
