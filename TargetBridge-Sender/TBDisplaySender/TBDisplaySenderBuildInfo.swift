import Foundation

enum TBDisplaySenderBuildInfo {
    static let marketingVersion = "3.3.0"
    static let buildNumber = "20260801015945"
    static var versionDisplay: String {
        let version = Bundle.main.bundleIdentifier == "com.targetbridge.intel-sender"
            ? "\(marketingVersion)-intel.1"
            : marketingVersion
        let bundleBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let displayedBuild = Bundle.main.bundleIdentifier == "com.targetbridge.intel-sender"
            ? (bundleBuild ?? buildNumber)
            : buildNumber
        return "\(version) + build \(displayedBuild)"
    }
}
