//
//  BetterNoteManager.swift
//  Notes
//
//  Created by Gourav Kumar on 19/01/22.
//

import Foundation

struct BetterNote {
    let id: UUID
    var title: String?
    var content: String?
    
    var isPinned: Bool
    var isSecured: Bool
    var isArchived: Bool
    
    let dateCreated: Date
    var dateModified: Date
    
    init?(id: UUID = UUID(), title: String? = nil, content: String? = nil, isPinned: Bool = false, isSecured: Bool = false, isArchived: Bool = false, dateCreated: Date = Date(), dateModified: Date = Date()) {
        if title == nil, content == nil {
            return nil
        }
        
        self.id           = id
        self.title        = title
        self.content      = content
        self.isPinned     = isPinned
        self.isSecured    = isSecured
        self.isArchived   = isArchived
        self.dateCreated  = dateCreated
        self.dateModified = dateModified
    }
}

///
///Add Note
///Delete Note
///Edit Note
///Secure Note
///Archive Note
///Pin Note
///Delete all notes
///
///Cleanup the ViewController
///
///D.R.Y optimizations
///Data Persistence; Read/Write from some persistent data source
///MVVM

class BetterNoteManager {
    
    //static var shared = BetterNoteManager()
    
    private var normalNotes: [BetterNote] = []
    private var pinnedNotes: [BetterNote] = []
    private var archivedNotes: [BetterNote] = []
    
    init(notes: [BetterNote]) {
        self.normalNotes = notes
    }
    
    func getAllNotes(searchTerm: String? = nil) -> [BetterNote] {
        let notes = pinnedNotes + normalNotes
        
        if let searchTerm = searchTerm, searchTerm.isEmpty == false {
            return notes.filter { (note) in
                if let title = note.title, title.lowercased().contains(searchTerm.lowercased()) {
                    return true
                } else if let content = note.content, content.lowercased().contains(searchTerm.lowercased()) {
                    return true
                }
                else {
                    return false
                }
            }
        } else {
            return notes
        }
    }
    
    func getArchivedNotes() -> [BetterNote] {
        return archivedNotes
    }
    
    func getPinnedNotes() -> [BetterNote] {
        return pinnedNotes
    }
    
    func getSecuredNotes(searchTerm: String? = nil) -> [BetterNote] {
        return getAllNotes(searchTerm: searchTerm).filter { $0.isSecured }
    }
    
    @discardableResult
    func addNote(title: String?, content: String?) -> UUID? {
        guard let note = BetterNote(title: title, content: content)
        else { return nil }
        
        normalNotes.insert(note, at: 0)
        
        return note.id
    }
    
    @discardableResult
    func deleteNote(id: UUID) -> Bool {
        if let foundIndex = normalNotes.firstIndex(where: { $0.id == id }) {
            normalNotes.remove(at: foundIndex)
            return true
        } else if let foundIndex = pinnedNotes.firstIndex(where: { $0.id == id }) {
            pinnedNotes.remove(at: foundIndex)
            return true
        } else if let foundIndex = archivedNotes.firstIndex(where: { $0.id == id }) {
            archivedNotes.remove(at: foundIndex)
            return true
        } else {
            return false
        }
    }
    
    func clear() {
        normalNotes = []
        pinnedNotes = []
        archivedNotes = []
    }
    
    @discardableResult
    func editNote(id: UUID, title: String?, content: String?) -> Bool {
        if let foundIndex = normalNotes.firstIndex(where: { $0.id == id }) {
            normalNotes[foundIndex].title = title
            normalNotes[foundIndex].content = content
            
            if title?.isEmpty ?? true, content?.isEmpty ?? true {
                deleteNote(id: id)
                return false
            } else {
                return true
            }
        } else if let foundIndex = pinnedNotes.firstIndex(where: { $0.id == id }) {
            pinnedNotes[foundIndex].title = title
            pinnedNotes[foundIndex].content = content
            
            if title?.isEmpty ?? true, content?.isEmpty ?? true {
                deleteNote(id: id)
                return false
            } else {
                return true
            }
        } else if let foundIndex = archivedNotes.firstIndex(where: { $0.id == id }) {
            archivedNotes[foundIndex].title = title
            archivedNotes[foundIndex].content = content
            
            if title?.isEmpty ?? true, content?.isEmpty ?? true {
                deleteNote(id: id)
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    @discardableResult
    func pinNote(id: UUID, pin: Bool) -> Bool {
        if pin {
            //move from notes to pinned
            guard let foundIndex = normalNotes.firstIndex(where: { $0.id == id }) else { return false }
            var note = normalNotes.remove(at: foundIndex)
            note.isPinned = pin
            pinnedNotes.insert(note, at: 0)
        } else {
            //move from pinned to notes
            guard let foundIndex = pinnedNotes.firstIndex(where: { $0.id == id }) else { return false }
            var note = pinnedNotes.remove(at: foundIndex)
            note.isPinned = pin
            normalNotes.append(note)
            normalNotes.sort { $0.dateCreated > $1.dateCreated }
        }
        
        return true
    }
    
    @discardableResult
    func secureNote(id: UUID, secure: Bool) -> Bool {
        if let foundIndex = normalNotes.firstIndex(where: { $0.id == id }) {
            normalNotes[foundIndex].isSecured = secure
            return true
        } else if let foundIndex = pinnedNotes.firstIndex(where: { $0.id == id }) {
            pinnedNotes[foundIndex].isSecured = secure
            return true
        } else if let foundIndex = archivedNotes.firstIndex(where: { $0.id == id }) {
            archivedNotes[foundIndex].isSecured = secure
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    func archiveNote(_ archive: Bool, id: UUID) -> Bool {
        if archive {
            if let foundIndex = normalNotes.firstIndex(where: { $0.id == id }) {
                var note = normalNotes.remove(at: foundIndex)
                note.isArchived = archive
                archivedNotes.append(note)
                return true
            } else if let foundIndex = pinnedNotes.firstIndex(where: { $0.id == id }) {
                var note = pinnedNotes.remove(at: foundIndex)
                note.isArchived = archive
                archivedNotes.append(note)
                return true
            } else {
                return false
            }
        } else if let foundIndex = archivedNotes.firstIndex(where: { $0.id == id }) {
            var note = archivedNotes.remove(at: foundIndex)
            note.isArchived = archive
            if note.isPinned {
                pinnedNotes.append(note)
                pinnedNotes.sort { $0.dateCreated > $1.dateCreated }
            } else {
                normalNotes.append(note)
                normalNotes.sort { $0.dateCreated > $1.dateCreated }
            }
            return true
        } else {
            return false
        }
    }
    
}
