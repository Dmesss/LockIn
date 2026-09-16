import AppKit
import AVFoundation

public class CameraMirrorController: NSObject {
    public static let shared = CameraMirrorController()

    private var captureSession: AVCaptureSession?
    private var videoInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "com.duckpet.cameramirror", qos: .userInitiated)
    public private(set) var isRunning: Bool = false

    private override init() {
        super.init()
    }

    public func startSession(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            self.configureAndStartSession(completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureAndStartSession(completion: completion)
                    } else {
                        completion(false)
                    }
                }
            }
        default:
            completion(false)
        }
    }

    private func configureAndStartSession(completion: @escaping (Bool) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            if self.captureSession == nil {
                let session = AVCaptureSession()
                session.beginConfiguration()
                session.sessionPreset = .high

                guard let device = AVCaptureDevice.default(for: .video) else {
                    session.commitConfiguration()
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                        self.videoInput = input
                    }
                } catch {
                    session.commitConfiguration()
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                session.commitConfiguration()
                self.captureSession = session
            }

            guard let session = self.captureSession else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            if !session.isRunning {
                session.startRunning()
            }
            self.isRunning = true

            DispatchQueue.main.async {
                completion(true)
            }
        }
    }

    public func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if let session = self.captureSession {
                if session.isRunning {
                    session.stopRunning()
                }
            }
            self.captureSession = nil
            self.videoInput = nil
            self.isRunning = false
        }
    }

    public func makePreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let session = captureSession else { return nil }
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        if let connection = preview.connection {
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
        return preview
    }

    public func attachPreview(to view: NSView) -> AVCaptureVideoPreviewLayer? {
        guard let session = captureSession else { return nil }
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        if let connection = preview.connection {
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
        view.wantsLayer = true
        preview.frame = view.bounds
        preview.cornerRadius = 18.0
        preview.masksToBounds = true
        view.layer?.addSublayer(preview)
        return preview
    }
}
