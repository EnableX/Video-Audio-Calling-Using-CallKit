//
//  VCXServicesClass.swift
//  sampleTextApp
//
//  Created by JayKumar on 15/11/18.
//  Copyright © 2018 VideoChat. All rights reserved.
//

import Foundation
import UIKit

class VCXServicesClass: NSObject {
    
    
    // MARK: - Create Room
    /**
     Input Parameter : - App Id and App Key
     Return :- EnxRoomInfoModel
     **/
    class func createRoom(completion:@escaping (EnxRoomInfoModel) -> ()){
        //create the url with URL
        let url = URL(string: kBasedURL + "createRoom")!
        //Create A session Object
        let session = URLSession.shared
        //Now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //Create Base64 Encription
        if(kTry){
            request.addValue(kAppId, forHTTPHeaderField: "x-app-id")
            request.addValue(kAppkey, forHTTPHeaderField: "x-app-key")
        }
        //create dataTask using the session object to send data to the server
        let tast = session.dataTask(with: request as URLRequest){(data,response, error) in
            guard error == nil else{
                let roomdataModel = EnxRoomInfoModel()
                roomdataModel.error = error?.localizedDescription
                completion(roomdataModel)
                return}
            guard let data = data else {
                let roomdataModel = EnxRoomInfoModel()
                roomdataModel.isRoomFlag = false
                completion(roomdataModel)
                return}
            do{
                if let responseValue = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]{
                    print("Create Room response",responseValue)
                    let roomdataModel = EnxRoomInfoModel()
                    if (responseValue["result"] as! Int) == 0{
                        if let respValue = responseValue["room"] as? [String : Any]{
                            roomdataModel.room_id = (respValue["room_id"] as! String)
                            let settingValue = respValue["settings"] as! [String : Any]
                            roomdataModel.mode = (settingValue["mode"] as! String)
                            roomdataModel.isRoomFlag = true
                        }
                        else{
                            roomdataModel.isRoomFlag = false
                        }
                    }
                    else{
                        roomdataModel.isRoomFlag = false
                    }
                    completion(roomdataModel)
                }
            }catch{
                let roomdataModel = EnxRoomInfoModel()
                roomdataModel.error = error.localizedDescription
                completion(roomdataModel)
                print(error.localizedDescription)
            }
        }
        tast.resume()
    }
    
    // MARK: - VAlidate RoomId
    /**
     Input Parameter : - RoomId
     Return :- EnxRoomInfoModel
     **/
    class func fetchRoomInfoWithRoomId(roomId : String , completion:@escaping (EnxRoomInfoModel) -> ()){
        let url = URL(string: kBasedURL + "getRoom/\(roomId)")!
        //Create A session Object
        let session = URLSession.shared
        //Now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if(kTry){
             request.addValue(kAppId, forHTTPHeaderField: "x-app-id")
             request.addValue(kAppkey, forHTTPHeaderField: "x-app-key")
        }
        //create dataTask using the session object to send data to the server
        let tast = session.dataTask(with: request as URLRequest){(data,response, error) in
            guard error == nil else{
                let roomdataModel = EnxRoomInfoModel()
                roomdataModel.error = error?.localizedDescription
                completion(roomdataModel)
                return}
            guard let data = data else {
                let roomdataModel = EnxRoomInfoModel()
                roomdataModel.isRoomFlag = false
                completion(roomdataModel)
                return}
            do{
                if let responseValue = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]{
                    print("response Value",responseValue)
                    let roomdataModel = EnxRoomInfoModel()
                    if (responseValue["result"] as! Int) == 0{
                        if let respValue = responseValue["room"] as? [String : Any]{
                            roomdataModel.room_id = (respValue["room_id"] as! String)
                            let settingValue = respValue["settings"] as! [String : Any]
                            roomdataModel.mode = (settingValue["mode"] as! String)
                            roomdataModel.isRoomFlag = true
                        }
                        else{
                            roomdataModel.isRoomFlag = false
                            roomdataModel.error = nil
                        }
                    }
                    else{
                        roomdataModel.isRoomFlag = false
                        roomdataModel.error = (responseValue["error"] as! String)
                    }
                    completion(roomdataModel)
                }
                
            }catch {
                let roomdataModel = EnxRoomInfoModel()
                roomdataModel.error = error.localizedDescription
                completion(roomdataModel)
            }
        }
        tast.resume()
    }
    
    
    // MARK: - featchToken
    /**
     Input Parameter : - [String : String]
     Return :- VCXRoomInfoModel
     **/
    class func featchToken(requestParam : [String: String] , completion:@escaping (String) -> ()){
        //create the url with URL
        let url = URL(string: kBasedURL + "createToken")!
        //Create A session Object
        let session = URLSession.shared
        //Now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: requestParam, options:.prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //Create Base64 Encription
        if(kTry){
            request.addValue(kAppId, forHTTPHeaderField: "x-app-id")
            request.addValue(kAppkey, forHTTPHeaderField: "x-app-key")
        }
        //create dataTask using the session object to send data to the server
        let tast = session.dataTask(with: request as URLRequest){(data,response, error) in
            guard error == nil else{
                completion("Error")
                return}
            guard let data = data else {
                completion("Error")
                return}
            do{
                if let responseValue = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]{
                    print(responseValue)
                    completion((responseValue["token"] as? String)!)
                }
            }catch{
                completion("Error")
                print(error.localizedDescription)
            }
        }
        tast.resume()
        
    }
}
