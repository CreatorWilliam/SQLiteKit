//
//  Column.swift
//  SQLiteKit
//
//  Created by William Lee on 2019/3/7.
//  Copyright © 2019 William Lee. All rights reserved.
//

import Foundation

public struct Column {
  
  public enum DataType: String {
    
    /// 整形
    case int = "INTEGER"
    /// 双精度浮点
    case double = "REAL"
    /// 字符串
    case text = "TEXT"
    /// 布尔
    case bool = "INT2"
    /// 二进制数据
    case blob = "BLOB"
  }
  
  /// 字段名称
  public let name: String
  /// 字段存储的数据类型
  public let dataType: DataType
  
  public init(name: String, dataType: DataType) {
    
    self.name = name
    self.dataType = dataType
  }
  
}
