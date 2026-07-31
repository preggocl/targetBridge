import CoreMedia
import Foundation
import VideoToolbox

struct ProbeResult: Codable {
    let codec: String
    let width: Int32
    let height: Int32
    let fps: Int
    let bitrate: Int
    let createStatus: OSStatus
    let prepareStatus: OSStatus?
    let hardware: Bool
    let encoderID: String
    let fallback: String
}

func probe(codecName: String, codec: CMVideoCodecType, width: Int32, height: Int32, bitrate: Int) -> ProbeResult {
    let spec = [
        kVTVideoEncoderSpecification_EnableHardwareAcceleratedVideoEncoder as String: true,
        kVTVideoEncoderSpecification_RequireHardwareAcceleratedVideoEncoder as String: true
    ] as CFDictionary
    var session: VTCompressionSession?
    let createStatus = VTCompressionSessionCreate(
        allocator: nil, width: width, height: height, codecType: codec,
        encoderSpecification: spec, imageBufferAttributes: nil,
        compressedDataAllocator: nil, outputCallback: nil, refcon: nil,
        compressionSessionOut: &session
    )
    guard createStatus == noErr, let session else {
        return ProbeResult(codec: codecName, width: width, height: height, fps: 60, bitrate: bitrate,
                           createStatus: createStatus, prepareStatus: nil, hardware: false,
                           encoderID: "unavailable", fallback: codec == kCMVideoCodecType_HEVC ? "H.264" : "none")
    }
    defer { VTCompressionSessionInvalidate(session) }
    VTSessionSetProperty(session, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
    VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ExpectedFrameRate, value: 60 as CFNumber)
    VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AverageBitRate, value: bitrate as CFNumber)
    let prepareStatus = VTCompressionSessionPrepareToEncodeFrames(session)
    var encoderValue: CFTypeRef?
    var hardwareValue: CFTypeRef?
    VTSessionCopyProperty(session, key: kVTCompressionPropertyKey_EncoderID, allocator: nil, valueOut: &encoderValue)
    VTSessionCopyProperty(session, key: kVTCompressionPropertyKey_UsingHardwareAcceleratedVideoEncoder, allocator: nil, valueOut: &hardwareValue)
    let encoderID = encoderValue as? String ?? "unknown"
    let hardware = hardwareValue as? Bool ?? false
    return ProbeResult(codec: codecName, width: width, height: height, fps: 60, bitrate: bitrate,
                       createStatus: createStatus, prepareStatus: prepareStatus, hardware: hardware,
                       encoderID: encoderID, fallback: "none")
}

let results = [
    probe(codecName: "H.264", codec: kCMVideoCodecType_H264, width: 2048, height: 1152, bitrate: 32_000_000),
    probe(codecName: "HEVC", codec: kCMVideoCodecType_HEVC, width: 2048, height: 1152, bitrate: 32_000_000),
    probe(codecName: "H.264", codec: kCMVideoCodecType_H264, width: 2304, height: 1296, bitrate: 40_000_000),
    probe(codecName: "HEVC", codec: kCMVideoCodecType_HEVC, width: 2304, height: 1296, bitrate: 40_000_000)
]
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
FileHandle.standardOutput.write(try encoder.encode(results))
FileHandle.standardOutput.write(Data("\n".utf8))
