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

final class CameraPresenter: NSObject, AVCapturePhotoCaptureDelegate {
    weak var viewInterface: CameraViewInterface?
    let session = AVCaptureSession()
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .unspecified)
    var videoInput: AVCaptureDeviceInput?
    let videoOutput = AVCaptureVideoDataOutput()
    let photoOutput = AVCapturePhotoOutput()
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
        recycleDeviceIO()
        guard let input = getNewInputDevice(),
              session.canAddInput(input), session.canAddOutput(videoOutput),
              session.canAddOutput(photoOutput)
        else {
            print(Self.self, #function, "Error");  return
        }
        videoInput = input
        session.addInput(input)
        session.addOutput(videoOutput)
        session.addOutput(photoOutput)
        session.commitConfiguration()
    }
    
    func recycleDeviceIO() {
        session.inputs.forEach { self.session.removeInput($0) }
        session.outputs.forEach { self.session.removeOutput($0) }
    }
    
    func getAVCaptureDevice(withPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        discoverySession.devices.first { $0.position == position }
    }
    
    func getNewInputDevice() -> AVCaptureDeviceInput? {
        do {
            guard let position = viewInterface?.position else {
                print(Self.self, #function, "Error");  return nil
            }
            guard let device = getAVCaptureDevice(withPosition: position.avCaptureDevicePosition) else {
                print(Self.self, #function, "Error");  return nil
            }
            let input = try AVCaptureDeviceInput(device: device)
            return input
        } catch {
            print(Self.self, #function, error.localizedDescription)
            return nil
        }
    }
    
    func captureImage() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) 
    {
        guard let cgImage = photo.cgImageRepresentation() else {
            return
        }
        viewInterface?.captured(image: UIImage(cgImage: cgImage))
    }
}
