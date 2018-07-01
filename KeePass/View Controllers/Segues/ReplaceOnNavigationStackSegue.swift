//
//  ReplaceOnNavigationStackSegue.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/30/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class ReplaceOnNavigationStackSegue: UIStoryboardSegue {
  override func perform() {
    // Swap out view controllers
    let navigationParent = source.parent as! UINavigationController
    
    var viewControllers = navigationParent.viewControllers
    viewControllers[viewControllers.count - 1] = destination
    navigationParent.setViewControllers(viewControllers, animated: false)
  }
}
