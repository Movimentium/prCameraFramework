//
//  CameraVC.swift
//  CameraFramework
//
//  Created by Miguel Gallego on 17/1/25.
//

import UIKit

public protocol CameraDelegate: AnyObject {
    func onCameraCancelButton(cameraVC: CameraVC)
    func orientationDidChanged(orientation: UIDeviceOrientation)
}

public class CameraVC: UIViewController, CameraViewInterface {
        
    let presenter = CameraPresenter()
    public weak var delegate: CameraDelegate?
    let cancelBtn = UIButton()
    let shutterBtn = UIButton()

    public var position: CameraPosition = .back {
        didSet {
            if presenter.session.isRunning {
                presenter.session.stopRunning()
                presenter.configure()
                startSession()
            }
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        presenter.viewInterface = self
    }
    
    required init?(coder: NSCoder) {  // Never used: no .xib, no .storyboard
        super.init(coder: coder)
    }
    
    // MARK: - View life cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createUI()
        presenter.configure()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification, 
                                               object: nil)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateBtnsFrames()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, 
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    // MARK: - Public methods
    public func startSession() {
        presenter.startSession()
    }
    
    // MARK: - Private view logic methods
    func createUI() {
        let previewCALayer = presenter.previewCALayer
        previewCALayer.frame = view.bounds
        view.layer.addSublayer(previewCALayer)
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(onCancelBtn), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        let imgShutter = UIImage(named: "imgShutter",
                                 in: Bundle(for: Self.self),
                                 compatibleWith: nil )
        shutterBtn.setImage(imgShutter, for: .normal)
        shutterBtn.addTarget(self, action: #selector(onShutterBtn), for: .touchUpInside)
        view.addSubview(shutterBtn)
    }
    
    @objc func orientationChanged() {
        let orientation = UIDevice.current.orientation
        delegate?.orientationDidChanged(orientation: orientation)
        guard let connection = presenter.previewCALayer.connection else { return }
        presenter.previewCALayer.frame = view.bounds
        switch orientation {
        case .portrait:            connection.videoOrientation = .portrait
        case .portraitUpsideDown:  connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:       connection.videoOrientation = .landscapeLeft
        case .landscapeRight:      connection.videoOrientation = .landscapeRight
        default:
            fatalError("\(Self.self) \(#function)")
        }
        updateBtnsFrames()
    }
            
    // Buttons related methods
    func updateBtnsFrames() {
        let safeBottom = view.safeAreaInsets.bottom
        let safeLeft = view.safeAreaInsets.left
        cancelBtn.frame = CGRect(x: view.frame.minX + safeLeft + 10,
                                 y: view.frame.maxY - safeBottom - 50,
                                 width: 70, height: 30)
        shutterBtn.frame = CGRect(x: view.frame.midX - 35,
                                  y: view.frame.maxY - safeBottom - 80,
                                  width: 70, height: 70)
    }
    
    @objc func onCancelBtn() {
        delegate?.onCameraCancelButton(cameraVC: self)
    }
    
    @objc func onShutterBtn() {
        presenter.captureImage()
    }
    
    // CameraViewInterface
    func captured(image: UIImage) {
        // TODO:
    }
}
