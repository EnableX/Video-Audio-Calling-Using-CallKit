//
//  EnxCall.swift
//  sampleCallkit
//
//  Created by Jay Kumar on 21/08/19.
//  Copyright © 2019 Jay Kumar. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import EnxRTCiOS
class EnxCall: NSObject {
    let uuid : UUID
    let isOutGoing: Bool
    var handle : String?
    //Mark : Start Call properties
    var connectData : Date?{
        didSet{
            stateDidChange?()
            hasStartedConnectDidChange?()
        }
    }
    var connectedData : Date?{
        didSet{
            stateDidChange?()
            hasConnectDidChange?()
        }
    }
    var endDate : Date?{
        didSet{
            stateDidChange?()
            hasEndedDidChang?()
        }
    }
    var isOnHild = false{
        didSet{
            stateDidChange?()
        }
    }
    var isMuted = false{
        didSet{
            
        }
    }
    // Mark:  Change State callback blocks
    var stateDidChange:(() -> Void)?
    var hasStartedConnectDidChange:(() -> Void)?
    var hasConnectDidChange:(() -> Void)?
    var hasEndedDidChang:(() -> Void)?
    
    //Mark Properties Derived
    var hasStartedConnecting : Bool{
        get{
            return connectData != nil
        }
        set{
            connectData = newValue ? Date() : nil
        }
    }
    var hasConnected : Bool{
        get{
            return connectedData != nil
        }
        set{
            connectedData = newValue ? Date() : nil
        }
    }
    var hasEnded : Bool{
        get {
            return endDate != nil
        }
        set{
            endDate = newValue ? Date() : nil
        }
    }
    var duration : TimeInterval{
        guard let connectDate = connectedData else {
            return 0
        }
        return Date().timeIntervalSince(connectDate)
    }
    //Mark : Initialization
    init(uuid : UUID , isOutgoing : Bool = false){
        self.uuid = uuid
        self.isOutGoing = isOutgoing
    }
    //Mark : Call Actions
    var startCallCompletion :((Bool) -> Void)?
    func startCall(withAudioSession audioSession: AVAudioSession ,completion :((_ success : Bool)->Void)?){
        startCallCompletion = completion
         setUproom()
        hasStartedConnecting = true
    }
    var answCallCompletion :((Bool) -> Void)?
    func ansCall(withAudioSession audioSession: AVAudioSession ,completion :((_ success : Bool)->Void)?){
        answCallCompletion = completion
        setUproom()
        hasStartedConnecting = true
    }
    func endCall(){
  
        hasEnded = true
    }
    func startAudio() {
        
    }
    private func setUproom(){
         NotificationCenter.default.post(name: NSNotification.Name("startCallTriger"), object: nil)
    }
}
