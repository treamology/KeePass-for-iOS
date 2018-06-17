//
//  MasterViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
  
  @IBOutlet var bookmarkTableView: UITableView?
  var detailViewController: DetailViewController? = nil
  
  var filePickerController: UIDocumentPickerViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // If we get an update from the cloud, reload the table to the latest items.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(cloudDataChanged(notification:)),
                                           name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                           object: NSUbiquitousKeyValueStore.default)
    
    if let split = splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController)
        .topViewController as? DetailViewController
    }
    
    // Turning this on from within IB doesn't work for some reason
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationItem.largeTitleDisplayMode = .always
    
    // Go ahead and load the file picker controller.
    filePickerController = UIDocumentPickerViewController(documentTypes:["org.keepassx.kdbx"],
                                                          in: .open)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  
  // MARK: - User Actions
  
  @IBAction
  func addButtonPressed(_ sender: Any) {
    // Ask the user what to do, open an existing database or open a new one.
    let alert = UIAlertController(title: nil,
                                  message: nil,
                                  preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Add Existing...",
                                  style: .default,
                                  handler: { (_) in self.importDatabaseFromBrowser() }))
    alert.addAction(UIAlertAction(title: "Create New...",
                                  style: .default,
                                  handler: { (_) in self.askForDatabaseName() } ))
    alert.addAction(UIAlertAction(title: "Cancel",
                                  style: .cancel,
                                  handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func askForDatabaseName() {
    let alert = UIAlertController(title: "New Database",
                                  message: "Give your database a name:",
                                  preferredStyle: .alert)
    alert.addTextField(configurationHandler: nil)
    alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction) in
    let name = alert.textFields![0].text!
    if name == "" {
        let failedAlert = UIAlertController(title: "The database name cannot be blank.",
                                            message: nil,
                                            preferredStyle: .alert)
        failedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(failedAlert, animated: true, completion: nil)
        return
      }
      
      FileManagement.createNewDatabase(name: name, completed: {(success: Bool) in
        if success {
          self.bookmarkTableView?.reloadData()
        }
      })
      return
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func importDatabaseFromBrowser() {
    present(filePickerController, animated: true, completion: nil)
  }
  
  // MARK: - Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = Persistence.bookmarkedFiles[indexPath.row]
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  // MARK: - Table View
  @objc func cloudDataChanged(notification: NSNotification) {
    bookmarkTableView?.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Persistence.bookmarkedFiles.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let fileBookmark = Persistence.bookmarkedFiles[indexPath.row]
    let fileURL = FileManagement.resolveBookmark(bookmark: fileBookmark, persistenceIndex: indexPath.row)
    if fileURL != nil {
      var titleText = String(fileURL!.lastPathComponent)
      titleText.removeLast(5)
      cell.textLabel!.text = titleText
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Bookmarked Files"
    }
    return ""
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      Persistence.removeFileBookmark(index: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}

