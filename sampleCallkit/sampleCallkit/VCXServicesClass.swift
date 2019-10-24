//
//  VCXServicesClass.swift
//  sampleTextApp
//
//  Created by JayKumar on 15/11/18.
//  Copyright © 2018 VideoChat. All rights reserved.
// 

import UIKit

class VCXServicesClass: NSObject {
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
