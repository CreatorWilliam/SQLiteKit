//
//  File.swift
//  
//
//  Created by William Lee on 2019/10/31.
//

import Foundation

/// 用于组装SQL语句中的条件短语
public struct Condition {
  
  public private(set) var columns: [Column] = []
  
  private typealias Handle = (_ isSimple: Bool) -> String
  private var handles: [Handle] = []
  
  public init(isNull column: Column) {
    
    let hanlde: Handle = { (isSimple) in
      
      let name = isSimple ? column.simpleName : column.fullName
      return "\(name) IS NULL"
    }
    handles.append(hanlde)
  }
  
  public init(_ leftColumn: Column, equal rightColumn: Column) {
    
    let hanlde: Handle = { (isSimple) in
      
      let leftName = isSimple ? leftColumn.simpleName : leftColumn.fullName
      let rightName = isSimple ? rightColumn.simpleName : rightColumn.fullName
      return "\(leftName) = \(rightName)"
    }
    handles.append(hanlde)
  }
  
  public init(equal column: Column) {
    
    let hanlde: Handle = { (isSimple) in
      
      let name = isSimple ? column.simpleName : column.fullName
      return "\(name) = \(column.bindPlaceholder)"
    }
    handles.append(hanlde)
    columns.append(column)
  }
  
  public init(greaterThanEqual column: Column) {
    
    let hanlde: Handle = { (isSimple) in
      
      let name = isSimple ? column.simpleName : column.fullName
      return "\(name) >= \(column.bindPlaceholder)"
    }
    handles.append(hanlde)
    columns.append(column)
  }
  
  public init(lessThanEqual column: Column) {
    
    let hanlde: Handle = { (isSimple) in
      
      let name = isSimple ? column.simpleName : column.fullName
      return "\(name) <= \(column.bindPlaceholder)"
    }
    handles.append(hanlde)
    columns.append(column)
  }
  
  public init(like column: Column) {
    
    let hanlde: Handle = { (isSimple) in
      
      let name = isSimple ? column.simpleName : column.fullName
      return "\(name) like \(column.bindPlaceholder)"
    }
    handles.append(hanlde)
    columns.append(column)
  }
  
  public mutating func and(_ condition: Condition) {
    
    let hanlde: Handle = { (isSimple) in
      
      return "AND \(condition.phrase(isSimple: isSimple))"
    }
    handles.append(hanlde)
    columns.append(contentsOf: condition.columns)
  }
  
  public mutating func or(_ condition: Condition) {
    
    let hanlde: Handle = { (isSimple) in
      
      return "OR \(condition.phrase(isSimple: isSimple))"
    }
    handles.append(hanlde)
    columns.append(contentsOf: condition.columns)
  }
  
}

// MARK: - Utiltiy
extension Condition {
  
  func phrase(isSimple: Bool = true) -> String {
    
    return handles.map({ $0(isSimple) }).joined(separator: " ")
  }
}
