//
//  DroneNodeManager.swift
//  ShootingApp
//
//  Created by Jose on 20/12/2024.
//

import Foundation
import SceneKit

final class DroneNodeManager: BaseNodeManager<ARDroneNode, DroneData> {
    weak var delegate: NodeManagerDelegate?
    
    override func spawnNode(for drone: DroneData) {
        data.append(drone)
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            self.nodes = self.nodes.filter { $0.parent != nil }
            let position = self.generateSpawnPosition(drone: drone)
            let node = ARDroneNode(with: drone.droneId, type: .fourRotorOne, position: position)
            
            DispatchQueue.main.async {
                self.sceneView.scene.rootNode.addChildNode(node)
                self.nodes.append(node)
                self.delegate?.nodeManagerDidUpdateDroneCount(self, count: self.nodes.count)
            }
        }
    }
    
    override func handleHit(node: ARDroneNode) -> Bool {
        let removed = node.droneWasHit()
        if removed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.removeNode(node)
                self.delegate?.nodeManagerDidUpdateDroneCount(self, count: self.nodes.count)
                
                if let drone = self.data.first(where: { $0.droneId == node.nodeId }) {
                    self.delegate?.nodeManager(self, droneHit: drone)
                    self.data.removeAll { $0 == drone }
                    SoundManager.shared.playSound(type: .explosion)
                }
            }
        }
        return removed
    }
    
    private func generateSpawnPosition(drone: DroneData) -> SCNVector3 {
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
            return SCNVector3(0, 1, -3)
        }
        
        let playerPosition = SCNVector3(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )
        
        return SCNVector3(
            playerPosition.x + drone.position.x,
            playerPosition.y + drone.position.y,
            playerPosition.z + drone.position.z
        )
    }
}
