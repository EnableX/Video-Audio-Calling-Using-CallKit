//
//  ViewController.swift
//  sampleCallkit
//
//  Created by Jay Kumar on 20/08/19.
//  Copyright © 2019 Jay Kumar. All rights reserved.
//
import Foundation
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
        if trigerCallBtn.titleLabel?.text == "Call Triger"{
            //Create Room
            createRoom();
        }
        else{
            endCall()
            //pushEndCallNotification()
            trigerCallBtn.setTitle("Call Triger", for: .normal)
            trigerCallBtn.setTitleColor(.black, for: .normal)
        }
    }
    func createRoom(){
        guard EnxNetworkManager.isReachable() else {
            self.showAleartView(message:"Kindly check your Network Connection", andTitles: "OK")
            return
        }
        VCXServicesClass.createRoom(completion:{roomModel  in
            DispatchQueue.main.async {
                //Success Response from server
                if roomModel.room_id != nil{
                    let appdel = UIApplication.shared.delegate as? AppDelegate
                    appdel!.room_Id = roomModel.room_id
                    //Triget Call
                    appdel!.callManager.startCall(handle: "Jay Kumar", roomID: roomModel.room_id)
                    self.trigerCallBtn.setTitle("End Call", for: .normal)
                    self.trigerCallBtn.setTitleColor(.red, for: .normal)
                }
                //Handeling server giving no error but due to wrong PIN room not available
                else if roomModel.isRoomFlag == false && roomModel.error == nil {
                    self.showAleartView(message:"Unable to connect, Kindly try again", andTitles: "OK")
                }
                //Handeling server error
                else{
                    print(roomModel.error!)
                    self.showAleartView(message:roomModel.error, andTitles: "OK")
                }
            }
        })
    }
    // MARK: - Show Alert
    /**
     Show Alert Based in requirement.
     Input parameter :- Message and Event name for Alert
     **/
    private func showAleartView(message : String, andTitles : String){
        let alert = UIAlertController(title: " ", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: andTitles, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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

