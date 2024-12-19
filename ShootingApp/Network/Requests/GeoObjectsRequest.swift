//
//  GeoObjectsRequest.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import Foundation

struct GeoObjectsRequest: NetworkRequest {
    var body: Data?
    
    let latitude: Double
    let longitude: Double
    let radius: Double // in meters
    
    var path: String {
        "api/v1/geo-objects"
    }
    
    var method: String { "GET" }
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    // Include location parameters in the URL
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "radius", value: String(radius))
        ]
    }
}
