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
    fileprivate var model : SCNNode! = nil
    fileprivate let wave_base_human_id = "base_human_waving"
    fileprivate let shrug_base_human_id = "base_human_shrug"
    
    fileprivate lazy var wave_base_human :CAAnimation? =
    {
        let model =  CAAnimation.animateWithSceneNamed(name:"art.scnassets/\(self.wave_base_human_id).dae" )!
        model.delegate = self
        model.repeatCount = 1
        return model
    }()
    
    fileprivate lazy var shrug_base_human :CAAnimation? =
    {
        let model =  CAAnimation.animateWithSceneNamed(name:"art.scnassets/\( self.shrug_base_human_id).dae" )!
        model.delegate = self
        model.repeatCount = 1
        return model
    }()

    // properties for speech recog
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate let speechRecognizer = SFSpeechRecognizer()
    fileprivate let speech_request_buffer = SFSpeechAudioBufferRecognitionRequest()
    fileprivate var speechRecogTask : SFSpeechRecognitionTask?
    
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
        print("start interacting")
        switch self.speech_setup_status
        {
            case .avaliable:
                self.getWordAndAct()
            case .recognizing:
                self.cancelRecord()
            case .unavaliable:
                print("Cannot init audio recognition engine")
        }
   
   }
    
   fileprivate func getWordAndAct()
   {
        self.convertSpeechToStr()
        {
            (word: String) in
    
                switch word.lowercased()
                {
                    case "hello",
                         "hi",
                         "how are you":
                        self.startWave()
                    default:
                        self.startShrug()
                }
                
                self.cancelRecord()
        }
   
   
    }
    
}

// Support for animations
extension SpeechAnimationCoodinator
{
    
    fileprivate func startWave()
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
    
    func convertSpeechToStr(completionHandeler : @escaping (_ input : String) -> Void)
    {
       // if no permission. return
       guard self.speech_setup_status == .avaliable else
       {
            return
       }
      
        guard let node = self.audioEngine.inputNode else
        {
           return
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
                print("Recogized Str : \(speech_str)")
                completionHandeler(speech_str)
            }
            else if let error = error
            {
               print(error)
            }

        })
    
        
    }
   
    func cancelRecord()
    {
        self.audioEngine.stop()
   
        if let node = audioEngine.inputNode
        {
            node.removeTap(onBus: 0)
        }
       
        self.speechRecogTask?.cancel()
        self.speech_setup_status = .avaliable
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
