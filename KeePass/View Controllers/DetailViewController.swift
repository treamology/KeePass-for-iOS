//
//  DetailViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  func configureView() {
    // Update the user interface for the detail item.
    if let detail = detailItem {
      let resolvedURL = FileManagement.resolveBookmark(bookmark: detail, persistenceIndex: nil)
      if resolvedURL != nil {
        var titleText = String(resolvedURL!.lastPathComponent)
        titleText.removeLast(5) // .kdbx
        self.navigationItem.title = titleText
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
  }
  
  var detailItem: Data? {
    didSet {
      // Update the view.
      configureView()
    }
  }
  
  
}

