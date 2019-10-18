//
//  SQLitable.swift
//  SQLiteKit
//
//  Created by William Lee on 14/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public protocol SQLitable {
  
  var id: Int { get }
  
  var table: Table { get }
    
  func value(for column: Column) -> Any?
  
}

