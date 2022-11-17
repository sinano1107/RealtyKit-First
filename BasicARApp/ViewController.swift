//
//  ViewController.swift
//  BasicARApp
//
//  Created by 長政輝 on 2022/11/16.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    // MARK: Setup Method
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    // MARK: Object Placement
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "toy_biplane", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("オブジェクトを置けませんでした - 平面が見つかりません")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.load(named: entityName)
        let parentEntity = ModelEntity()
        parentEntity.addChild(entity)
        
        parentEntity.generateCollisionShapes(recursive: true)
        arView.installGestures(for: parentEntity)
        
        let anchorEntity = AnchorEntity(.anchor(identifier: anchor.identifier))
        anchorEntity.addChild(parentEntity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "toy_biplane" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
