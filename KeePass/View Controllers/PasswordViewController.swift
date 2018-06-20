//
//  PasswordViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/16/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet var tableView: UITableView?
  var passwordCell: PasswordTableViewCell?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppeared), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappeared), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    // Do any additional setup after loading the view.
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    updateTableViewContentInset()
  }
  
  @objc func keyboardAppeared(notification: Notification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      updateTableViewContentInset(animated: true, offset: 0)
    }
  }
  
  @objc func keyboardDisappeared(notification: Notification) {
    updateTableViewContentInset(animated: true)
  }
  
  // MARK: - User Actions
  
  @IBAction func unlockButtonPressed() {
    guard let parentController = parent as? DetailViewController else {
      return
    }
    parentController.document = KDBXDocument(fileURL: parentController.resolvedURL)
    guard let document = parentController.document else {
      return
    }
    
    document.password = passwordCell!.textField!.text!
    
    document.open(completionHandler: { (success) in
      if success {
        print(document.parsedData?.xml)
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
      // This will never happen.
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
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
