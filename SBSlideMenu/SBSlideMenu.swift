//
//  SBSlideMenu.swift
//  Shop
//
//  Created by Braksa Salim on 10/6/15.
//  Copyright © 2015 Braksa Salim. All rights reserved.
//

import UIKit
import Cartography

// MARK: - Main Class
public class SBSlideMenu: UIView {
   
   // MARK:  Properties
   weak public var delegate: SBSlideMenuDelegate!
   var animator: Animator!
   
   private var currentIndex: Int = 0 {
      didSet {
         
         // If currentIndex didn't change then let's just cancel
         if currentIndex == oldValue {
            return
         }
         
         // Save previous index
         previousIndex = oldValue
         
         // Set direction
         if oldValue < currentIndex {
            direction = .Forward
         } else if oldValue == currentIndex {
            direction = .Static
         } else {
            direction = .Backward
         }
         
      }
   }
   private var previousIndex: Int?
   private var direction: Direction?
   
   // Animation index
   private var animationFromIndex: Int!
   private var animationToIndex: Int!
   
   // - Configurable Params
   
   public var enableBlurEffect: Bool = false
   public var bgColor: UIColor = UIColor.whiteColor()
   public var spacing: CGFloat = 10
   public var animatedBarColor: UIColor = UIColor.blueColor()
   public var autoSpreadCategories: Bool = false
   public var spacerViewColor = UIColor.clearColor()
   
   // We're setting only leftMargin because it's equal to rightMargin anyways
   public var leftMargin: CGFloat = 20
   public var rightMargin: CGFloat = 20
   
   // - Subviews
   
   private var categories = [UIControl]()
   private var categoriesContainer: UIView!
   private var backgroundView: UIView!
   private var scrollView: UIScrollView!
   var animatedBar: UIView!
   
   // - Other
   
   private var animatedBarConstraints: ConstraintGroup!
   
   // MARK: Initialization
   
   public init(arrangedSubviews: [AnyObject]) {
      super.init(frame: CGRectZero)
      
      // Instantiate animator
      animator = Animator.sharedInstance
      animator.delegate = self
      
      // Set categories
      for (i, view) in arrangedSubviews.enumerate() {
         
         // Convert to control
         if let control = view as? UIControl {
            
            // Append control
            categories.append(control)
            
         } else {
            print("View of index \(i) is not of type UIControl")
         }
         
      }
      
   }
   
   func initializeTopBar() {
      
      // Initializing Subviews, and adding them
      
      // Background view, it's going to be opaque or transluent
      backgroundView = UIView()
      backgroundView.backgroundColor = UIColor.clearColor()
      if enableBlurEffect {
         
         // Add a blurView
         let blurEffect = UIBlurEffect(style: .ExtraLight)
         let blurView = UIVisualEffectView(effect: blurEffect)
         backgroundView.backgroundColor = UIColor.clearColor()
         backgroundView.addSubview(blurView)
         
         // Layout blurView
         constrain(blurView) { blurView in
            blurView.edges == blurView.superview!.edges
         }
         
      }
      
      addSubview(backgroundView)
      
      // A Scroll View, to scroll categories if there is a lot of them
      scrollView = UIScrollView()
      scrollView.showsHorizontalScrollIndicator = false
      backgroundView.addSubview(scrollView)
      
      // A container that is going to contain all the categories
      categoriesContainer = UIView()
      categoriesContainer.backgroundColor = UIColor.clearColor()
      scrollView.addSubview(categoriesContainer)
      
      // The categories themselves
      for (i, view) in categories.enumerate() {
         
         // Defer does the following:
         // Before leaving this function scope
         // Please execute this block
         defer {
            
            // Select only the first view
            // And Deselect the others
            let view = view as? CategoryControl
            if i == 0 {
               view?.didSelectCategory()
            } else {
               view?.didDeselectCategory()
            }
            
         }
         
         // Without this, shit happens
         categoriesContainer.autoresizesSubviews = false
         
         // Add target/control to view
         view.addTarget(self, action: "controlPressed:", forControlEvents: .TouchUpInside)
         
         // Disable user interaction
         view.subviews.first?.userInteractionEnabled = false
         
         // Add each view to superview
         categoriesContainer.addSubview(view)
         
      }
      
      // Add an animated bar
      animatedBar = UIView(frame: CGRect(x: leftMargin, y: 45, width: 45, height: 3))
      animatedBar.backgroundColor = animatedBarColor
      categoriesContainer.addSubview(animatedBar)
      constrain(animatedBar) { animatedBar in
         animatedBar.height == 3
         animatedBar.bottom == animatedBar.superview!.bottom
      }
      
      // Allocate animatedBarConstraints
      animatedBarConstraints = ConstraintGroup()
      
      // Constrain views
      constrainViews()
      
   }
   
   required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   // MARK: View Lifecycle
   
   override public func willMoveToSuperview(newSuperview: UIView?) {
      super.willMoveToSuperview(newSuperview)
      initializeTopBar()
   }
   
   // MARK: User Interaction
   
   func moveToIndex(index: Int, fromIndex: Int, automatic: Bool) {
      
      // Animate
      prepareAnimationFromIndex(currentIndex, toIndex: index, startAutomatically: automatic)
      
      // Set currentIndex
      currentIndex = index
      
   }
   
   func controlPressed(control: UIControl) {
      
      // Get the index of superview
      guard let index = categories.indexOf(control) else { return }
      
      // Do nothing if currentIndex == index
      if index == currentIndex { return }
      
      // Move
      moveToIndex(index, fromIndex: currentIndex, automatic: true)
      
      // Call the delegate
      delegate?.didSelectButtonOfIndex(index)
      
   }
   
   // MARK: Layouting & Constraining
   
   private func constrainViews() {
      
      // Constrain backgroundView
      constrain(backgroundView) { backgroundView in
         backgroundView.edges == backgroundView.superview!.edges
      }
      
      // Constrain scrollView
      constrain(scrollView) { scrollView in
         scrollView.edges == scrollView.superview!.edges
      }
      
      // Constrain animatedBar
      updateAnimatedBarConstraints()
      
      // Constrain categories
      
      // Iterate through each category
      for (index, category) in categories.enumerate() {
         
         // Get the previous category and spacerView
         let previousCategory: UIControl? = index != 0 ? categories[index-1] : nil
         let previousSpacerView: UIView? = index != 0 ? categoriesContainer.subviews.last : nil
         
         // Get category width that cames directly from the nib ( or maybe programmatically )
         let categoryWidth: CGFloat? = autoSpreadCategories == false ? category.bounds.width : nil
         
         // Common constraints for every category at any index
         constrain(category) { category in
            category.top == category.superview!.top
            category.bottom == category.superview!.bottom
         }
         
         // Adding a spacer view and constraining it at every index
         // Excepct the last one
         var spacerView: UIView!
         if index < categories.endIndex - 1 {
            
            // Create a spacer view
            spacerView = UIView()
            spacerView.backgroundColor = spacerViewColor
            categoriesContainer.addSubview(spacerView)
            
            // Common constraints for every spacerView at any index ( except the last one )
            constrain(category, spacerView) { category, spacerView in
               spacerView.top == spacerView.superview!.top
               spacerView.bottom == spacerView.superview!.bottom
               category.right == spacerView.left
               autoSpreadCategories == true ? ( spacerView.width == spacing ~ 500 ) : ( category.width == categoryWidth! ~ 500 )
            }
            
         }
         
         switch index {
            
            // Constrain the first category
         case 0:
            
            constrain(category) { category in
               category.left == category.superview!.left + leftMargin
            }
            
         case let i where i > 0 && i != categories.endIndex - 1:
            
            constrain(category, spacerView, previousCategory!, previousSpacerView!) { category, spacerView, previousCategory, previousSpacerView in
               autoSpreadCategories == true ? ( previousCategory.width == category.width ) : ( previousSpacerView.width == spacerView.width )
               previousSpacerView.right == category.left
            }
            
            // Constrain the last category
         case categories.endIndex - 1:
            
            constrain(category, previousCategory!, previousSpacerView!) { category, previousCategory, previousSpacerView in
               category.right == category.superview!.right - rightMargin ~ 500
               autoSpreadCategories == true ? ( previousCategory.width == category.width ) : ( category.width == categoryWidth! ~ 500 )
               previousSpacerView.right == category.left
            }
            
            // Constrain views in the middle
         default: break
            
         }
         
      }
      
   }
   
   override public func layoutSubviews() {
      super.layoutSubviews()
      
      // (Re)Calculate the container size manually
      recalculateContainerSize()
      
      // Cancel all ongoing animations
      cancelAnimations()
      
   }
   
   private func updateAnimatedBarConstraints() {
      
      // Constrain animatedBar
      let firstView = categories[currentIndex]
      constrain(animatedBar, firstView, replace: animatedBarConstraints) { animatedBar, firstView in
         animatedBar.left == firstView.left
         animatedBar.right == firstView.right
      }
      
   }
   
   private func setAnimatedBarConstraintsForIndex(index: Int) {
      
      let category = categories[index]
      constrain(animatedBar, category, replace: animatedBarConstraints) { animatedBar, category in
         animatedBar.left == category.left
         animatedBar.right == category.right
      }
      
   }
   
   // MARK: Helpers
   
   private func recalculateContainerSize() {
      
      // If the autoSpreadCategories is activated
      // No need to calculate the container width
      let containerWidth: CGFloat
      if autoSpreadCategories == true {
         containerWidth = bounds.width
      } else {
         let numberOfViews = categories.count
         let totalWidth = categories.reduce(0) { $0 + $1.bounds.width }
         let totalWidthWithSpacing = rightMargin + leftMargin + CGFloat(numberOfViews-1) * spacing + totalWidth
         containerWidth = autoSpreadCategories == true ? bounds.width : max(totalWidthWithSpacing, bounds.width)
      }
      
      scrollView?.contentSize = CGSize(width: containerWidth, height: bounds.height)
      scrollView?.alwaysBounceHorizontal = containerWidth > bounds.width
      scrollView?.contentOffset.x = contentOffsetForControl(categories[currentIndex]).x
      
      categoriesContainer?.frame.size = CGSize(width: containerWidth ?? 0, height: bounds.height)
      
   }
   
   private func contentOffsetForControl(control: UIControl) -> CGPoint {
      
      // Maximum offset x of the scrollView
      let offsetXMaxValue = categoriesContainer.bounds.width - bounds.width
      
      // The center of this view
      let bgCenterX = center.x
      
      // The center of the selected button's superview
      let viewCenterX = control.center.x
      
      // The distance between them
      let distance = viewCenterX - bgCenterX
      
      // Calculate the the new offset
      return CGPoint(x: max(0, min(offsetXMaxValue, distance)), y: scrollView.contentOffset.y)
      
   }
   
   private func isValidIndex(index: Int!) -> Bool {
      
      // False if it's nill
      if index == nil { return false }
      
      // Index shouldn't exceed or preceed categories first index and last index
      return index >= 0 && index < categories.endIndex
      
   }
   
}

// MARK: - Animation Section
extension SBSlideMenu: AnimatorDelegate {
   
   // MARK: Animation API
   
   public func prepareAnimationFromIndex(fromIndex: Int, toIndex: Int, startAutomatically automatic: Bool = false) {
      
      // The following two "if"s concern only categories
      // They handle some animation EDGE CASES
      // You may want to skip this step in order to understand
      // How these animations work
      //
      // 1. Understanding the first 'if' :
      //
      // - First of all it checks if the animationToIndex is a valid index
      // Check the isValidIndex: method below, it's not rocket science
      // N.B: animationToIndex here is not the actual toIndex param, animationToIndex
      //      Is the previous toIndex
      // - Imagine the following scenario :
      //
      // [ Category 1 ] - [ Category 2 ] - [ Category 3 ]
      //
      // Here, assume we have 3 categories, Okey ?
      // The first "if" solves the problem that occurs
      // When the user does the following
      // --> Starts at [ Category 1 ]
      // --> Moves to [ Category 2 ]
      // --> But before he stops transitionning to [ Category 2 ]
      //     He quickly moves to [ Category 3 ]
      // --> Again, before he stops transitionning to [ Category 3 ]
      //     He quickly moves back to [ Category 1 ] ( YES IT CAN HAPPENS )
      //
      // EXPECTATION:
      // [ Category 3 ]'s animations SHOULD be cancelled
      //
      // REALITY:
      // [ Category 3 ]'s animations ARE not cancelled
      
      if isValidIndex(animationToIndex) && fromIndex == animationFromIndex {
         let castedControl = categories[animationToIndex] as? SBAnimator
         let layers = castedControl?.animatedSublayers() ?? []
         for layer in layers {
            animator.cancelLayerAnimationForKeys(layer, forKeys: layer.explicitAnimationKeys())
         }
      }
      
      // 2. Understanding the second 'if':
      //
      // - Like the first 'if', we test if animationToIndex is a valid index
      // And the actual next index ( aka. toIndex param ) isn't
      // The previous animationFromIndex ( not the actual fromIndex param )
      // N.B: animationFromIndex here is not the actual fromIndex param, animationFromIndex
      //      Is the previous fromIndex
      // - Imagine the following scenario :
      //
      // [ Category 1 ] - [ Category 2 ] - [ Category 3 ]
      //
      // Here, assume we have 3 categories, Okey ?
      // The second "if" solves the problem that occurs
      // When the user does the following
      // --> Starts at [ Category 1 ]
      // --> Moves to [ Category 2 ]
      // --> But before he stops transitionning to [ Category 2 ]
      //     He quickly moves to [ Category 3 ]
      // --> The user stops at [ Category 3 ]
      //
      // EXPECTATION:
      // [ Category 1 ]'s animations SHOULD be finished ( not cancelled this time )
      //
      // REALITY:
      // [ Category 1 ]'s animations ARE not finished
      
      if isValidIndex(animationToIndex) && toIndex != animationFromIndex {
         let layers = (categories[animationFromIndex] as? SBAnimator)?.animatedSublayers() ?? []
         for layer in layers {
            animator.resumeLayer(layer, fromCurrentTimeOffset: true)
         }
      }
      
      // Remember these indexes
      animationFromIndex = fromIndex
      animationToIndex = toIndex
      
      // Verify destination index ( toIndex )
      // If toIndex isn't valid, then do not perform any animation
      if !isValidIndex(toIndex) { return }
      
      // Get the next control
      let nextControl = categories[toIndex]
      
      // The default duration depending if the animation
      // Should start automatically or manually
      let duration = automatic ? 0.25 : 0.90
      
      // Animating the animatedBar position, and width
      // By setting it's constraints
      setAnimatedBarConstraintsForIndex(toIndex)
      categoriesContainer.layoutIfNeeded()
      let posAnimation = CABasicAnimation(keyPath: "position.x")
      let point = animatedBar.center
      posAnimation.toValue = NSNumber(double: Double(point.x))
      let sizeAnimation = CABasicAnimation(keyPath: "bounds.size.width")
      let size = animatedBar.bounds.size
      sizeAnimation.toValue = NSNumber(double: Double(size.width))
      
      // Groupe animatedBar's animations
      let animatedBarAnimationGroup = CAAnimationGroup()
      animatedBarAnimationGroup.duration = duration
      animatedBarAnimationGroup.animations = [posAnimation, sizeAnimation]
      
      // Animate scrollView's contentOffset
      // ( but since the layer has no contentOffset property, I use bounds )
      let scrollAnimation = CABasicAnimation(keyPath: "bounds.origin.x")
      var bounds = scrollView.bounds
      bounds.origin.x = contentOffsetForControl(nextControl).x
      self.scrollView.bounds.origin.x = bounds.origin.x
      scrollAnimation.toValue = NSNumber(double: Double(bounds.origin.x))
      
      // Group scrollView's animations
      let scrollViewAnimationGroup = CAAnimationGroup()
      scrollViewAnimationGroup.fillMode = kCAFillModeBackwards
      scrollViewAnimationGroup.duration = duration
      scrollViewAnimationGroup.animations = [scrollAnimation]
      
      // Add animations
      animator.addAnimation(animatedBarAnimationGroup, toLayer: animatedBar.layer, forKey: "Bar Animation", startAutomatically: automatic)
      animator.addAnimation(scrollViewAnimationGroup, toLayer: scrollView.layer, forKey: "ScrollView Animation", startAutomatically: automatic)
      
      // Categories animations
      animateCategoryForIndex(toIndex, reversed: false, automatic: automatic)
      animateCategoryForIndex(fromIndex, reversed: true, automatic: automatic)
      
   }
   
   public func moveProgressively(progress: Double) {
      
      // Handling possible errors
      if animationToIndex >= categories.count || animationToIndex < 0 { return }
      
      // Animate Progessively
      animator.animateLayerProgressively(animatedBar.layer, progress: progress)
      animator.animateLayerProgressively(scrollView.layer, progress: progress)
      
      let nextControlLayers = (categories[animationToIndex] as? SBAnimator)?.animatedSublayers() ?? []
      let previousControlLayers = (categories[animationFromIndex] as? SBAnimator)?.animatedSublayers() ?? []
      
      for layer in nextControlLayers {
         animator.animateLayerProgressively(layer, progress: progress)
      }
      for layer in previousControlLayers {
         animator.animateLayerProgressively(layer, progress: progress)
      }
      
   }
   
   // MARK: Animator Delegate
   
   internal func animationDidStop(animation: CAAnimation, forLayer layer: CALayer, finished: Bool) {
      
      // Set animated bar constraints to the previous category if :
      // + The layer is the animatedBar layer
      // + The animation is not finished
      // + There is no ongoing animation with the same animation.name
      let shouldSetBarConstraints = layer == animatedBar.layer && !finished && !(layer.explicitAnimationKeys()?.contains(animation.name ?? "") ?? false)
      shouldSetBarConstraints ? setAnimatedBarConstraintsForIndex(animationFromIndex) : ()
      
      // Update currentIndex if the animation is finished
      finished ? ( currentIndex = animationToIndex ) : ()
      
   }
   
   // MARK: Internal Helpers
   
   private func cancelAnimations() {
      
      // Cancel ongoing animations
      animator.cancelLayerAnimationForKeys(animatedBar.layer, forKeys: animatedBar.layer.explicitAnimationKeys())
      animator.cancelLayerAnimationForKeys(scrollView.layer, forKeys: scrollView.layer.explicitAnimationKeys())
      
      if isValidIndex(animationFromIndex) {
         
         // Get destination control layers
         let layers = (categories[animationFromIndex] as? SBAnimator)?.animatedSublayers() ?? []
         let _ = layers.map {
            animator.cancelLayerAnimationForKeys($0, forKeys: $0.explicitAnimationKeys())
         }
         
      }
      
      if isValidIndex(animationToIndex) {
         
         // Get destination control layers
         let layers = (categories[animationToIndex] as? SBAnimator)?.animatedSublayers() ?? []
         let _ = layers.map {
            animator.cancelLayerAnimationForKeys($0, forKeys: $0.explicitAnimationKeys())
         }
         
      }
      
   }
   
   private func animateCategoryForIndex(index: Int, reversed: Bool, automatic: Bool) {
      
      guard let category = categories[index] as? SBAnimator else { return }
      
      // Animate Next Control
      let categoryLayers = category.animatedSublayers()
      for layer in categoryLayers {
         
         // Get animations
         guard let animations = category.describeAnimationsForLayer(layer, reversed: reversed, automatic: automatic) else { return }
         for (index, animation) in animations.enumerate() {
            
            // Make key
            let key = index == 0 ? "Animation" : "Animation-\(index)"
            
            // Add Animation
            animator.addAnimation(animation, toLayer: layer, forKey: key, startAutomatically: automatic)
            
         }
         
      }
      
   }
   
}