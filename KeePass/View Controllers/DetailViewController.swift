//
//  DetailViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit
import KeePassSupport

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  static let STORYBOARD_FILE = "Main"
  
  var navigationParent: UINavigationController!
  
  @IBOutlet var tableView: UITableView!
  var passwordCell: PasswordTableViewCell?
  
  var resolvedURL: URL!
  var document: KDBXDocument?
  var database: KDBXDatabase?
  
  deinit {
    print("deinit")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppeared), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappeared), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    navigationParent = self.parent as? UINavigationController
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    updateTableViewContentInset()
  }
  
  func configureView() {
    // Update the user interface for the detail item.
    if let detail = detailItem {
      if isViewLoaded {
        tableView.isHidden = false
      }
      
      guard let resolvedURL = FileManagement.resolveBookmark(bookmark: detail, persistenceIndex: nil) else {
        print("Couldn't resolve the bookmark.")
        return
      }
      self.resolvedURL = resolvedURL
      var titleText = String(resolvedURL.lastPathComponent)
      titleText.removeLast(5) // .kdbx
      self.navigationItem.title = titleText
      
      // You can't hide and show bar button items so we'll have to do this hack.
      self.navigationItem.leftBarButtonItem?.isEnabled = true
      self.navigationItem.leftBarButtonItem?.tintColor = nil
    } else {
      tableView.isHidden = true
      
      self.navigationItem.title = ""
      self.navigationItem.leftBarButtonItem?.isEnabled = false
      self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
    }
  }
  
  var detailItem: Data? {
    didSet {
      // Update the view.
      configureView()
    }
  }
  
  // MARK: - User Actions
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "UnlockSegue" {
      // This means we're unlocking the database, so give the new view controller the information
      // it needs.
      let destination = segue.destination as! DatabaseViewController
      destination.document = document
      destination.database = database
    }
  }
  
  @IBAction func unlockButtonPressed() {
    document = KDBXDocument(fileURL: resolvedURL)
    guard let document = document else {
      return
    }
    
    document.password = passwordCell!.textField!.text!
    
    document.open(completionHandler: { (success) in
      if success {
        self.database = KDBXDatabase(withXML: document.parsedData!)
        self.performSegue(withIdentifier: "UnlockSegue", sender: self)
      } else {
        let alert = UIAlertController(title: "Failed to open the database.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    })
  }
  
  // MARK: - Table View
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 || section == 1{
      return 2
    }
    return 0
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 32
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Password"
    } else if section == 1 {
      return "Keyfile"
    }
    return ""
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell!
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath)
        passwordCell = cell as? PasswordTableViewCell
      } else if indexPath.row == 1 {
        cell = tableView.dequeueReusableCell(withIdentifier: "AndOrCell", for: indexPath)
      }
    } else if indexPath.section == 1 {
      if indexPath.row == 0 {
        cell = tableView.dequeueReusableCell(withIdentifier: "FileChooserCell", for: indexPath)
      } else if indexPath.row == 1 {
        cell = tableView.dequeueReusableCell(withIdentifier: "UnlockCell", for: indexPath)
      }
    } else {
      // This will never happen (unless I screw something up).
      cell = UITableViewCell()
    }
    return cell
  }
  
  func updateTableViewContentInset(animated: Bool = false, offset: CGFloat? = nil) {
    let viewHeight: CGFloat = view.frame.size.height
    if let table = tableView {
      let tableViewContentHeight: CGFloat = table.contentSize.height
      let marginHeight: CGFloat = (viewHeight - tableViewContentHeight) / 2.0
      var theOffset: CGFloat! = offset
      if offset == nil {
        theOffset = marginHeight
      }
      let edgeInsets = UIEdgeInsets(top: theOffset, left: 0, bottom: -theOffset, right: 0)
      if animated {
        UIView.animate(withDuration: 0.5, animations: {
          table.contentInset = edgeInsets
        })
      } else {
        table.contentInset = edgeInsets
      }
    }
  }
  
  func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//    let storyboard = UIStoryboard(name: EntryDetailsViewController.STORYBOARD_FILE, bundle: Bundle.main)
//    let detailsVC = storyboard.instantiateViewController(withIdentifier: "EntryDetailsViewController")
//    present(detailsVC, animated: true, completion: nil)
  }
  
  // MARK: - Keyboard Notifications
  @objc func keyboardAppeared(notification: Notification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let distToTop = tableView!.contentInset.top
      let offset = min(keyboardSize.height, distToTop)
      updateTableViewContentInset(animated: true, offset: distToTop - offset)
    }
  }
  
  @objc func keyboardDisappeared(notification: Notification) {
    updateTableViewContentInset(animated: true)
  }
}

