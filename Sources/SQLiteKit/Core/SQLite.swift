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
  private var statment: OpaquePointer? = nil
  private var state: State = .unknow {
    didSet {
      guard self.state == .error || self.state == .unknow else { return }
      print(String(cString: sqlite3_errmsg(self.db), encoding: .utf8) ?? "error message is nil")
    }
  }
  
  public init(at location: URL) {
    
    self.location = location
  }
  
}

public extension SQLite {
  
  func creat(_ table: Table) {
    
    let tableName = table.name
    
    let sql = "CREATE TABLE IF NOT EXISTS t_\(tableName)(ID INTEGER PRIMARY KEY AUTOINCREMENT, \(table.columns.map({ "\($0.name) \($0.dataType.rawValue) " }).joined(separator: ", ")));"
    
    self.excute(sql)
  }
  
  func insert(_ item: SQLitable) {
    
    let table = item.table
    
    var keys: [String] = []
    var values: [Any] = []
    
    table.columns.forEach({ (column) in
      
      if let value = item.value(for: column) {
        
        keys.append(column.name)
        values.append(value)
      }
    })
    
    let sql = "INSERT INTO t_\(table.name) "
      + "(\(keys.joined(separator: ","))) "
      + "VALUES (\(values.map({ "\"\($0)\"" }).joined(separator: ",")))"
    
    self.excute(sql)
  }
  
  func remove(_ item: SQLitable) {
    
    let tableName = item.table.name
    let condition: String? = "id=\(item.id)"
    
    var sql = "DELETE FROM t_\(tableName)"
    
    if let condition = condition {
      
      sql += " WHERE \(condition)"
    }
    
    self.excute(sql)
  }
  
  func update(_ item: SQLitable) {
    
    let table = item.table
    var rowInfo: [String: Any] = [:]
    
    table.columns.forEach({ (column) in
      
      guard let value = item.value(for: column) else { return }
      rowInfo[column.name] = value
    })
    
    let condition: String? = "id=\(item.id)"
    
    var sql = "UPDATE t_\(table.name) SET "
    
    sql += rowInfo.map({ "\($0.key)=\'\($0.value)\'" }).joined(separator: ",")
    
    if let condition = condition {
      
      sql += " WHERE \(condition)"
    }
    
    self.excute(sql)
  }
  
}

// MARK: - Convince
public extension SQLite {
  
  func excute(with sql: String, bindHandle: (SQLite) -> Void) {
    
    prepare(sql)
    
    bindHandle(self)
    
    step()
    
    finalize()
  }
  
  func bind(_ index: Int, with value: Any?) {
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    let index = Int32(index)
    
    let code: Int32
    if let value = value as? Blob {
      
      code = sqlite3_bind_blob(self.statment, index, value.bytes, Int32(value.bytes.count), SQLITE_TRANSIENT)
      
    } else if let value = value as? Float {
      
      code = sqlite3_bind_double(self.statment, index, Double(value))
      
    } else if let value = value as? Double {
      
      code = sqlite3_bind_double(self.statment, index, value)
      
    } else if let value = value as? String {
      
      code = sqlite3_bind_text(self.statment, index, value, -1, SQLITE_TRANSIENT)
      
    } else if let value = value as? Int {
      
      code = sqlite3_bind_int64(self.statment, index, Int64(value))
      
    } else if let value = value as? Bool {
      
      code = sqlite3_bind_int64(self.statment, index, value ? 1 : 0)
      
    } else {
      
      code = sqlite3_bind_null(self.statment, index)
    }
    
    self.state = State(code)
  }
  
}

// MARK: - SQLite Original Funcation
public extension SQLite {
  
  func open() {
    
    let code = sqlite3_open(self.location.absoluteString, &self.db)
    self.state = State(code)
  }
  
  func close() {
    
    let code = sqlite3_close(self.db)
    self.state = State(code)
    self.db = nil
  }
  
  func excute(_ sql: String) {
    
    let code = sqlite3_exec(self.db, sql.cString(using: .utf8), nil, nil, nil)
    self.state = State(code)
  }
  
  func prepare(_ sql: String) {
    
    let code = sqlite3_prepare_v2(self.db, sql.cString(using: .utf8), -1, &self.statment, nil)
    self.state = State(code)
  }
  
  @discardableResult
  func step() -> State {
    
    let code = sqlite3_step(self.statment)
    self.state = State(code)
    return self.state
  }
  
  func reset() {
    
    let code = sqlite3_reset(self.statment)
    self.state = State(code)
  }
  
  func finalize() {
    
    let code = sqlite3_finalize(self.statment)
    //self.statment = nil
    self.state = State(code)
    self.statment = nil
  }
  
  func lastInsertID() -> Int {
    
    let id = sqlite3_last_insert_rowid(db)
    return Int(id)
  }
  
}

// MARK: - Column
public extension SQLite {
  
  func column(at index: Int) -> String {
    
    return String(cString: sqlite3_column_text(self.statment, Int32(index)))
  }
  
  func column(at index: Int) -> Int {
    
    return Int(sqlite3_column_int64(self.statment, Int32(index)))
  }
  
  func column(at index: Int) -> Double {
    
    return sqlite3_column_double(self.statment, Int32(index))
  }
  
  func column(at index: Int) -> Bool {
    
    return sqlite3_column_int(self.statment, Int32(index)) != 0
  }
  
}

// MARK: - Location
public extension SQLite {
  
  /// The location of a SQLite database.
  enum Location {
    
    /// An in-memory database (equivalent to `.uri(":memory:")`).
    ///
    /// See: <https://www.sqlite.org/inmemorydb.html#sharedmemdb>
    case inMemory
    
    /// A temporary, file-backed database (equivalent to `.uri("")`).
    ///
    /// See: <https://www.sqlite.org/inmemorydb.html#temp_db>
    case temporary
    
    /// A database located at the given URI filename (or path).
    ///
    /// See: <https://www.sqlite.org/uri.html>
    ///
    /// - Parameter filename: A URI filename
    case uri(String)
  }
  
}

// MARK: - CustomStringConvertible
extension SQLite.Location: CustomStringConvertible {
  
  public var description: String {
    
    switch self {
    case .inMemory: return ":memory:"
    case .temporary: return ""
    case .uri(let URI): return URI
    }
  }
  
}

public extension SQLite {
  
  enum State {
    
    case unknow
    
    /// Successful
    case ok
    /// sqlite3_step() has finished executing
    case done
    /// sqlite3_step() has another row ready
    case row
    /// Library used incorrectly
    case misuse
    /// Data type mismatch
    case mismatch
    
    case error
    
    
    init(_ code: Int32) {
      
      switch code {
      
      case SQLITE_OK: self = .ok
      case SQLITE_ERROR: self = .error
      case SQLITE_ROW: self = .row
      case SQLITE_DONE: self = .done
      case SQLITE_MISUSE: self = .misuse
      case SQLITE_MISMATCH: self = .mismatch
        
      default: self = .unknow
      }
    }
  }
  
  
}
