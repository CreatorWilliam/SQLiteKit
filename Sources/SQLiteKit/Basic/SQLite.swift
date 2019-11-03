//
//  SQLite.swift
//  SQLiteKit
//
//  Created by William Lee on 14/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation
import SQLite3

public class SQLite {
  
  private let location: URL
  
  private var db: OpaquePointer? = nil
  private var statment: OpaquePointer? = nil//sqlite3_stmt
  private var state: State = .unknow {
    didSet {
      guard state == .error || state == .unknow else { return }
      #if DEBUG
      print(String(cString: sqlite3_errmsg(db), encoding: .utf8) ?? "error message is nil")
      #endif
    }
  }
  
  public init(at location: URL) {
    
    self.location = location
  }
  
}

// MARK: - SQLite Original Funcation
public extension SQLite {
  
  func open() {
    
    let code = sqlite3_open(location.absoluteString, &db)
    state = State(code)
  }
  
  func close() {
    
    let code = sqlite3_close(db)
    state = State(code)
    db = nil
  }
  
  func excute(_ sql: String) {
    
    let code = sqlite3_exec(db, sql.cString(using: .utf8), nil, nil, nil)
    state = State(code)
  }
  
  func prepare(_ sql: String) {
    
    let code = sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &statment, nil)
    state = State(code)
  }
  
  @discardableResult
  func step() -> State {
    
    let code = sqlite3_step(statment)
    state = State(code)
    return state
  }
  
  func reset() {
    
    let code = sqlite3_reset(statment)
    state = State(code)
  }
  
  func finalize() {
    
    let code = sqlite3_finalize(statment)
    state = State(code)
    statment = nil
  }
  
  func lastInsertRowID() -> Int {
    
    let id = sqlite3_last_insert_rowid(db)
    return Int(id)
  }
  
}

// MARK: - Bind
public extension SQLite {
  
  func bindClear() {
    
    let code = sqlite3_clear_bindings(statment)
    state = State(code)
  }
  
  func bindParameterCount() -> Int {
    
    return Int(sqlite3_bind_parameter_count(statment))
  }
  
  func bindParameterName(at index: Int) -> String? {
    
    guard let cString = sqlite3_bind_parameter_name(statment, Int32(index)) else { return nil }
    
    return String(cString: cString)
  }
  
  func bindParameterIndex(of name: String) -> Int? {
    
    let index = sqlite3_bind_parameter_index(statment, name)
    if index < 1 { return nil }
    return Int(index)
  }
  
  func bind(_ index: Int, with value: SQLIteDataCompatible?) {
    
    guard let statment = statment else { return }
    
    if let value = value {
      
      state = value.bind(sqlite: statment, at: index)
      
    } else {
      
      let code = sqlite3_bind_null(statment, Int32(index))
      state = State(code)
    }
    
  }
  
}

// MARK: - Column
public extension SQLite {
  
  func column<T: SQLIteDataCompatible>(at index: Int) -> T? {
    
    guard let statment = statment else { return nil }
    return T.init(sqlite: statment, at: index)
  }
  
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension SQLite.Location: CustomStringConvertible, CustomDebugStringConvertible {
  
  public var description: String {
    
    switch self {
    case .inMemory: return ":memory:"
    case .temporary: return ""
    case .uri(let URI): return URI
    }
  }
  
  public var debugDescription: String {
    
    switch self {
    case .inMemory: return ":memory:"
    case .temporary: return ""
    case .uri(let URI): return URI
    }
  }
}
