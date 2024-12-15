//
//  ARDroneNode+DroneType.swift
//  ShootingApp
//
//  Created by Jose on 14/12/2024.
//

import SceneKit

extension ARDroneNode {
    enum DroneType: String {
        case box = "drone_box"
        case fourRotorOne = "drone_four_rotor_one"
        case fourRotorTwo = "drone_four_rotor_two"
        
        var scale: SCNVector3 {
            switch self {
            case .fourRotorOne: return SCNVector3(0.02, 0.02, 0.02)
            case .fourRotorTwo: return SCNVector3(0.002, 0.002, 0.002)
            default: return SCNVector3(1, 1, 1)
            }
        }
        
        var rotateAction: SCNAction {
            switch self {
            case .box:
                return SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 0.5))
            case .fourRotorOne, .fourRotorTwo:
                return SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 0.3))
            }
        }
    }
}
