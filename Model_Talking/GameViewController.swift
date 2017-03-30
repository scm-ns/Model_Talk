//
//  GameViewController.swift
//  Model_Talking
//
//  Created by Mattappali, Sandeep on 3/28/17.
//  Copyright © 2017 Mattappali, Sandeep. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var base_human :SCNNode! = nil
    var interactor : SpeechAnimationCoodinator? = nil
    var camera_node : SCNNode! = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let scene = self.createAndConfigureScene() else { return }
        
        // retrieve the ship node
        base_human = scene.rootNode.childNode(withName: "base_human_armtr", recursively: true)!
        
        // constriant the camera to always look at this model
        let target_node = SCNLookAtConstraint(target: base_human)
        target_node.isGimbalLockEnabled = true
        self.camera_node.constraints  = [target_node]
        
        
       // make it face the camera. 
        //base_human.eulerAngles = SCNVector3Make(0, Float.pi * 4.0/5, 0)
        
        // setup the scene view
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor.white
    
        interactor = SpeechAnimationCoodinator(model: base_human)
        
        // setup button at the bottom of scene
        let button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: self.view.frame.height - 40, width: self.view.frame.width , height:  40)
        button.backgroundColor = UIColor.red
        self.view.addSubview(button)
        if let interactor = interactor
        {
            button.addTarget(interactor, action: #selector(interactor.startInteraction), for: .touchDown)
        }
        
        
        
        
    }
   
 
    
    
    override var shouldAutorotate: Bool
    {
        return false
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
}

// Coniguration of Scene Kit
extension GameViewController
{
    func createAndConfigureScene() -> SCNScene?
    {
         // create a new scene
        let scene = SCNScene(named: "art.scnassets/base_human.dae")!
        
        // create and add a camera to the scene
        self.camera_node = SCNNode()
        self.camera_node.camera = SCNCamera()
        scene.rootNode.addChildNode(self.camera_node)
        
        // place the camera
        camera_node.position = SCNVector3(x: 0, y: 10, z: 25)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
       
        
        // Add a floor
        let floorGeo = SCNFloor()
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.green
        floorMaterial.specular.contents = UIColor.black
        floorGeo.firstMaterial = floorMaterial
        
        let floorNode = SCNNode(geometry:floorGeo )
        scene.rootNode.addChildNode(floorNode)
      
        return scene
        
    }
}

