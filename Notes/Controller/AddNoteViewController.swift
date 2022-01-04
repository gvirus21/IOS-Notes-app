//
//  addNoteViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 16/12/21.
//

import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate {


    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    
    var noteTitle = ""
    var noteContent = ""
        
    var delegate: UpdateUI?
    
    var note = Note(title: "", content: "")
    
    var selectedRow: Int = 9999999

    var editMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noteTextView.delegate = self
        
        titleTextField.text = noteTitle
        noteTextView.text = noteContent
        
        if noteTitle != "" || noteContent != "" {
            // make editing true
            editMode = true
        }
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
        
        noteTitle = titleTextField.text!
        noteContent = noteTextView.text!
        
        if editMode {
            
            print("editing")
            
            _ = noteManager.editNote(row: selectedRow, title: noteTitle, content: noteContent) { edited in
                if edited {
                    print("should update table view")
                    delegate?.updateTableView()
                } else {
                    print("editing failed")
                }
                
            }
            
        } else {
            
            // if edit mode is false, means we are creating a new note
            
            if noteTitle != "" {
                note.title = noteTitle
                note.content = noteContent
            
            
            let _ = noteManager.addNote(note) { added in
                
                if added {
                    delegate?.updateTableView()
                } else {
                    print("Error! not added")
                }
            }
            
        }
    }
        
        //  go back to main screen
        
        _ = navigationController?.popViewController(animated: true)
       

}


}


// note is editing but not updating the ui
