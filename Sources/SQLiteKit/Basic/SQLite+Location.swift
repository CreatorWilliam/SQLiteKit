//
//  SQLite+Location.swift
//  
//
//  Created by William Lee on 2019/10/31.
//

import Foundation

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
