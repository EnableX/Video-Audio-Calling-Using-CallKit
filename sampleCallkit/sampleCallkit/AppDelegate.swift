//
//  AppDelegate.swift
//  sampleCallkit
//
//  Created by Jay Kumar on 20/08/19.
//  Copyright © 2019 Jay Kumar. All rights reserved.
//

import UIKit
import PushKit
import CallKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = EnxCallManager()
    var providerDelegate : ProviderDelegate?
    var room_Id : String = "Room ID"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        providerDelegate = ProviderDelegate(callManager: callManager)
        pushRegistry.delegate = self as? PKPushRegistryDelegate
        pushRegistry.desiredPushTypes = [.voIP]
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
extension AppDelegate : PKPushRegistryDelegate{
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("\(#function) token: \(pushCredentials.token)")
        let deciceToken = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        print("\(#function) token is: \(deciceToken)")
    }
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("\(#function) incoming voip call notfication: \(payload.dictionaryPayload)")
        let payLoadValue =  payload.dictionaryPayload["aps"] as! [String : String]
        if((payLoadValue["roomId"]) != nil){
            room_Id = payLoadValue["roomId"]!
        }
        if let uuidString = payLoadValue["UUID"] , let handle = payLoadValue["handle"] , let uuid = UUID(uuidString: uuidString){
            if(handle == "start call"){
                let backGroundTaskIndet = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                self.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: false){ _ in
                    UIApplication.shared.endBackgroundTask(backGroundTaskIndet)
                }
            }
            if(handle == "end call"){
                for call in callManager.calls{
                    callManager.endCall(call: call)
                }
            }
        }
    }
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("\(#function)  invalidated token")
    }
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        providerDelegate?.reportIncomingCalls(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
}
