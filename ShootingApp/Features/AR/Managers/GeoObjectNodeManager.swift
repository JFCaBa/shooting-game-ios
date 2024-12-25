//
//  GeoObjectNodeManager.swift
//  ShootingApp
//
//  Created by Jose on 20/12/2024.
//

import Foundation

final class GeoObjectNodeManager: BaseNodeManager<GeoARNode, GeoObject> {
    weak var delegate: NodeManagerDelegate?
    
    override func spawnNode(for geoObject: GeoObject) {        
        data.append(geoObject)
        var node = GeoARNodeFactory.createNode(for: geoObject, location: .init(x: 0, y: 10, z: 0))
        
        if let location = LocationManager.shared.location {
            node.updatePosition(
                relativeTo: location,
                heading: LocationManager.shared.heading
            )
        }
        
        node = GeoARNodeFactory.createNode(for: geoObject, location: node.position)
        
        sceneView.scene.rootNode.addChildNode(node)
        nodes.append(node)
        
        delegate?.nodeManagerDidUpdateGeoObjectCount(self, count: nodes.count)
    }
    
    override func handleHit(node: GeoARNode) -> Bool {
        let removed = node.geoObjectWasHit()
        if removed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.removeNode(node)
                self.delegate?.nodeManagerDidUpdateGeoObjectCount(self, count: self.nodes.count)
                
                if let geoObject = self.data.first(where: { $0.id == node.nodeId }) {
                    self.delegate?.nodeManager(self, geoObjectHit: geoObject)
                    self.data.removeAll { $0 == geoObject }
                }
            }
        }
        return removed
    }
}
