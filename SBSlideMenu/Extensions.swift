//
//  Extensions.swift
//  Shop
//
//  Created by Salim Ive on 12/10/15.
//  Copyright © 2015 Braksa. All rights reserved.
//

import UIKit

extension CAAnimationGroup {
   
   var basicAnimations: [CABasicAnimation]? {
      return convertToBasicAnimation()
   }
   
   private func convertToBasicAnimation() -> [CABasicAnimation]? {
      
      // Unwrap animations
      guard let animations = self.animations else { return nil }
      
      // The array that will hold basic animation
      var basicAnimations = [CABasicAnimation]()
      
      // Loop through each animation
      for animation in animations {
         
         // If animation is a basic animation
         if animation.isKindOfClass(CABasicAnimation) {
            basicAnimations.append(animation as! CABasicAnimation)
         } else if animation.isKindOfClass(CAAnimationGroup) {
            basicAnimations.appendContentsOf((animation as! CAAnimationGroup).convertToBasicAnimation() ?? [])
         }
         
      }
      
      return basicAnimations
      
   }
   
}

extension CAAnimation {
   
   var name: String? {
      get {
         return valueForKey("Animation Name") as? String
      } set {
         setValue(newValue, forKey: "Animation Name")
      }
   }
   
}

extension CALayer {
   
   var maxOfAnimationsDurations: Double {
      get {
         return valueForKey("Maximum Of Animations Duration") as? Double ?? -1
      } set {
         setValue(newValue, forKey: "Maximum Of Animations Duration")
      }
   }
   
   func explicitAnimationKeys() -> [String]? {
      let keys = valueForKey("Explicit Animation Keys") as? [String]
      return keys
   }
   
   func addExplicitAnimationKey(key: String?) {
      guard let key = key else { return }
      var keys = explicitAnimationKeys() ?? []
      keys.append(key)
      setValue(keys, forKey: "Explicit Animation Keys")
   }
   
   func removeExplicitAnimationKey(key: String?) {
      guard let key = key else { return }
      var keys = explicitAnimationKeys() ?? []
      guard let index = keys.indexOf(key) else { return }
      keys.removeAtIndex(index)
      setValue(keys, forKey: "Explicit Animation Keys")
   }
   
   public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
      
      // Remove animation name for keys
      removeExplicitAnimationKey(anim.name)
      
      // Recalculate the maximum of the animations durations
      let allAnimations = animationKeys()?.map { animationForKey($0)! }
      let durations = allAnimations?.map { $0.valueForKey("duration") as? Double ?? -1 }
      maxOfAnimationsDurations = durations?.maxElement() ?? -1
      
      // Report to the delegate that this layer's animation is stopped
      Animator.sharedInstance.layerAnimationDidStop(self, animation: anim, finished: flag)
      
   }
   
}