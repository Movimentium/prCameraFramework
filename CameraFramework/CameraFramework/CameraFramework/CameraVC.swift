//
//  CameraVC.swift
//  CameraFramework
//
//  Created by Miguel Gallego on 17/1/25.
//

import UIKit
import AVFoundation

public protocol CameraDelegate: AnyObject {
    func onCameraCancelButton(cameraVC: CameraVC)
}

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

public class CameraVC: UIViewController {
    public weak var delegate: CameraDelegate?
    let cancelBtn = UIButton()
    let session = AVCaptureSession()
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .unspecified)
    var videoInput: AVCaptureDeviceInput?
    let videoOutput = AVCaptureVideoDataOutput()
    lazy var previewCALayer: AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: session)
    }()

    public var postion = CameraPosition.back {
        didSet {
            if session.isRunning {
                session.stopRunning()
                configure()
                startSession()
            }
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {  // Never used: no .xib, no .storyboard
        super.init(coder: coder)
    }
    
    // MARK: - View life cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createUI()
        configure()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUI(withOrientation: UIApplication.shared.statusBarOrientation)
        updateCancelBtnFrame()
    }
    
    
    // MARK: - Public methods
    public func startSession() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    // MARK: - Private methods
    func createUI() {
        previewCALayer.frame = view.bounds
        previewCALayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewCALayer)
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(onCancelBtn), for: .touchUpInside)
        view.addSubview(cancelBtn)
    }
    
    func updateUI(withOrientation orientation: UIInterfaceOrientation) {
        guard let connection = previewCALayer.connection else { return }
        previewCALayer.frame = view.bounds
        switch orientation {
        case .portrait:            connection.videoOrientation = .portrait
        case .portraitUpsideDown:  connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:       connection.videoOrientation = .landscapeLeft
        case .landscapeRight:      connection.videoOrientation = .landscapeRight
        default:
            fatalError("\(Self.self) \(#function)")
        }
    }
    
    func configure() {
        if let currentInput = videoInput {
            session.removeInput(currentInput)
            session.removeOutput(videoOutput)
        }
        do {
            guard let device = getAVCaptureDevice(withPosition: postion.avCaptureDevicePosition) else {
                print(Self.self, #function, "Error")
                return
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
        
    // CancelBtn related methods
    func updateCancelBtnFrame() {
        cancelBtn.frame = CGRect(x: view.frame.minX + 10, y: view.frame.maxY - 50, width: 70, height: 30)
    }
    
    @objc func onCancelBtn() {
        delegate?.onCameraCancelButton(cameraVC: self)
    }
}
