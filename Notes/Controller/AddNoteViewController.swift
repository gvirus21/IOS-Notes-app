//
//  addNoteViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 16/12/21.
//

import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate {
    
    let placeholder = "Note"

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
//    var noteManager = NoteManager()
    
    var noteTitle = "Title"
    var noteContent = ""
        
    var delegate: UpdateUI?
    
    var note = Note(title: "", content: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        noteTextView.delegate = self
        noteTextView.text = placeholder
        noteTextView.textColor = .lightGray
        

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        


        
        if noteTextView.text == "" {
            noteTextView.text = placeholder
            noteTextView.textColor = .lightGray
        }

        noteTitle = titleTextField.text!
        
        
        // prevents from adding placeholder text to textview
        if noteTextView.textColor == .lightGray {
            noteContent = ""
        } else {
            noteContent = noteTextView.text!
        }
        
        if noteTitle != "" {
            note.title = noteTitle
            note.content = noteContent
        }
        
        let _ = noteManager.addNote(note) { added in
            if added {
                print("added")
                delegate?.updateTableView()
                
            } else {
                print("not added")
            }
        }
        
        
        
        //  go back to main screen
        
        
        dismiss(animated: true, completion: nil)
        
    }

}



