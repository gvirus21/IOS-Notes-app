//
//  NoteManager.swift
//  Notes
//
//  Created by Gourav Kumar on 17/12/21.
//

import UIKit

class NoteManager: Codable {

  
 var notes: [NoteItem] = []
 var filteredNotes: [NoteItem] = []

    
  ///Translates a given Note ID to the index of the note in the `notes` array

    private func indexOfNote(id: UUID) -> Int? {
    return notes.firstIndex { $0.note.id == id }
  }
    
    func sortByDate() {
        notes.sort {
            $0 > $1
        }

    }
    
    func sortPinnedNotes() {
        var index = 0
        for noteItem in notes {
            if noteItem.isPinned {
                let removedNoteItem = notes.remove(at: index)
                notes.insert(removedNoteItem, at: 0)

            }
            index += 1
        }
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
          } catch {
            print("error decode > \(error)")
          }
        
    }
    

    func addNote(_ note: Note ) -> UUID? {
        
    guard note.title.isEmpty == false || note.content.isEmpty == false else { return nil }
      
          let noteItem = NoteItem(note: note)
          
          var topIndex = 0
        
        for noteItem in notes {
            if noteItem.isPinned {
                topIndex += 1
            }
        }
        
          //appends to the notes array
          notes.insert(noteItem, at: topIndex)
          
          //updates local storage
          updateLocalStorage()
          
          
          //update filtered notes
          filteredNotes = notes
          
          return note.id
          
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
        
        
        // Updating the values
        
        notes[row].note.title = title
        notes[row].note.content = content
        
        
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


// note pin issue - fixed
// hide secure notes
//
