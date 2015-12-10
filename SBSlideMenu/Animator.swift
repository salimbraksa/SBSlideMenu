//
//  Animator.swift
//  AnimationTest
//
//  Created by Salim Ive on 11/26/15.
//  Copyright © 2015 braksa. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol AnimatorDelegate: class {
   
   func animationDidStop(animation: CAAnimation, forLayer layer: CALayer, finished: Bool)
   
}

// MARK: - Class

class Animator: NSObject {
   
   // MARK: Properties
   
   weak var delegate: AnimatorDelegate?
   
   // Singleton
   class var sharedInstance: Animator {
      struct AnimatorWrapper {
         static let singleton = Animator()
      }
      return AnimatorWrapper.singleton
   }
   
   // MARK: Initialize
   
   private override init() {
      
   }
   
   // MARK: API
   
   func addAnimation(animation: CAAnimationGroup, toLayer layer: CALayer, forKey key: String?, startAutomatically automatic: Bool) {
   
      // Additional Setups bere adding the animation
      
      // Set the animation delegate
      animation.delegate = layer
      
      // Set animation fillMode
      animation.fillMode = kCAFillModeBackwards
      
      // Iterate through each CABasicAnimation and update it's fromValue
      for animation in animation.basicAnimations ?? [] {
         let fromValue = (layer.presentationLayer() as? CALayer)?.valueForKeyPath(animation.keyPath ?? "")
         animation.fromValue = fromValue
      }
      
      // Separate all animation keys from just explicit keys
      // And give the animation a name
      layer.addExplicitAnimationKey(key)
      animation.name = key
      
      // Set maximum of animations duration
      layer.maxOfAnimationsDurations = max(layer.maxOfAnimationsDurations, animation.valueForKey("duration") as? Double ?? -1)
      
      // Add animation to layer
      layer.addAnimation(animation, forKey: key)
      
      // Pause / Resume Layer
      automatic ? resumeLayer(layer) : pauseLayer(layer)
      
   }
   
   func animateLayerProgressively(layer: CALayer, progress: Double) {
      
      // Get layer animations
      let duration: Double = layer.maxOfAnimationsDurations
      
      // Animate the layer progressively
      layer.timeOffset = progress * duration
      
      if progress == 1.0 {
            resumeLayer(layer)
      } else if progress == 0.0 {
         guard let animationKeys = layer.explicitAnimationKeys() else { return }
         for key in animationKeys {
            cancelLayerAnimationForKey(layer, forKey: key)
         }
      }
      
      
   }
   
   // MARK: Animation Delegate
   
   func layerAnimationDidStop(layer: CALayer, animation: CAAnimation, finished: Bool) {
      layer.timeOffset = 0
      delegate?.animationDidStop(animation, forLayer: layer, finished: finished)
   }
   
   // MARK: Internal Helpers
   
   func cancelLayerAnimationForKey(layer: CALayer, forKey key: String) {
      
      // Get the animation
      guard let animation = layer.animationForKey(key) else { return }
      
      // Set layer from value
      if layer.animationForKey(key)!.isKindOfClass(CABasicAnimation) {
         
         let basicAnimation = animation as! CABasicAnimation
         setLayerValueFromBasicAnimation(layer, value: basicAnimation.fromValue, basicAnimation: basicAnimation)
         
      } else if layer.animationForKey(key)!.isKindOfClass(CAAnimationGroup) {
         setLayerValueFromAnimationGroup(layer, animationGroup: animation as! CAAnimationGroup)
      }
      
      // Resume layer
      resumeLayer(layer)
      
      // Remove that animation
      layer.removeAnimationForKey(key)
            
   }
   
   func cancelLayerAnimationForKeys(layer: CALayer, forKeys keys: [String]?) {
      
      // Do nothings if keys is nil
      guard let keys = keys else { return }
      
      // Iterate through each key
      for key in keys {
         cancelLayerAnimationForKey(layer, forKey: key)
      }
      
   }
   
   private func setLayerValueFromBasicAnimation(layer: CALayer, value: AnyObject?, basicAnimation: CABasicAnimation) {
      layer.setValue(basicAnimation.fromValue, forKeyPath: basicAnimation.keyPath ?? "")
   }
   
   private func setLayerValueFromAnimationGroup(layer: CALayer, animationGroup: CAAnimationGroup) {
      for animation in animationGroup.basicAnimations ?? [] {
         setLayerValueFromBasicAnimation(layer, value: animation.fromValue, basicAnimation: animation)
      }
   }
   
   private func pauseLayer(layer: CALayer) {
      layer.speed = 0
      layer.timeOffset = 0.0
   }
   
   func resumeLayer(layer: CALayer, fromCurrentTimeOffset useCurrentTimeOffset: Bool = false) {
      layer.speed = 1.0
      !useCurrentTimeOffset ? layer.timeOffset = 0.0 : ()
      layer.beginTime = 0
   }
   
}