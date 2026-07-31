import Foundation

enum TBIntelSenderIdentity {
    static let bundleIdentifier = "com.targetbridge.intel-sender"
    static let isIntelVariant = Bundle.main.bundleIdentifier == bundleIdentifier
    static let applicationSupportName = isIntelVariant ? "TargetBridge Intel Sender" : "TargetBridge"
    static let logSubsystem = isIntelVariant ? bundleIdentifier : "com.targetbridge.sender"
}
