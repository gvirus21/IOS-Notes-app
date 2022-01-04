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
  
 var notes: [NoteItem] = []
    
    var filteredNotes: [NoteItem] = []

  ///Translates a given Note ID to the index of the note in the `notes` array
    
  private func indexOfNote(id: UUID) -> Int? {
    return notes.firstIndex { $0.note.id == id }
  }
    
    
    func updateLocalStorage() {
        
        // adding noteItem to local storage
        
        let plistEncoder = PropertyListEncoder()
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notes.plist") else { return }
        
        do {
            let data = try plistEncoder.encode(notes)
             try data.write(to: path)
          } catch {
            print("error encode > \(error)")
          }
        
    }
    
    func loadLocalStorageData() {
        // Load data
        // updates the notes array with locally stored data
        
        let plistDecoder = PropertyListDecoder()
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notes.plist") else { return }
        
          do {
            let decodedData = try Data(contentsOf: path)
            notes = try plistDecoder.decode([NoteItem].self, from: decodedData)
            print("data restore !")
          } catch {
            print("error decode > \(error)")
          }
        
    }
    

    func addNote(_ note: Note, completion: (Bool) -> Void) -> UUID? {
        
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
          
          //update table view
          completion(true)
          
          //update filtered notes
          filteredNotes = notes
          
          return note.id
      } else {
          
          completion(false)
      }
            
   return nil
      
  }
    
    
    func deleteNote(_ row: Int)->Bool{
        
        // delete note from note array
        notes.remove(at: row)
        
        // delete note from database
        updateLocalStorage()
        
        //update filtered notes
        filteredNotes = notes
        
        return true
      }
    
    func editNote(row: Int, title: String, content: String, completion: (Bool) -> Void) -> Bool {
        
        print("editNoteCalled")
        
        // Updating the values
        
        notes[row].note.title = title
        notes[row].note.content = content
        
        for noteItem in notes {
            print(noteItem.note.content)
        }
        
        // Updating the local storage
        updateLocalStorage()
        
        // Update table ui
        completion(true)
        
        //update filtered notes
        filteredNotes = notes

        return false
    }
    

}

var noteManager = NoteManager()
