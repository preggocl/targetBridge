import Foundation

enum TBDisplaySenderBuildInfo {
    static let marketingVersion = "3.3.0"
    static let buildNumber = "20260810043000"
    static var versionDisplay: String {
        let bundleIdentifier = Bundle.main.bundleIdentifier
        let version: String
        if bundleIdentifier == "com.targetbridge.intel-sender.legacy" {
            version = "\(marketingVersion)-intel-legacy.1"
        } else if bundleIdentifier == "com.targetbridge.intel-sender" {
            version = "\(marketingVersion)-intel.2"
        } else {
            version = marketingVersion
        }
        let bundleBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let displayedBuild = (bundleIdentifier == "com.targetbridge.intel-sender" ||
                              bundleIdentifier == "com.targetbridge.intel-sender.legacy")
            ? (bundleBuild ?? buildNumber) : buildNumber
        return "\(version) + build \(displayedBuild)"
    }
}
