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
    var remoteRoom : EnxRoom!
    var objectJoin : EnxRtc!
    var localStream : EnxStream!
    
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
        if(remoteRoom != nil){
            remoteRoom.disconnect()
            remoteRoom = nil;
        }
        if(objectJoin != nil){
            objectJoin = nil;
        }
        if(localStream != nil){
            localStream = nil;
        }
        hasEnded = true
    }
    func startAudio() {
        
    }
    private func setUproom(){
        objectJoin = EnxRtc()
        self.createToken()
    }
    func createToken(){
        guard let appdel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let inputParam : [String : String] = ["name" :"Jay" , "role" :  "participant" ,"roomId" : appdel.room_Id, "user_ref" : "2236"]
        VCXServicesClass.featchToken(requestParam: inputParam, completion:{token  in
            DispatchQueue.main.async {
                //  Success Response from server
                    let videoSize : NSDictionary =  ["minWidth" : 720 , "minHeight" : 480 , "maxWidth" : 1280, "maxHeight" :720]
                let roomInfo : [String : Any] = ["allow_reconnect" :true , "number_of_attempts" :  3 ,"timeout_interval" : 20, "audio_only" : true]
                    let localStreamInfo : NSDictionary = ["video" : false ,"audio" : true  ,"data" :true ,"name" :"EnxCall","type" : "public" ,"maxVideoBW" : 400 ,"minVideoBW" : 300 , "videoSize" : videoSize]
                guard let stream = self.objectJoin.joinRoom(token, delegate: self, publishStreamInfo: (localStreamInfo as! [AnyHashable : Any]), roomInfo: (roomInfo as [AnyHashable : Any]), advanceOptions: nil) else{
                    return
                }
                self.localStream = stream
                self.localStream.delegate = self as EnxStreamDelegate
            }
        })
    }
}
/*
 // MARK: - Extension
 Delegates Methods
 */
extension EnxCall : EnxRoomDelegate, EnxStreamDelegate {
    //Mark - EnxRoom Delegates
    /*
     This Delegate will notify to User Once he got succes full join Room
     */
    func room(_ room: EnxRoom?, didConnect roomMetadata: [AnyHashable : Any]?) {
        hasConnected = true
        startCallCompletion?(true)
        answCallCompletion?(true)
        remoteRoom = room
        remoteRoom.publish(localStream)
    }
    /*
     This Delegate will notify to User Once he Getting error in joining room
     */
     func room(_ room: EnxRoom?, didError reason: [Any]?) {
    }
    /*
     This Delegate will notify to  User Once he Publisg Stream
     */
    func room(_ room: EnxRoom?, didPublishStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to  User Once he Unpublisg Stream
     */
    func room(_ room: EnxRoom?, didUnpublishStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if any new person added to room
     */
    func room(_ room: EnxRoom?, didAddedStream stream: EnxStream?) {
        room!.subscribe(stream!)
    }
    /*
     This Delegate will notify to User if any new person Romove from room
     */
    func room(_ room: EnxRoom?, didRemovedStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User to subscribe other user stream
     */
    func room(_ room: EnxRoom?, didSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User to Unsubscribe other user stream
     */
    func room(_ room: EnxRoom?, didUnSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if Room Got discunnected
     */
    func roomDidDisconnected(_ status: EnxRoomStatus) {
        // self.leaveRoom()
        //self.navigationController?.popViewController(animated: true)
        
    }
    /*
     This Delegate will notify to User if any person join room
     */
    func room(_ room: EnxRoom?, userDidJoined Data: [Any]?) {
        //listOfParticipantInRoom.append(Data!)
    }
    /*
     This Delegate will notify to User if any person got discunnected
     */
    func room(_ room: EnxRoom?, userDidDisconnected Data: [Any]?) {
        //self.leaveRoom()
        remoteRoom?.disconnect()
    }
    /*
     This Delegate will notify to User if any person got discunnected
     */
    func room(_ room: EnxRoom?, didChange status: EnxRoomStatus) {
        //To Do
    }
    /*
     This Delegate will notify to User once any stream got publish
     */
    func room(_ room: EnxRoom?, didReceiveData data: [AnyHashable : Any]?, from stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User to get updated attributes of particular Stream
     */
    func room(_ room: EnxRoom?, didUpdateAttributesOf stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if any new User Reconnect the room
     */
    func room(_ room: EnxRoom?, didReconnect reason: String?) {
        //To Do
    }
    /*
     This Delegate will notify to User with active talker list
     */
    func room(_ room: EnxRoom?, activeTalkerList Data: [Any]?) {
        //To Do
        
    }
    
    func room(_ room: EnxRoom?, didEventError reason: [Any]?) {
        //let resDict = reason![0] as! [String : Any]
    }
    
    //Mark- EnxStreamDelegate Delegate
    /*
     This Delegate will notify to current User If User will do Self Stop Video
     */
    func stream(_ stream: EnxStream?, didSelfMuteVideo data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If User will do Self Start Video
     */
    func stream(_ stream: EnxStream?, didSelfUnmuteVideo data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If User will do Self Mute Audio
     */
    func stream(_ stream: EnxStream?, didSelfMuteAudio data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If User will do Self UnMute Audio
     */
    func stream(_ stream: EnxStream?, didSelfUnmuteAudio data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If any user has stoped There Video or current user Video
     */
    func didVideoEvents(_ data: [AnyHashable : Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If any user has stoped There Audio or current user Video
     */
    func didAudioEvents(_ data: [AnyHashable : Any]?) {
        //To Do
    }
    
}
