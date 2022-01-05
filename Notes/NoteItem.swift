//
//  NoteItem.swift
//  Notes
//
//  Created by Gourav Kumar on 05/01/22.
//

import Foundation


struct NoteItem: Equatable, Codable {
  var note: Note
  var isPinned: Bool
  var isSecured: Bool

  init(note: Note, isPinned: Bool = false, isSecured: Bool = false){
    self.note = note
    self.isPinned = isPinned
    self.isSecured = isSecured
  }
    
    static func ==(lhs: NoteItem, rhs: NoteItem) -> Bool{
        return lhs.note == rhs.note
    }
}
