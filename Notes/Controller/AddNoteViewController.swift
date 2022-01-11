//
//  addNoteViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 16/12/21.
//

import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {


    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    

    var delegate: UpdateUI?
    
    var note = Note(title: "", content: "")
    
    var selectedRow: Int = 9999999

    var editMode = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField?.delegate = self
        noteTextView?.delegate = self
        
        titleTextField.text = note.title
        noteTextView.text = note.content
        
        if note.title != "" || note.content != "" {
            // make editing true
            editMode = true
        }
    }
    
    func saveNote() {
        
        
            note.title = titleTextField.text!
            note.content = noteTextView.text!


        if let _ = noteManager.addNote(note) {


                delegate?.updateTableView()
           
        } else {
            print("not added")
        }
      
    }
    
    
    func editNote() {
        
         note.title = titleTextField.text!
         note.content = noteTextView.text!
        
        //use id insted of row/index
        _ = noteManager.editNote(row: selectedRow, title: note.title, content: note.content) { edited in
            
        if edited {
            delegate?.updateTableView()
        } else {
            print("editing failed")
        }

      }
   }
    

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        print("back button pressed ")
        
        if editMode {
            editNote()
        } else {
            saveNote()
        }

    }
    
}
