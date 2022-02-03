//
//  BetterNoteManager.swift
//  Notes
//
//  Created by Gourav Kumar on 19/01/22.
//

import Foundation

class BetterNoteManager {
    
    private var normalNotes: [Note] = []
    private var pinnedNotes: [Note] = []
    private var archivedNotes: [Note] = []
    
    init(notes: [Note] = []) {
        for note in notes {
            if note.isArchived {
                archivedNotes.append(note)
            } else if note.isPinned {
                pinnedNotes.append(note)
            } else {
                normalNotes.append(note)
            }
        }
    }
    
    func addNotes(_ notes: [Note]) {
        for note in notes {
            if note.isArchived, !archivedNotes.contains(where: { $0.id == note.id }) {
                archivedNotes.append(note)
            } else if note.isPinned, !pinnedNotes.contains(where: { $0.id == note.id }) {
                pinnedNotes.append(note)
            } else if !normalNotes.contains(where: { $0.id == note.id }) {
                normalNotes.append(note)
            }
        }
    }
    
    func getAllNotes(searchTerm: String? = nil) -> [Note] {
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
    
    func getNormalNotes() -> [Note] {
        return normalNotes
    }
    
    func getArchivedNotes() -> [Note] {
        return archivedNotes
    }
    
    func getPinnedNotes() -> [Note] {
        return pinnedNotes
    }
    
    func getSecuredNotes(searchTerm: String? = nil) -> [Note] {
        return getAllNotes(searchTerm: searchTerm).filter { $0.isSecured }
    }
    
    @discardableResult
    func addNote(title: String?, content: String?) -> UUID? {
        if title != "" || content != "" {
            guard let note = Note(title: title, content: content)
            else { return nil }
            
            normalNotes.insert(note, at: 0)
            
            return note.id
        }
        return nil
        
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
        
        func editNote(inArray: inout [Note]) -> Bool {
            guard let foundIndex = inArray.firstIndex(where: { $0.id == id }) else { return false }
            
            inArray[foundIndex].title = title
            inArray[foundIndex].content = content
            
            if title?.isEmpty ?? true, content?.isEmpty ?? true {
                deleteNote(id: id)
                return false
            } else {
                return true
            }
        }
        
        return editNote(inArray: &archivedNotes) || editNote(inArray: &pinnedNotes) || editNote(inArray: &normalNotes)
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
            
            insertNormalNote(note)
        }
        
        return true
    }
    
    @discardableResult
    func secureNote(id: UUID, secure: Bool) -> Bool {
        func secureNote(inArray: inout [Note]) -> Bool {
            guard let foundIndex = inArray.firstIndex(where: { $0.id == id }) else { return false }
            inArray[foundIndex].isSecured = secure
            return true
        }
        
        return secureNote(inArray: &normalNotes) || secureNote(inArray: &pinnedNotes) || secureNote(inArray: &archivedNotes)
    }
    
    @discardableResult
    func archiveNote(id: UUID, archive: Bool) -> Bool {
        func archiveNote(fromArray: inout [Note]) -> Bool {
            guard let foundIndex = fromArray.firstIndex(where: { $0.id == id }) else { return false }
            var note = fromArray.remove(at: foundIndex)
            note.isArchived = archive
            archivedNotes.append(note)
            return true
        }
        
        if archive {
            return archiveNote(fromArray: &normalNotes) || archiveNote(fromArray: &pinnedNotes)
        } else if let foundIndex = archivedNotes.firstIndex(where: { $0.id == id }) {
            var note = archivedNotes.remove(at: foundIndex)
            note.isArchived = archive
            
            if note.isPinned {
                pinnedNotes.append(note)
            } else {
                insertNormalNote(note)
            }
            return true
        } else {
            return false
        }
    }
    
    private func insertNormalNote(_ note: Note) {
        let insertAtIndex = normalNotes.firstIndex(where: { $0.dateCreated < note.dateCreated }) ?? normalNotes.count
        normalNotes.insert(note, at: insertAtIndex)
    }
    
}


// carsh - 1

// - when you click on a note in archive mode, it will show empty create note screen
// - when you press, go back button, app will crash
  
