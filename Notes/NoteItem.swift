//
//  NoteItem.swift
//  Notes
//
//  Created by Gourav Kumar on 05/01/22.
//

import Foundation


struct NoteItem: Equatable, Codable {
  var note: Note
  var dateCreated = Date()
  var isPinned: Bool
  var isSecured: Bool

  init(note: Note, isPinned: Bool = false, isSecured: Bool = false){
    self.note = note
    self.isPinned = isPinned
    self.isSecured = isSecured
  }
    
    
}

extension NoteItem: Comparable {
    static func < (lhs: NoteItem, rhs: NoteItem) -> Bool {
        return lhs.dateCreated < rhs.dateCreated
    }
    
    static func > (lhs: NoteItem, rhs: NoteItem) -> Bool {
        return lhs.dateCreated > rhs.dateCreated
    }

    
    static func ==(lhs: NoteItem, rhs: NoteItem) -> Bool{
        return lhs.note == rhs.note
    }
    
    
}
