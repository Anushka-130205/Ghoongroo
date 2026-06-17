import SwiftUI
import Combine
import AVFoundation
import CoreImage

// MARK: - Camera Manager (AVFoundation + Vision + Recording)
// Handles live front-camera capture, feeds frames to Vision, and records local 720p video.

// MARK: - Video Constants

private enum VideoConstants {
    static let captureWidth: Int = 720
    static let captureHeight: Int = 1280
    /// Only push a CGImage to SwiftUI every Nth frame to reduce main-thread load.
    static let uiFrameSkip: Int = 3
}

@MainActor
final class CameraManager: NSObject, ObservableObject, @unchecked Sendable {

    @Published var currentFrame: CGImage?
    @Published var isRunning = false
    @Published var permissionGranted = false
    @Published var errorMessage: String?
    
    // Video Recording State
    @Published var isRecording = false
    private(set) var recordingURL: URL?

    /// Orientation applied to every frame so the upright, mirrored (selfie) portrait image
    /// is consistent across the live preview, Vision pose detection, and the recorded video.
    /// `.leftMirrored` is the standard value for the front camera while the device is held
    /// in portrait. If the preview ever appears upside-down on a given device, switch this
    /// to `.rightMirrored`; this single constant drives all three pipelines.
    nonisolated(unsafe) var imageOrientation: CGImagePropertyOrientation = .leftMirrored

    // Delegate for pose detection — set by PracticeView
    nonisolated(unsafe) var frameHandler: ((CMSampleBuffer, CGImagePropertyOrientation) -> Void)?

    // AVFoundation Core
    nonisolated(unsafe) private let captureSession = AVCaptureSession()
    nonisolated(unsafe) private let videoDataOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.taalsen.camera", qos: .userInteractive)
    private let context = CIContext()
    
    // Recording Core - Modified exclusively on sessionQueue
    nonisolated(unsafe) private var assetWriter: AVAssetWriter?
    nonisolated(unsafe) private var assetWriterInput: AVAssetWriterInput?
    nonisolated(unsafe) private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    nonisolated(unsafe) private var sessionAtSourceTime: CMTime?

    /// Color space used when rendering oriented frames into the recording pixel buffers.
    nonisolated(unsafe) private let renderColorSpace = CGColorSpaceCreateDeviceRGB()
    
    // Frame throttling counter (accessed on sessionQueue only)
    nonisolated(unsafe) private var frameCount: Int = 0

    override init() {
        super.init()
    }

    // MARK: - Permissions

    func checkAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionGranted = true
            setupAndStartSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupAndStartSession()
                    } else {
                        self?.errorMessage = "Camera access denied."
                    }
                }
            }
        case .denied, .restricted:
            self.permissionGranted = false
            self.errorMessage = "Camera access is restricted or denied."
        @unknown default:
            break
        }
    }

    // MARK: - Session Setup

    private func setupAndStartSession() {
        guard !isRunning, permissionGranted else { return }
        
        sessionQueue.async {
            self.configureSession()
            self.captureSession.startRunning()
            Task { @MainActor in
                self.isRunning = true
            }
        }
    }

    nonisolated private func configureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720 // 720p for fast ML processing & smaller file size

        // Use front camera (it's a mirror app)
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            Task { @MainActor in self.errorMessage = "Unable to access front camera." }
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }

        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        }

        // NOTE: We intentionally do NOT rotate or mirror the capture connection.
        // Connection rotation on a video-data output is not reliably honored on every
        // device/OS, which is what caused the sideways ("landscape") preview. Instead the
        // sensor delivers its native landscape buffer and we orient every frame explicitly
        // in `captureOutput` via `imageOrientation`. This keeps the preview, Vision input,
        // and recorded video perfectly in sync and upright.

        captureSession.commitConfiguration()
    }

    // MARK: - Start / Stop

    func start() {
        checkAndStart()
    }

    func stop() {
        sessionQueue.async {
            self.captureSession.stopRunning()
            Task { @MainActor in
                self.isRunning = false
            }
        }
    }

    // MARK: - Video Recording (AVAssetWriter)
    
    func startRecording() {
        sessionQueue.async {
            self.setupAssetWriter()
            Task { @MainActor in
                self.isRecording = true
            }
        }
    }
    
    func stopRecording(completion: @escaping @Sendable (URL?) -> Void) {
        sessionQueue.async { [self] in
            Task { @MainActor in self.isRecording = false }
            
            guard let writer = self.assetWriter, writer.status == .writing else {
                Task { @MainActor in completion(nil) }
                return
            }
            
            self.assetWriterInput?.markAsFinished()
            let outputURL = writer.outputURL
            writer.finishWriting { [self] in
                self.assetWriter = nil
                self.assetWriterInput = nil
                self.pixelBufferAdaptor = nil
                self.sessionAtSourceTime = nil
                
                Task { @MainActor [self] in
                    self.recordingURL = outputURL
                    completion(outputURL)
                }
            }
        }
    }
    
    nonisolated private func setupAssetWriter() {
        // Output to temporary directory, clean up old file if exists
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("taalsen_practice_\(UUID().uuidString).mp4")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        do {
            assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
            
            let outputSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: VideoConstants.captureWidth,
                AVVideoHeightKey: VideoConstants.captureHeight
            ]
            
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
            input.expectsMediaDataInRealTime = true

            // Adaptor lets us feed already-oriented (upright, mirrored, portrait) pixel
            // buffers rendered from the raw landscape frames — so the saved video matches
            // exactly what the dancer saw on screen.
            let sourceAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
                kCVPixelBufferWidthKey as String: VideoConstants.captureWidth,
                kCVPixelBufferHeightKey as String: VideoConstants.captureHeight
            ]
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: input,
                sourcePixelBufferAttributes: sourceAttributes
            )

            if assetWriter!.canAdd(input) {
                assetWriter!.add(input)
                assetWriterInput = input
                pixelBufferAdaptor = adaptor
            }

            assetWriter?.startWriting()
        } catch {
            print("Failed to setup AVAssetWriter: \(error.localizedDescription)")
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        frameCount += 1

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Orient the raw landscape sensor buffer into the upright, mirrored portrait image.
        // The same orientation is handed to Vision below so detected joints line up with
        // exactly what is shown on screen.
        let orientedImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(imageOrientation)

        // 1. Send to Vision (PoseDetector) — every frame for accurate tracking.
        //    Vision applies `imageOrientation` itself, so it sees the same upright frame.
        frameHandler?(sampleBuffer, imageOrientation)

        // 2. Send to AssetWriter — render the oriented frame into the recording so the
        //    saved video is upright/portrait and matches the live preview.
        if let writer = assetWriter, let input = assetWriterInput,
           let adaptor = pixelBufferAdaptor, writer.status == .writing {
            let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            if sessionAtSourceTime == nil {
                sessionAtSourceTime = time
                writer.startSession(atSourceTime: time)
            }
            if input.isReadyForMoreMediaData, let pool = adaptor.pixelBufferPool {
                var renderBuffer: CVPixelBuffer?
                CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &renderBuffer)
                if let renderBuffer {
                    let bounds = CGRect(x: 0, y: 0,
                                        width: VideoConstants.captureWidth,
                                        height: VideoConstants.captureHeight)
                    context.render(orientedImage, to: renderBuffer, bounds: bounds, colorSpace: renderColorSpace)
                    adaptor.append(renderBuffer, withPresentationTime: time)
                }
            }
        }

        // 3. Convert to CGImage for SwiftUI preview — throttled to reduce main-thread load.
        guard frameCount % VideoConstants.uiFrameSkip == 0 else { return }
        guard let cgImage = context.createCGImage(orientedImage, from: orientedImage.extent) else { return }

        Task { @MainActor [weak self] in
            self?.currentFrame = cgImage
        }
    }
}
