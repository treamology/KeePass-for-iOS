//
//  MasterViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
  
  var detailViewController: DetailViewController? = nil
  var objects = [Any]()
  
  var filePickerController: UIDocumentPickerViewController!
  
  var filesManager = FileManager.default
  var signedIntoCloud = false
  var documentsURL: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let split = splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController)
        .topViewController as? DetailViewController
    }
    
    // Turning this on from within IB doesn't work for some reason
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationItem.largeTitleDisplayMode = .always
    
    // Choose the location to store new databases depending on if the user is signed into iCloud
    // or not.
    if filesManager.ubiquityIdentityToken != nil {
      print("Signed into iCloud")
      signedIntoCloud = true
      DispatchQueue.global(qos: .background).async {
        print("Getting the documents folder URL...")
        // Passing nil gives the first one in the list
        self.documentsURL = self.filesManager.url(forUbiquityContainerIdentifier: nil)
        
        // So for some reason you need to make a Documents directory within your
        // app's iCloud folder. It doesn't actually show in the UI, but you need
        // it in order for the files you save to actually show up.
        self.documentsURL = self.documentsURL?.appendingPathComponent("Documents", isDirectory: true)
        do {
          try self.filesManager.createDirectory(at: self.documentsURL!,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        } catch {
          print("Couldn't create the documents directory")
          self.signedIntoCloud = false
        }
      }
    } else {
      print("Not signed into iCloud")
      let urls = self.filesManager.urls(for: .documentDirectory, in: .userDomainMask)
      print(urls)
      // FIXME: Is it always the first one of these?
      documentsURL = urls[0]
    }
    
    // Go ahead and load the file picker controller.
    filePickerController = UIDocumentPickerViewController(documentTypes:["org.keepassx.kdbx"],
                                                          in: .open)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  
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
      
      self.createNewDatabase(name: name)
      return
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func importDatabaseFromBrowser() {
    present(filePickerController, animated: true, completion: nil)
  }
  
  func createNewDatabase(name: String) {
    let success = filesManager.createFile(atPath: (documentsURL?.appendingPathComponent("\(name).kdbx",
      isDirectory: false).path)!,
                                          contents: Data(),
                                          attributes: nil)
    print(success)
  }
  
  // MARK: - Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let object = objects[indexPath.row] as! NSDate
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = object
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  // MARK: - Table View
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return objects.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let object = objects[indexPath.row] as! NSDate
    cell.textLabel!.text = object.description
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      objects.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }
  
  
}

