//
//  SQL.swift
//  
//
//  Created by William Lee on 2019/10/30.
//

import Foundation

// MARK: - SQL
public class SQL {
  
  /// 保存最终要执行的SQL语句
  public private(set) var sentence: String = ""
  /// 查询SQL语句中结果字段列表
  internal private(set) var resultColumns: [Column] = []
  /// SQL语句中要绑定字段列表
  internal private(set) var bindColumns: [Column] = []
  
  private init() { }
  
}

// MARK: - Table
public extension SQL {
  
  convenience init(createTable name: String,
                   columns: [Column]) {
    self.init()
    
    sentence = "CREATE TABLE IF NOT EXISTS \(name)"
    sentence += "(\(columns.map({ $0.constraintDescription }).joined(separator: ", ")))"
    sentence += ";"
  }
  
  convenience init(dropTable name: String) {
    self.init()
    
    sentence = "DROP TABLE IF EXISTS \(name)"
    sentence += ";"
  }
  
}

// MARK: - Calculation
public extension SQL {
  
  convenience init(calculation: Calculation,
                   from table: String,
                   where condition: Condition? = nil) {
    
    self.init(calculation: calculation,
              from: [table],
              where: condition)
  }
  
  convenience init(calculation: Calculation,
                   from tables: [String],
                   where condition: Condition? = nil) {
    
    self.init()
    
    let isMultiTable = (tables.count > 1)
    
    let columnList = isMultiTable ? calculation.column.fullName : calculation.column.simpleName
    
    sentence = "SELECT \(columnList)"
    
    sentence = "SELECT \(calculation.function)(\(columnList))"
    
    /// 保存结果字段列表，后续用于执行赋值操作
    resultColumns = [calculation.column]
    
    sentence += " FROM \(tables.joined(separator: ", "))"
    
    
    if let condition = condition {
      
      sentence += " WHERE "
      sentence += condition.phrase(isSimple: isMultiTable == false)
      
      /// 保存字段列表，后续用于执行值绑定
      bindColumns.append(contentsOf: condition.columns)
    }
    
    sentence += ";"
  }
  
}

// MARK: - Select
public extension SQL {
  
  convenience init(select columns: [Column],
                   from table: String,
                   where condition: Condition? = nil,
                   sort sortedColumn: Column? = nil,
                   by sort: Sort? = nil) {
    
    self.init(select: columns,
              from: [table],
              where: condition,
              sort: sortedColumn,
              by: sort)
  }
  
  convenience init(select columns: [Column],
                   from tables: [String],
                   where condition: Condition? = nil,
                   sort sortedColumn: Column? = nil,
                   by sort: Sort? = nil) {
    self.init()
    
    let isMultiTable = (tables.count > 1)
    
    let columnList: String
    
    if columns.isEmpty == true {
      
      columnList = "*"
      
    } else {
      
      columnList = columns.map({ isMultiTable ? $0.fullName : $0.simpleName }).joined(separator: ", ")
    }
    
    sentence = "SELECT \(columnList)"
    
    /// 保存结果字段列表，后续用于执行赋值操作
    resultColumns = columns
    
    sentence += " FROM \(tables.joined(separator: ", "))"
    
    
    if let condition = condition {
      
      sentence += " WHERE "
      sentence += condition.phrase(isSimple: isMultiTable == false)
      
      /// 保存字段列表，后续用于执行值绑定
      bindColumns.append(contentsOf: condition.columns)
    }
    
    if let orderColumn = sortedColumn, let sort = sort {
      
      sentence += " ORDER BY \(isMultiTable ? orderColumn.fullName : orderColumn.simpleName) \(sort)"
    }
    
    sentence += ";"
  }
  
}

// MARK: - Insert
public extension SQL {
  
  convenience init(insert columns: [Column],
                   into tableNsme: String) {
    self.init()
    
    bindColumns.append(contentsOf: columns)
    
    sentence = "INSERT INTO \(tableNsme)"
    
    var columnList: [String] = []
    var valueList: [String] = []
    
    for column in columns {
      
      columnList.append(column.simpleName)
      valueList.append(column.bindPlaceholder)
    }
    sentence += " (\(columnList.joined(separator: ", ")))"
    sentence += " VALUES (\(valueList.joined(separator: ", ")))"
    
    sentence += ";"
  }
  
}

// MARK: - Delete
public extension SQL {
  
  convenience init(deleteFrom tableName: String,
                   where condition: Condition? = nil) {
    self.init()
    
    sentence = "DELETE FROM \(tableName)"
    
    if let condition = condition {
      
      sentence += " WHERE "
      sentence += condition.phrase(isSimple: true)
      bindColumns.append(contentsOf: condition.columns)
    }
    
    sentence += ";"
  }
  
}

// MARK: - Update
public extension SQL {
  
  convenience init(update columns: [Column],
                   in tableName: String,
                   where condition: Condition? = nil) {
    self.init()
    
    bindColumns.append(contentsOf: columns)
    
    sentence = "UPDATE \(tableName)"
    
    sentence += " SET "
    sentence += columns.map({ "\($0.simpleName) = \($0.bindPlaceholder)" }).joined(separator: ", ")
    
    if let condition = condition {
      
      sentence += " WHERE "
      sentence += condition.phrase(isSimple: true)
      bindColumns.append(contentsOf: condition.columns)
    }
    
    sentence += ";"
  }
}

// MARK: - Sort
public extension SQL {
  
  enum Sort: String, CustomStringConvertible, CustomDebugStringConvertible {
    /// 升序
    case ascend  = "ASC"
    /// 降序
    case descend = "DESC"
    
    public var description: String { return rawValue }
    
    public var debugDescription: String { return rawValue }
    
  }
  
}

// MARK: - CustomStringConvertible， CustomDebugStringConvertible
extension SQL: CustomStringConvertible, CustomDebugStringConvertible {
  
  public var description: String { return sentence }
  
  public var debugDescription: String { return sentence }
  
}
