import AVFoundation

final class CameraService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    var onFrame: ((CVPixelBuffer) -> Void)?

    private let videoQueue = DispatchQueue(label: "videoQueue")
    private(set) var currentPosition: AVCaptureDevice.Position = .back
    private var videoOutput: AVCaptureVideoDataOutput?

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // 1) Input (from currentPosition)
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            print("⚠️ Could not create/add camera input.")
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        // 2) Output (BGRA + delegate)
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(output) { session.addOutput(output) }
        self.videoOutput = output

        // Orientation + mirroring
        if let conn = output.connection(with: .video) {
            conn.videoOrientation = .portrait
            if conn.isVideoMirroringSupported {
                conn.isVideoMirrored = (currentPosition == .front)
            }
        }

        session.commitConfiguration()
    }

    func start() { if !session.isRunning { session.startRunning() } }
    func stop()  { if  session.isRunning { session.stopRunning()  } }

    // Switch between front/back camera at runtime
    func switchTo(position: AVCaptureDevice.Position) {
        guard position != currentPosition else { return }

        session.beginConfiguration()

        // Remove existing video inputs
        for input in session.inputs {
            if let di = input as? AVCaptureDeviceInput, di.device.hasMediaType(.video) {
                session.removeInput(di)
            }
        }

        // Add new input
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
            currentPosition = position
        } else {
            print("Could not switch camera to \(position).")
        }

        // Update mirroring on the video output
        if let conn = videoOutput?.connection(with: .video),
           conn.isVideoMirroringSupported {
            conn.isVideoMirrored = (currentPosition == .front)
            conn.videoOrientation = .portrait
        }

        session.commitConfiguration()
    }

    // Delegate → emit CVPixelBuffer
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if let pb = CMSampleBufferGetImageBuffer(sampleBuffer) {
            onFrame?(pb)
        }
    }
}
