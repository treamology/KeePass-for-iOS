//
//  PasswordTableViewCell.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/17/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class PasswordTableViewCell: UITableViewCell {
  
  @IBOutlet var textField: UITextField?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
