//
//  MainVC.swift
//  SampleAppForCamFramework
//
//  Created by Miguel Gallego on 17/1/25.
//

import UIKit
import CameraFramework

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let camVC = CameraVC()
        camVC.modalPresentationStyle = .fullScreen
        camVC.modalTransitionStyle = .coverVertical
        present(camVC, animated: true) {
            camVC.startSession()
        }
    }
    

}
