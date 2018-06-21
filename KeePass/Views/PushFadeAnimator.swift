//
//  PushFadeAnimator.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import UIKit

class PushFadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let toVC = transitionContext.viewController(forKey: .to)!
    transitionContext.containerView.addSubview(toVC.view)
    toVC.view.alpha = 0
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      toVC.view.alpha = 1
    }) { (finished) in
      transitionContext.completeTransition(finished)
    }
  }
}
