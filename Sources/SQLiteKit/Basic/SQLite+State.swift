//
//  SQLite+State.swift
//  
//
//  Created by William Lee on 2019/10/31.
//

import Foundation
import SQLite3

// MARK: - State
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
