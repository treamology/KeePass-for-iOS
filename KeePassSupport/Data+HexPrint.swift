//
//  Data+HexPrint.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 9/28/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

extension Data {
  private static let hexAlphabet = "0123456789abcdef".unicodeScalars.map { $0 }
  
  public func hexEncodedString() -> String {
    return String(self.reduce(into: "".unicodeScalars, { (result, value) in
      result.append(Data.hexAlphabet[Int(value/16)])
      result.append(Data.hexAlphabet[Int(value%16)])
    }))
  }
}
