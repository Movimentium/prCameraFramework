//
//  CameraPresenter.swift
//  CameraFramework
//
//  Created by Miguel Gallego on 18/1/25.
//

import UIKit
import AVFoundation

public enum CameraPosition {
    case front
    case back
    
    var avCaptureDevicePosition: AVCaptureDevice.Position {
        switch self {
        case .front:  .front
        case .back:   .back
        }
    }
}
 
protocol CameraViewInterface: AnyObject {
    var position: CameraPosition  { get set }
    func captured(image: UIImage)
}

final class CameraPresenter {
    weak var viewInterface: CameraViewInterface?
    let session = AVCaptureSession()
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .unspecified)
    var videoInput: AVCaptureDeviceInput?
    let videoOutput = AVCaptureVideoDataOutput()
    lazy var previewCALayer: AVCaptureVideoPreviewLayer = {
        let previewCALayer = AVCaptureVideoPreviewLayer(session: session)
        previewCALayer.videoGravity = .resizeAspectFill
        return previewCALayer
    }()
    
    func startSession() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.session.startRunning()
        }
    }
    func configure() {
        if let currentInput = videoInput {
            session.removeInput(currentInput)
            session.removeOutput(videoOutput)
        }
        do {
            guard let position = viewInterface?.position else {
                print(Self.self, #function, "Error");  return
            }
            guard let device = getAVCaptureDevice(withPosition: position.avCaptureDevicePosition) else {
                print(Self.self, #function, "Error");  return
            }
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) && session.canAddOutput(videoOutput) {
                videoInput = input
                session.addInput(input)
                session.addOutput(videoOutput)
                session.commitConfiguration()
            } else {
                print(Self.self, #function, "session Error .canAddInput(input) .canAddOutput(videoOutput)")
            }
        } catch {
            print(Self.self, #function, error.localizedDescription)
        }
    }
    
    func getAVCaptureDevice(withPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        discoverySession.devices.first { $0.position == position }
    }
    
    func captureImage() {
        viewInterface?.captured(image: UIImage())
        // TODO:
    }

}
