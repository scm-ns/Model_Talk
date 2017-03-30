//
//  SpeechAnimationCoordinator.swift
//  Model_Talking
//
//  Created by Mattappali, Sandeep on 3/29/17.
//  Copyright © 2017 Mattappali, Sandeep. All rights reserved.
//

import Foundation
import UIKit
import Speech
import SceneKit

enum SpeechRecogStatus
{
   case avaliable
   case recognizing
   case unavaliable
}

class SpeechAnimationCoodinator : NSObject
{
    // properties for animation
    var model : SCNNode! = nil
    let wave_base_human_id = "base_human_waving"
    let shrug_base_human_id = "base_human_shrug"
    var wave_base_human :CAAnimation? = CAAnimation()
    var shrug_base_human :CAAnimation? = CAAnimation()

    // properties for speech recog
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let speech_request_buffer = SFSpeechAudioBufferRecognitionRequest()
    var speechRecogTask : SFSpeechRecognitionTask?
    
    var speech_setup_status = SpeechRecogStatus.unavaliable
    {
        didSet
        {
            // update ui element
        }
    }
   
    init(model : SCNNode)
    {
        super.init()
        self.model = model
        wave_base_human = CAAnimation.animateWithSceneNamed(name:"art.scnassets/\(wave_base_human_id).dae" )!
        wave_base_human?.delegate = self
        wave_base_human?.repeatCount = 1
        
        shrug_base_human =  CAAnimation.animateWithSceneNamed(name:"art.scnassets/\(shrug_base_human_id).dae" )!
        shrug_base_human?.delegate = self
        shrug_base_human?.repeatCount = 1
        
        switch SFSpeechRecognizer.authorizationStatus()
        {
            case .notDetermined:
                self.askSpeechPermission()
            case .authorized:
                self.speech_setup_status = .avaliable
            default :
                self.speech_setup_status = .unavaliable
        }
        
    }
    
   
}

// Build Interaction between Speech and Animation
extension SpeechAnimationCoodinator
{
    // Call after the scene has been shown and everything has been setup. That is after view did load
   func startInteraction()
   {
        let word = convertSpeechToStr()
    
        guard let word = word else
        {
            return
        }
   
    


    
   }
}

// Support for animations
extension SpeechAnimationCoodinator
{
    
    func startWave()
    {
        model.addAnimation(wave_base_human!, forKey: wave_base_human_id)
    }
   
    func stopWave()
    {
        model.removeAnimation(forKey: wave_base_human_id)
    }
   
    
    func startShrug()
    {
        model.addAnimation(shrug_base_human! , forKey: shrug_base_human_id)
    }
   
    func stopShrug()
    {
        model.removeAnimation(forKey: shrug_base_human_id)
    }
    
}


// Support for speech
extension SpeechAnimationCoodinator
{
    func askSpeechPermission()
    {
        SFSpeechRecognizer.requestAuthorization
        {
            ( status :SFSpeechRecognizerAuthorizationStatus) in
            
            OperationQueue.main.addOperation
            {
                switch status
                {
                    case .authorized:
                        self.speech_setup_status = .avaliable
                    default :
                        self.speech_setup_status = .unavaliable
                }
                
            }
        }
    }
    
    func convertSpeechToStr() -> String?
    {
       var result_str : String? = nil
       // if no permission. return
       guard self.speech_setup_status == .avaliable else
       {
            return nil
       }
      
        guard let node = self.audioEngine.inputNode else
        {
           return nil
        }
       
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
        {
            (buffer : AVAudioPCMBuffer, _ ) in
                self.speech_request_buffer.append(buffer)
        }
       
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            self.speech_setup_status = .recognizing
        }
        catch
        {
           print(error)
        }
        
        
        self.speechRecogTask = self.speechRecognizer?.recognitionTask(with: self.speech_request_buffer , resultHandler: 
        {
            (result : SFSpeechRecognitionResult? , error) in
         
            if let result = result
            {
                let speech_str = result.bestTranscription.formattedString
                result_str = speech_str
            }
            else if let error = error
            {
               print(error)
            }

        })
    
        return result_str
        
    }
   
    func cancelRecord()
    {
        self.audioEngine.stop()
   
        if let node = audioEngine.inputNode
        {
            node.removeTap(onBus: 0)
        }
       
        self.speechRecogTask?.cancel()
    }

    
    
}



extension SpeechAnimationCoodinator : CAAnimationDelegate
{
    func animationDidStart(_ anim: CAAnimation)
    {
        print("Animating : \(anim)")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("Animating Stop: \(anim)")
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
