//
//  scanVC.swift
//  Sommelier
//
//  Created by Damian on 08/12/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import ARKit

class scanVC: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // Do any additional setup after loading the view.
    }

}

extension scanVC: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func getPlaneNode(withReferenceImage image: ARReferenceImage) -> SCNNode {
        let plane = SCNPlane(width: image.physicalSize.width,
                             height: image.physicalSize.height)
        let node = SCNNode(geometry: plane)
        return node
    }
    
    func getNode(withImageName name: String) -> SCNNode {
        var node = SCNNode()
//        switch name {
//        case "Book":
//            node = bookNode
//        case "Snow Mountain":
//            node = mountainNode
//        case "Trees In the Dark":
//            node = treeNode
//        default:
//            break
//        }
        return node
    }
    
}
