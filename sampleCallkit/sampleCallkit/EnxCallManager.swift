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
                print("Requested transaction \(action) successfully")
            }
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
