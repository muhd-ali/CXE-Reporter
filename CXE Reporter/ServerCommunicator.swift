//
//  ServerCommunicator.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 3/3/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation
import Alamofire

class ServerCommunicator: NSObject {
    static let shared = ServerCommunicator()
    
    let serverURL = "http://localhost:8000"
    
    func send(reportJSON: [String: Any], callback: @escaping (Bool) -> Void) {
        Alamofire.request(
            "\(self.serverURL)/report",
            method: .post,
            parameters: [
                "data": reportJSON,
            ],
            encoding: JSONEncoding.default
            ).validate().response { (response) in
                let statusCode = response.response?.statusCode ?? -1
                if statusCode == 200 {
                    callback(true)
                } else {
                    callback(false)
                }
        }
    }
}
