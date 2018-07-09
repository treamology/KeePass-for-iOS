//
//  UITextView+MarginFix.swift
//  KeePass
//
//  Created by Donny Lawrence on 7/6/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class MarginlessTextView: UITextView {
  override func layoutSubviews() {
    super.layoutSubviews()
    textContainer.lineFragmentPadding = 0
  }
}
