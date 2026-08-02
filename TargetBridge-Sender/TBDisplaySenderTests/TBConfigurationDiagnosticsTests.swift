import XCTest
@testable import TargetBridge

final class TBConfigurationDiagnosticsTests: XCTestCase {
    func testMissingEssentialsNeedAttention() {
        let checks = TBConfigurationDiagnostics.checks(for: baseSnapshot(hasScreenRecording: false, localInterfaceName: nil, receiverAddress: ""))

        XCTAssertEqual(checks.first(where: { $0.id == "screen_recording" })?.state, .attention)
        XCTAssertEqual(checks.first(where: { $0.id == "local_link" })?.state, .attention)
        XCTAssertEqual(checks.first(where: { $0.id == "receiver_address" })?.state, .attention)
    }

    func testThunderboltTransportWarnsWhenBridgeIsNotSelected() {
        let checks = TBConfigurationDiagnostics.checks(for: baseSnapshot(localInterfaceName: "en0"))
        XCTAssertEqual(checks.first(where: { $0.id == "local_link" })?.state, .attention)
    }

    func testReceiverControlChecksBothSidesOfInputRelay() {
        let checks = TBConfigurationDiagnostics.checks(for: baseSnapshot(requiresSenderAccessibility: true, senderAccessibilityGranted: false, requiresReceiverInputMonitoring: true, receiverInputMonitoringGranted: false))

        XCTAssertEqual(checks.first(where: { $0.id == "sender_accessibility" })?.state, .attention)
        XCTAssertEqual(checks.first(where: { $0.id == "receiver_input_monitoring" })?.state, .attention)
    }

    func testInterfacePerformanceTiersMatchTransportNeeds() {
        XCTAssertEqual(TBInterfacePerformanceAssessment.tier(for: 8.0), .rawNV12)
        XCTAssertEqual(TBInterfacePerformanceAssessment.tier(for: 0.95), .compressed4K)
        XCTAssertEqual(TBInterfacePerformanceAssessment.tier(for: 0.10), .compressedReduced)
        XCTAssertEqual(TBInterfacePerformanceAssessment.tier(for: 0.05), .insufficient)
    }

    private func baseSnapshot(
        hasScreenRecording: Bool = true,
        localInterfaceName: String? = "bridge0",
        receiverAddress: String = "169.254.1.2",
        requiresSenderAccessibility: Bool = false,
        senderAccessibilityGranted: Bool = true,
        requiresReceiverInputMonitoring: Bool = false,
        receiverInputMonitoringGranted: Bool? = true
    ) -> TBConfigurationDiagnosticSnapshot {
        TBConfigurationDiagnosticSnapshot(
            hasScreenRecording: hasScreenRecording, transportIsThunderbolt: true, localInterfaceName: localInterfaceName,
            receiverAddress: receiverAddress, receiverProfileAvailable: true, receiverSupportsHEVC: true,
            requiresHEVC: false, cableRate: 18.5, requiresSenderInputMonitoring: false,
            senderInputMonitoringGranted: true, requiresSenderAccessibility: requiresSenderAccessibility,
            senderAccessibilityGranted: senderAccessibilityGranted, requiresReceiverInputMonitoring: requiresReceiverInputMonitoring,
            receiverInputMonitoringGranted: receiverInputMonitoringGranted, requiresReceiverAccessibility: false,
            receiverAccessibilityGranted: true
        )
    }
}
