//
//  CameraVC.swift
//  CameraFramework
//
//  Created by Miguel Gallego on 17/1/25.
//

import UIKit
import AVFoundation

public class CameraVC: UIViewController {
    
    let session = AVCaptureSession()
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .unspecified)
    let videoOutput = AVCaptureVideoDataOutput()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        createUI()
        configure()
    }
    
    required init?(coder: NSCoder) {  // Never used: no .xib, no .storyboard
        super.init(coder: coder)
    }
    
    // MARK: - View life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Public methods
    public func startSession() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    // MARK: - Private methods
    func createUI() {
        let previewCALayer = AVCaptureVideoPreviewLayer(session: session)
        previewCALayer.frame = view.bounds
        view.layer.addSublayer(previewCALayer)
    }
    
    func configure() {
        do {
            guard let device = self.avCaptureDevice else {
                print(Self.self, #function, "Error")
                return
            }
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) && session.canAddOutput(videoOutput) {
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
    
    var avCaptureDevice: AVCaptureDevice? {
        discoverySession.devices.first { $0.position == .back }
    }
}
