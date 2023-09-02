//
//  ViewController.swift
//  BasicARApp
//
//  Created by sludgebox on 02/09/2023.
//

import ARKit
import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    // MARK: Setup methods
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        // can also do image tracking here
        config.planeDetection = [.horizontal, .vertical]
        // env texturing only available on ios 12+
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }
    
    // MARK: Object placement
    @objc
    func handleTap(recognizer: UITapGestureRecognizer ) {
        let location = recognizer.location(in: arView)
        let results =  arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "fender_stratocaster", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Object placement failed: couldn't find surface")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "fender_stratocaster" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
