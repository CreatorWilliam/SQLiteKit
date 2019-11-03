//
//  SQLIteDataCompatible.swift
//  
//
//  Created by William Lee on 2019/10/31.
//

import Foundation
import SQLite3

public protocol SQLIteDataCompatible {
  
  init?(sqlite statment: OpaquePointer, at index: Int)
  
  func bind(sqlite statment: OpaquePointer, at index: Int) -> SQLite.State
  
}

// MARK: - Bool SQLIteDataCompatible
extension Bool: SQLIteDataCompatible {
  
  public init?(sqlite statment: OpaquePointer, at index: Int) {
    
    self.init(sqlite3_column_int(statment, Int32(index)) != 0)
  }
  
  public func bind(sqlite statment: OpaquePointer, at index: Int) -> SQLite.State {
    
    let code = sqlite3_bind_int64(statment, Int32(index), self ? 1 : 0)
    return SQLite.State(code)
  }
  
}

// MARK: - Int SQLIteDataCompatible
extension Int: SQLIteDataCompatible {
  
  public init?(sqlite statment: OpaquePointer, at index: Int) {
    
    self.init(sqlite3_column_int64(statment, Int32(index)))
  }
  
  public func bind(sqlite statment: OpaquePointer, at index: Int) -> SQLite.State {
    
    let code = sqlite3_bind_int64(statment, Int32(index), Int64(self))
    return SQLite.State(code)
  }
  
}

// MARK: - Float SQLIteDataCompatible
extension Float: SQLIteDataCompatible {
  
  public init?(sqlite statment: OpaquePointer, at index: Int) {
    
    self.init(sqlite3_column_double(statment, Int32(index)))
  }
  
  public func bind(sqlite statment: OpaquePointer, at index: Int) -> SQLite.State {
    
    let code = sqlite3_bind_double(statment, Int32(index), Double(self))
    return SQLite.State(code)
  }
  
}

// MARK: - Double SQLIteDataCompatible
extension Double: SQLIteDataCompatible {
  
  public init?(sqlite statment: OpaquePointer, at index: Int) {
    
    self.init(sqlite3_column_double(statment, Int32(index)))
  }
  
  public func bind(sqlite statment: OpaquePointer, at index: Int) -> SQLite.State {
    
    let code = sqlite3_bind_double(statment, Int32(index), self)
    return SQLite.State(code)
  }
}

// MARK: - String SQLIteDataCompatible
extension String: SQLIteDataCompatible {
  
  public init?(sqlite statment: OpaquePointer, at index: Int) {
    
    guard let cString = sqlite3_column_text(statment, Int32(index)) else { return nil }
    self.init(cString: cString)
  }
  
  public func bind(sqlite statment: OpaquePointer, at index: Int) -> SQLite.State {
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    let code = sqlite3_bind_text(statment, Int32(index), self, -1, SQLITE_TRANSIENT)
    return SQLite.State(code)
  }
  
}

// MARK: - Data SQLIteDataCompatible
extension Data: SQLIteDataCompatible {
  
  public init?(sqlite statment: OpaquePointer, at index: Int) {
    
    guard let bytes = sqlite3_column_blob(statment, Int32(index)) else { return nil }
    let count = sqlite3_column_bytes(statment, Int32(index))
    
    self.init(bytes: bytes, count: Int(count))
  }
  
  public func bind(sqlite statment: OpaquePointer, at index: Int) -> SQLite.State {
    
    let bytes = [UInt8](self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    let code = sqlite3_bind_blob(statment, Int32(index), bytes, Int32(bytes.count), SQLITE_TRANSIENT)
    
    return SQLite.State(code)
  }
  
}
