//
//  EnxCallManager.swift
//  sampleCallkit
//
//  Created by Jay Kumar on 21/08/19.
//  Copyright © 2019 Jay Kumar. All rights reserved.
//

import UIKit
import CallKit
import NWPusher

class EnxCallManager: NSObject {
    let callContr = CXCallController()
    func startCall(handle : String , video : Bool = false) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCall = CXStartCallAction(call: UUID(), handle: handle)
        startCall.isVideo = video
        let callTransaction = CXTransaction()
        callTransaction.addAction(startCall)
        requestCall(callTransaction, action: "startCall")
    }
    func endCall(call : EnxCall){
        let endCall = CXEndCallAction(call: call.uuid)
        let callTransaction = CXTransaction()
        callTransaction.addAction(endCall)
        requestCall(callTransaction, action: "endCall")
    }
    func setHeld(call : EnxCall , onHold : Bool){
        let handleCall = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let callTransaction = CXTransaction()
        callTransaction.addAction(handleCall)
        requestCall(callTransaction, action: "holdCall")
    }
    private func requestCall(_ callTrans : CXTransaction , action : String = ""){
        callContr.request(callTrans){ error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                if(action == "startCall"){
                    self.pushCalltoDevice()
                }
                else if(action == "endCall"){
                    self.pushEndCallNotification()
                }
                print("Requested transaction \(action) successfully")
            }
        }
    }
    //Mark push message for Start call
    fileprivate func pushCalltoDevice(){
        let bundleurl  = Bundle.main.url(forResource: "push", withExtension: "p12", subdirectory: "resource.bundle")
        let data = NSData(contentsOf: bundleurl!)
        do{
            let pusher = try NWPusher.connect(withPKCS12Data: data as Data?, password: "enablex201301", environment: .sandbox)
            //5BEDD42D9CE7F258E1F72C1B042062CDCB84D12C31AFE1D0E58DB197AF2C7197  -- My phone
            let payload = "{\"aps\":{\"UUID\":\"\(UUID())\",\"handle\":\"start call\"}}"
            let token = "A022E64D8DE7D72447BAFB53AD37190B0A5DD9C89B1859502D2B29742D201367"
            do {
                try pusher.pushPayload(payload, token: token, identifier: UInt(arc4random()))
            } catch{
                print(error)
            }
        }catch{
            print(error)
        }
    }
    //Mark push message for End call
    fileprivate func pushEndCallNotification(){
        let bundleurl  = Bundle.main.url(forResource: "push", withExtension: "p12", subdirectory: "resource.bundle")
        let data = NSData(contentsOf: bundleurl!)
        do{
            let pusher = try NWPusher.connect(withPKCS12Data: data as Data?, password: "enablex201301", environment: .sandbox)
            //A022E64D8DE7D72447BAFB53AD37190B0A5DD9C89B1859502D2B29742D201367  -- office phone
            let payload = "{\"aps\":{\"UUID\":\"\(UUID())\",\"handle\":\"end call\"}}"
            let token = "A022E64D8DE7D72447BAFB53AD37190B0A5DD9C89B1859502D2B29742D201367"
            do {
                try pusher.pushPayload(payload, token: token, identifier: UInt(arc4random()))
            } catch{
                print(error)
            }
        }catch{
            print(error)
        }
    }
    //Mark : Call Managment
    static let callsChangedNotification = Notification.Name("CallsChangedNotification")
    private(set) var calls = [EnxCall]()
    func callWithUUID(uuid : UUID) -> EnxCall?{
        return calls[0]
    }
    func addCall(_ call : EnxCall){
        calls.append(call)
        call.stateDidChange = {[weak self] in
            self?.postCallNotification()
        }
        postCallNotification()
    }
    func removeCall(_ Call : EnxCall){
        let index = calls.firstIndex(where: {
            $0 === Call
        })
        calls.remove(at: index!)
        postCallNotification()
    }
    func removeAllCalls(){
        calls.removeAll()
        postCallNotification()
    }
    private func postCallNotification(){
        NotificationCenter.default.post(name: type(of: self).callsChangedNotification, object: self)
    }
}
