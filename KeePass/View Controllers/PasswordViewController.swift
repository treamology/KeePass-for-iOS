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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    updateTableViewContentInset()
  }
  
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
    return 20
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
  
  func updateTableViewContentInset() {
    let viewHeight: CGFloat = view.frame.size.height
    if let table = tableView {
      let tableViewContentHeight: CGFloat = table.contentSize.height
      let marginHeight: CGFloat = (viewHeight - tableViewContentHeight) / 2.0
      table.contentInset = UIEdgeInsets(top: marginHeight, left: 0, bottom:  -marginHeight, right: 0)
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
