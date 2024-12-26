//
//  Environment.swift
//  ShootingApp
//
//  Created by Jose on 07/12/2024.
//

import Foundation

struct Environment {
    private static let baseURL: String = {
        guard let path = Bundle.main.path(forResource: "URLs", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let baseURL = plist["BaseURL"] as? String else {
            fatalError("BaseURL is missing in URLs.plist")
        }
        return baseURL
    }()
    
    private static let apiPort: Int = {
        guard let path = Bundle.main.path(forResource: "URLs", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiPort = plist["APIPort"] as? Int else {
            fatalError("APIPort is missing in URLs.plist")
        }
        return apiPort
    }()
    
    private static let socketPort: Int = {
        guard let path = Bundle.main.path(forResource: "URLs", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let socketPort = plist["SocketPort"] as? Int else {
            fatalError("SocketPort is missing in URLs.plist")
        }
        return socketPort
    }()
    
    static var apiURL: URL {
        URL(string: "https://\(baseURL)")!
    }
    
    static var socketURL: URL {
        URL(string: "wss://\(baseURL):\(socketPort)")!
    }
}
