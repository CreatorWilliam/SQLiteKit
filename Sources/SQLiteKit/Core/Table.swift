//
//  Table.swift
//  SQLiteKit
//
//  Created by William Lee on 2019/3/7.
//  Copyright © 2019 William Lee. All rights reserved.
//

import Foundation

public struct Table {
  
  public let name: String
  
  public private(set) var columns: [Column] = []
  
  public init(_ name: String) {
    
    self.name = name
  }
  
  public mutating func append(_ column: Column) {
    
    self.columns.append(column)
  }
  
}
