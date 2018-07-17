//
//  KDBXXMLDict.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXXMLDict<ElementType: KDBXXMLElement>: KDBXXMLList<ElementType> {
  private var indexCache: [String: Int]?
  
  subscript(key: String) -> String? {
    get {
      if let cache = indexCache {
        if let key = cache[key] {
          return elements[key].xmlElement["Value"].value
        }
      } else {
        indexCache = [:]
      }
      
      for i in 0..<elements.count {
        let element = elements[i]
        if let iterKey = element.xmlElement["Key"].value {
          indexCache![iterKey] = i
          if key == iterKey {
            return element.xmlElement["Value"].value
          }
        }
      }
      
      return nil
    }
    set {
      indexCache = nil
      for element in elements {
        if key == element.xmlElement["Key"].value {
          element.xmlElement["Value"].value = newValue
        }
      }
    }
  }
}
