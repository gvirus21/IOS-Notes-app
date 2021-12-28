//
//  Note.swift
//  Notes
//
//  Created by Gourav Kumar on 17/12/21.
//

import Foundation

struct Note: Codable {
  var id : UUID = UUID()
  var title: String
  var content: String

  init(title: String = "", content: String = "") {
    self.title = title
    self.content = content
  }
}

extension Note: Equatable {
    static func ==(lhs: Note, rhs: Note) -> Bool{
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}


// first try to place completion handler
