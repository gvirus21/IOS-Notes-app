//
//  NoteManager.swift
//  Notes
//
//  Created by Gourav Kumar on 17/12/21.
//

import UIKit

class NoteManager: Codable {

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
  
  static var notes: [NoteItem] = []

  ///Translates a given Note ID to the index of the note in the `notes` array
    
  static private func indexOfNote(id: UUID) -> Int? {
    return notes.firstIndex { $0.note.id == id }
  }
    
    
    static func updateLocalStorage() {
        
        // adding noteItem to local storage
        
        let plistEncoder = PropertyListEncoder()
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notes.plist") else { return }
        
        do {
            let data = try plistEncoder.encode(notes)
             try data.write(to: path)
            
            //print("data saved!: \(data)")
          } catch {
            print("error encode > \(error)")
          }
        
        
    }
    
    static func loadLocalStorageData() {
        // Load data
        let plistDecoder = PropertyListDecoder()
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notes.plist") else { return }
        
          do {
            let decodedData = try Data(contentsOf: path)
            notes = try plistDecoder.decode([NoteItem].self, from: decodedData)
            print("data restore !")
          } catch {
            print("error decode > \(error)")
          }
        
        print(notes)
        //update the Table UI
//        updateTableView()
        
        
    }
    

    static func addNote(_ note: Note, completion: (Bool) -> Void) -> UUID? {
        
    guard note.title.isEmpty == false || note.content.isEmpty == false else { return nil }
      
      var doesAlreadyExist = false
      
      
      notes.forEach { n in
          if n.note.id == note.id {
              doesAlreadyExist = true
          }

      }
      
      if !doesAlreadyExist {
          //create noteItem
          let noteItem = NoteItem(note: note)
          
          //appends to the notes array
          notes.append(noteItem)
          
          //updates local storage
          updateLocalStorage()
          
          completion(true)
          
          return note.id
      } else {
          
          completion(false)
      }
            
   return nil
      
  }
    
    
    static func deleteNote(_ row: Int)->Bool{
        
        // delete note from note array
        notes.remove(at: row)
        
        // delete note from database
        updateLocalStorage()
        
        // update UI
//        updateTable()
        
        return true
      }
    
//    func getNote() {
//
//    }
//
//  static func deleteNote(_ id: UUID)->Bool{
//    guard let foundIndex = indexOfNote(id: id)
//    else { return false }
//
//    notes.remove(at: foundIndex)
//    return true
//  }
//
//  static func editNote(id: UUID, title: String, content: String) -> Bool {
//    guard let foundIndex = indexOfNote(id: id)
//    else { return false }
//
//    notes[foundIndex].note.title = title
//    notes[foundIndex].note.content = content
//
//    return true
//  }
//
//
//  static func togglePin(_ id: UUID) -> Bool {
//    guard let foundIndex = indexOfNote(id: id)
//    else { return false }
//
//    notes[foundIndex].isPinned.toggle()
//    return true
//  }
//
//  static func toggleSecureNote(_ id: UUID) -> Bool {
//    guard let foundIndex = indexOfNote(id: id)
//    else { return false }
//
//    notes[foundIndex].isSecured.toggle()
//    return true
//  }
//
//  ///Replaces the content of a note with *** if the note is secured
//  static private func getSecuredNote(for item: NoteItem) -> NoteItem {
//    var securedNote = item.note
//    securedNote.content = "***"
//
//    return NoteItem(note: securedNote,
//                    isPinned: item.isPinned,
//                    isSecured: item.isSecured)
//  }
//
//  ///Trims a note if the content is greater than 6 characters
//  static private func getTrimmedNote(for item: NoteItem) -> NoteItem {
//    let shortContent: String = {
//      let content = item.note.content
//      let index = content.index(content.startIndex, offsetBy: 6)
//      return String(content[..<index] + "...")
//    }()
//
//    var shortNote = item.note
//    shortNote.content = shortContent
//
//    let noteItem = NoteItem(note: shortNote,
//                            isPinned: item.isPinned,
//                            isSecured: item.isSecured)
//    return noteItem
//  }
//
////TODO: Replace Dictionary with Note
//  static func viewNote(id: UUID, asExpanded: Bool) -> NoteItem? {
//    guard let foundIndex = indexOfNote(id: id)
//    else { return nil }
//
//    let noteItem = notes[foundIndex]
//
//    if asExpanded {
//      return noteItem
//    } else {
//      if noteItem.isSecured {
//        return getSecuredNote(for: noteItem)
//      } else {
//        return getTrimmedNote(for: noteItem)
//      }
//    }
//  }
//
//  static func isNotePinned(_ id: UUID) -> Bool {
//    guard let foundIndex = indexOfNote(id: id)
//    else { return false }
//
//    return notes[foundIndex].isPinned
//  }
//
//  static func isNoteSecured(_ id: UUID)->Bool {
//    guard let foundIndex = indexOfNote(id: id)
//    else { return false }
//
//    return notes[foundIndex].isSecured
//  }
//
//  static func findNotes(containing keyword: String) ->[NoteItem]{
//    var outputNotes = [NoteItem]()
//        for note in notes{
//            if note.note.title.lowercased().contains(keyword){
//            outputNotes.append(note)
//          }
//        }
//    return outputNotes
//  }

}

