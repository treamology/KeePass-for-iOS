//
//  DetailViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet var passwordContainerView: UIView?
  @IBOutlet var databaseContainerView: UIView?
  
  var resolvedURL: URL!
  var document: KDBXDocument?
  
  func configureView() {
    // Update the user interface for the detail item.
    if let detail = detailItem {
      self.databaseContainerView?.isHidden = true
      self.passwordContainerView?.isHidden = false
      
      guard let resolvedURL = FileManagement.resolveBookmark(bookmark: detail, persistenceIndex: nil) else {
        print("Couldn't resolve the bookmark.")
        return
      }
      self.resolvedURL = resolvedURL
      var titleText = String(resolvedURL.lastPathComponent)
      titleText.removeLast(5) // .kdbx
      self.navigationItem.title = titleText
      
      // You can't hide bar button items so we'll have to do this hack.
      self.navigationItem.leftBarButtonItem?.isEnabled = true
      self.navigationItem.leftBarButtonItem?.tintColor = nil
    } else {
      self.databaseContainerView?.isHidden = true
      self.passwordContainerView?.isHidden = true
      
      self.navigationItem.title = ""
      self.navigationItem.leftBarButtonItem?.isEnabled = false
      self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
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

