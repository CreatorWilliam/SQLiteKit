//
//  Column.swift
//  SQLiteKit
//
//  Created by William Lee on 2019/3/7.
//  Copyright © 2019 William Lee. All rights reserved.
//

import Foundation

/// 用于描述一个表中的一列
public struct Column {
  
  /// 字段存储的数据类型
  public let dataType: DataType
  /// 字段保存的数据
  public var data: SQLIteDataCompatible?
  /// 赋值操作
  public var assignmentHandle: ((SQLIteDataCompatible?) -> Void)?
  /// 字段所在的表名
  private let tableName: String
  /// 字段名称
  private let name: String
  /// 字段的约束
  private let constraints: [Constraint]
  
  /// 创建Table时使用
  public init(name: String,
              constraints: [Constraint] = [],
              dataType: DataType,
              in tableName: String) {
    
    self.tableName = tableName
    self.name = name
    self.constraints = constraints
    if constraints.contains(.autoIncrement) { self.dataType = .integer }
    else { self.dataType = dataType }
  }
  
}

// MARK: - Name and Description
public extension Column {
  
  /// 字段描述，创建Table时使用
  var constraintDescription: String {
    
    var names: [String] = []
    names.append(name)
    names.append("\(dataType)")
    names.append(contentsOf: constraints.map({ "\($0)" }))
    
    return names.joined(separator: " ")
  }
  
  /// 相对名称
  var simpleName: String { return name }
  /// 绝对名称
  var fullName: String { return "\(tableName).\(name)"}
  
  /// 用于绑定的占位符，共有5种类型     :VVV    @VVV    $VVV   ?   ?NNN
  var bindPlaceholder: String { return "?" }
  
}

// MARK: - Handle
public extension Column {
  
  /// 追加数据
  func appending(_ data: SQLIteDataCompatible?) -> Column {
    
    var column = self
    column.data = data
    return column
  }
  
  func appending(_ assignmentHandle: @escaping (SQLIteDataCompatible?) -> Void) -> Column {
    
    var column = self
    column.assignmentHandle = assignmentHandle
    return column
  }
}

// MARK: - Constraint
public extension Column {
  
  /// 字段约束
  enum Constraint: String, CustomStringConvertible, CustomDebugStringConvertible {
    
    ///字段值自动增加, 只能用于整型
    case autoIncrement = "AUTOINCREMENT"
    /// 确保某列不能有 NULL 值
    case notNull = "NOT NULL"
    /// 当某列没有指定值时，为该列提供默认值
    case `default` = "DEFAULT"
    /// 确保某列中的所有值是不同的
    case unique = "UNIQUE"
    /// 唯一标识数据库表中的各行/记录
    case primaryKey = "PRIMARY KEY"
    /// 确保某列中的所有值满足一定条件
    case check = "CHECK"
    
    public var description: String { return rawValue }
    
    public var debugDescription: String { return rawValue }
  }
  
}

// MARK: - DataType
public extension Column {
  
  enum DataType: String, CustomStringConvertible, CustomDebugStringConvertible {
    
    /// 整形
    case integer = "INTEGER"
    /// 双精度浮点
    case double = "REAL"
    /// 字符串
    case text = "TEXT"
    /// 布尔
    case bool = "INT2"
    /// 二进制数据
    case binary = "BLOB"
    
    public var description: String { return rawValue }
    
    public var debugDescription: String { return rawValue }
  }
  
}
