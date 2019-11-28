//
//  Calculation.swift
//  
//
//  Created by William Lee on 2019/11/28.
//

import Foundation

public struct Calculation {
  
  public private(set) var function: String
  
  public private(set) var column: Column
  
  // 求和
  public init(sum column: Column) {
    
    self.function = "SUM"
    self.column = column
  }
  
}

