//
//  ViewController.swift
//  sampleCallkit
//
//  Created by Jay Kumar on 20/08/19.
//  Copyright © 2019 Jay Kumar. All rights reserved.
//

import UIKit
import EnxRTCiOS
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var trigerCallBtn: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPrivacyAccess()
        // Do any additional setup after loading the view.
    }
    private func getPrivacyAccess(){
        let vStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if(vStatus == AVAuthorizationStatus.notDetermined){
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            })
        }
        let aStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        if(aStatus == AVAuthorizationStatus.notDetermined){
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangedNotification(notification:)), name: EnxCallManager.callsChangedNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func trigerCallEvent(_ sender: Any) {
        guard let appdel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if trigerCallBtn.titleLabel?.text == "Call Triger"{
            
            appdel.callManager.startCall(handle: "Call To Me")
            trigerCallBtn.setTitle("End Call", for: .normal)
            trigerCallBtn.setTitleColor(.red, for: .normal)
        }
        else{
            endCall()
            trigerCallBtn.setTitle("Call Triger", for: .normal)
            trigerCallBtn.setTitleColor(.black, for: .normal)
        }
    }
    @objc func handleChangedNotification(notification: NSNotification) {
        guard let appdel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if(appdel.callManager.calls.count > 0){
            let call = appdel.callManager.calls[0]
            
            if(call.isOnHild){
                
            }else{
                trigerCallBtn.setTitle("End Call", for: .normal)
                trigerCallBtn.setTitleColor(.red, for: .normal)
            }
        }else{
            trigerCallBtn.setTitle("Call Triger", for: .normal)
            trigerCallBtn.setTitleColor(.black, for: .normal)
        }
    }
    fileprivate func endCall(){
        guard let appdel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        for call in appdel.callManager.calls{
            appdel.callManager.endCall(call: call)
        }
    }
}

