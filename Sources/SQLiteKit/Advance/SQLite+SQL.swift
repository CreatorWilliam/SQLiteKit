//
//  SQLite+SQL.swift
//  
//
//  Created by William Lee on 2019/10/31.
//

import Foundation

public extension SQLite {
  
  func prepare(_ sql: SQL) {
    
    prepare(sql.sentence)
    #if DEBUG
    print(sql.sentence)
    #endif
    
    sql.bindColumns.enumerated().forEach({ bind($0 + 1, with: $1.data) })
  }
  
  func excute(_ sql: SQL) {
    
    prepare(sql)
    step()
    finalize()
  }
  
  func excute(select sql: SQL, rowStartHandle: (SQLite) -> Void = { _ in }, rowEndHandle: (SQLite) -> Void = {_ in }) {
    
    prepare(sql)
    
    while step() == .row {
      
      rowStartHandle(self)
      
      sql.resultColumns.enumerated().forEach({ (index, item) in
        
        let data: SQLIteDataCompatible?
        switch item.dataType {
        case .bool:
          
          let temp: Bool? = column(at: index)
          data = temp
          
        case .integer:
          
          let temp: Int? = column(at: index)
          data = temp
          
        case .double:
          
          let temp: Double? = column(at: index)
          data = temp
          
        case .binary:
          
          let temp: Data? = column(at: index)
          data = temp
          
        case .text:
          
          let temp: String? = column(at: index)
          data = temp
        }
        item.assignmentHandle?(data)
      })
      
      rowEndHandle(self)
    }
    finalize()
  }
  
}
