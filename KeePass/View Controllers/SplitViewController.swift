//
//  SplitViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/18/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.delegate = self
    self.preferredDisplayMode = .allVisible
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
