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
    
    struct Server {
        static let ip_address = "localhost"
        static let port_number = 8000
        static var reportURL: String {
            let ip = Server.ip_address
            let port = Server.port_number
            return "http://\(ip):\(port)/report"
        }
    }
    
    func send(reportJSON: [String: Any], callback: @escaping (Bool) -> Void) {
        Alamofire.request(
            Server.reportURL,
            method: .post,
            parameters: [
                "report": reportJSON,
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
