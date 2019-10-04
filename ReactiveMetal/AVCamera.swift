//
//  AVCamera.swift
//  ReactiveMetal
//
//  Created by s.kananat on 2018/12/05.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift

// MARK: Main
/// AVFoundation camera
final class AVCamera: NSObject {
    
    /// Dispatch queue for camera session output
    private let dispatchQueue = DispatchQueue(label: "com.donuts.ReactiveMetal.AVCamera")
    
    /// Captured sample buffer (reactive)
    private let _sampleBuffer = MutableProperty<CMSampleBuffer?>(nil)
    
    /// Is session running (reactive)
    let isRunning = MutableProperty<Bool>(true)
    
    /// Is session pausing (reactive)
    let isPausing = MutableProperty<Bool>(false)
    
    /// Video orientation (reactive)
    let orientation = MutableProperty<AVCaptureVideoOrientation>(.portrait)
    
    /// Capture session
    private let session: AVCaptureSession = {
        let session = AVCaptureSession()
        
        if session.canSetSessionPreset(.hd1280x720) { session.sessionPreset = .hd1280x720 }
        else if session.canSetSessionPreset(.high) { session.sessionPreset = .high }
            
        return session
    }()
    
    /// Capture session input
    private let input: AVCaptureInput
    
    /// Capture session output
    private lazy var output: AVCaptureOutput = {
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: self.dispatchQueue)
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
        
        return output
    }()
    
    /// Init with a camera position
    init?(position: AVCaptureDevice.Position = .front) {

        // Requests access to camera
        var granted = true
        
        AVCaptureDevice.requestAccess(for: .video) { granted = $0 }
        
        guard granted else { return nil }

        // Discovers capture input devices
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
        
        guard devices.count > 0 else { return nil }
        
        guard let input = try? AVCaptureDeviceInput(device: devices[0]) else { return nil }

        self.input = input
        
        super.init()
        
        // Begin atomic operation
        self.session.beginConfiguration()
        
        // Add input to session
        guard self.session.canAddInput(input) else { return nil }
        
        self.session.addInput(input)

        // Add output to session
        guard self.session.canAddOutput(self.output) else { return nil }
        
        self.session.addOutput(self.output)
        
        // Finish atomic operation
        self.session.commitConfiguration()
        
        guard let connection = self.output.connection(with: .video) else { return nil }
        
        // Fix video orientation
        self.orientation.producer.startWithValues { [weak self] value in
            guard let `self` = self else { return }
            
            guard let connection = `self`.output.connection(with: .video),
                connection.isVideoOrientationSupported
                else { return }
            
            connection.videoOrientation = value
        }
        
        // Fix mirror
        if connection.isVideoMirroringSupported { connection.isVideoMirrored = position == .front }
        
        // Reactively bind
        self.bind()
    }
    
    deinit { self.stopCapture() }
}

// MARK: Protocol
extension AVCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard self.output == output, !self.isPausing.value else { return }

        self._sampleBuffer.swap(sampleBuffer)
    }
}

// MARK: Internal
internal extension AVCamera {

    /// Captured sample buffer (reactive)
    var sampleBuffer: SignalProducer<CMSampleBuffer, Never> { return self._sampleBuffer.producer.skipNil() }
}

// MARK: Private
private extension AVCamera {
    
    /// Reactively bind
    @discardableResult
    func bind() -> Disposable? {
        let disposable = CompositeDisposable()
        
        disposable += self.isRunning.producer.startWithValues { [weak self] value in
            guard let `self` = self else { return }
            
            if value { `self`.startCapture() }
            else { `self`.stopCapture() }
        }
        
        return disposable
    }
    
    // Starts the capture session
    func startCapture() {
        guard !self.session.isRunning else { return }
        
        DispatchQueue.main.async { self.session.startRunning() }
    }
    
    // Stops the capture session
    func stopCapture() {
        guard self.session.isRunning else { return }
        
        DispatchQueue.main.async { self.session.stopRunning() }
    }
}
