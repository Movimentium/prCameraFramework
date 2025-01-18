//
//  MainVC.swift
//  SampleAppForCamFramework
//
//  Created by Miguel Gallego on 17/1/25.
//

import UIKit
import CameraFramework

class MainVC: UIViewController, CameraDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let camVC = CameraVC()
        camVC.position = .back
        camVC.delegate = self
        camVC.modalPresentationStyle = .fullScreen
        camVC.modalTransitionStyle = .coverVertical
        present(camVC, animated: true) {
            camVC.startSession()
        }
    }
    
    @objc func orientationChanged() {
        let orientation = UIDevice.current.orientation
        print(Self.self, #function, orientation)

    }
    
    // MARK: - CameraDelegate
    func onCameraCancelButton(cameraVC: CameraFramework.CameraVC) {
        cameraVC.dismiss(animated: true)
    }
    
    func orientationDidChanged(orientation: UIDeviceOrientation) {
        print(Self.self, #function, orientation)
    }

}
