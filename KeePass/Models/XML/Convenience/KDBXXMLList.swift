//
//  KDBXGroupList.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXXMLList<ElementType: KDBXXMLElement> {
  private var root: AEXMLElement
  
  public var elements: [ElementType] {
    get {
      return root.children
        .filter({$0.name == ElementType.elementName})
        .map({ElementType(withElement: $0)})
    }
  }
  
  subscript(index: Int) -> ElementType {
    get {
      return elements[index]
    }
  }
  
  public func addElement(element: ElementType) {
    root.addChild(element.xmlElement)
  }
  
  public func removeElement(byIndex index: Int) {
    let groupToRemove = elements[index].xmlElement
    for i in 0..<root.children.count {
      if groupToRemove == root.children[i] {
        groupToRemove.removeFromParent()
      }
    }
  }
  
  init(withRootElement root: AEXMLElement) {
    self.root = root
  }
}
