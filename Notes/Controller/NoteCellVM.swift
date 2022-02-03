//
//  NoteCellVM.swift
//  Notes
//
//  Created by Gourav Kumar on 02/02/22.
//

import Foundation

struct NoteCellVM {
    private let note: Note
    
    var noteTitle: String { note.title ?? "" }
    var noteContent: String { note.isSecured ? "***" : note.content ?? "" }
    var modifiedDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return formatter.string(from: note.dateModified)
    }
    
    var isPinned: Bool { note.isPinned }
    
    init(note: Note) {
        self.note = note
    }
}
