import Foundation

enum TBDisplaySenderBuildInfo {
    static let marketingVersion = "3.3.0"
    static let buildNumber = "20260731193045"
    static var versionDisplay: String {
        let version = Bundle.main.bundleIdentifier == "com.targetbridge.intel-sender"
            ? "\(marketingVersion)-intel.1"
            : marketingVersion
        return "\(version) + build \(buildNumber)"
    }
}
