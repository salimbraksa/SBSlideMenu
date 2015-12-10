//
//  Protocols.swift
//  SBSlideMenu
//
//  Created by Salim Ive on 12/10/15.
//  Copyright © 2015 braksa. All rights reserved.
//

import UIKit

public protocol SBAnimator {
   
   func animatedSublayers() -> [CALayer]
   
   func describeAnimationsForLayer(layer: CALayer, reversed: Bool, automatic: Bool) -> [CAAnimationGroup]?
   
}

public protocol CategoryControl: class {
   
   var codename: String { get set }
   
   func didSelectCategory()
   func didDeselectCategory()
   
}

public protocol SBSlideMenuDelegate: class {
   func didSelectButtonOfIndex(index: Int)
}