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

    var base_human = SCNNode()
    let wave_base_human_id = "base_human_waving"
    let shrug_base_human_id = "base_human_shrug"
    var wave_base_human :CAAnimation? = CAAnimation()
    var shrug_base_human :CAAnimation? = CAAnimation()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/base_human.dae")!
        wave_base_human = CAAnimation.animateWithSceneNamed(name:"art.scnassets/\(wave_base_human_id).dae" )!
        wave_base_human?.delegate = self
        wave_base_human?.repeatCount = 1
        
        shrug_base_human =  CAAnimation.animateWithSceneNamed(name:"art.scnassets/\(shrug_base_human_id).dae" )!
        shrug_base_human?.delegate = self
        shrug_base_human?.repeatCount = 1
        
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 25)
        
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
        
        
        // retrieve the ship node
        base_human = scene.rootNode.childNode(withName: "base_human_armtr", recursively: true)!
      
       // make it face the camera. 
        base_human.eulerAngles = SCNVector3Make(0, Float.pi * 4.0/5, 0)
        
        self.startWave()
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        
        scnView.backgroundColor = UIColor.white
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
   
    func startWave()
    {
        
        base_human.addAnimation(wave_base_human!, forKey: wave_base_human_id)
    //    base_human.removeAnimation(forKey: wave_base_human_id)
    }
   
    func stopWave()
    {
        base_human.removeAnimation(forKey: wave_base_human_id)
    }
   
    
    func startShrug()
    {
        base_human.addAnimation(shrug_base_human! , forKey: shrug_base_human_id)
    }
   
    func stopShrug()
    {
        base_human.removeAnimation(forKey: shrug_base_human_id)
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Release any cached data, images, etc that aren't in use.
    }

}

extension CAAnimation
{
    class func animateWithSceneNamed(name : String) -> CAAnimation?
    {
        var anim : CAAnimation?
        if let scene = SCNScene(named:  name)
        {
           scene.rootNode.enumerateChildNodes({ (child, stop) in
                if child.animationKeys.count > 0
                {
                        anim = child.animation(forKey:child.animationKeys.first! )
                        stop.initialize(to: true)
                }
           })
        }
        return anim
    }
}


extension GameViewController : CAAnimationDelegate
{
    func animationDidStart(_ anim: CAAnimation)
    {
        print("Animating : \(anim)")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("Animating Stop: \(anim)")
    }
}

