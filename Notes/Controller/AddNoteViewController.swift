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
    
    var betterNoteManager: BetterNoteManager!
    var noteID: UUID? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField?.delegate = self
        noteTextView?.delegate = self
        
        let note = betterNoteManager.getAllNotes().first { $0.id == noteID }
        titleTextField.text = note?.title
        noteTextView.text = note?.content
    }
    
    func saveNote() {
        let title = titleTextField.text
        let content = noteTextView.text
        
        if let noteID = noteID {
            betterNoteManager.editNote(id: noteID,
                                       title: title,
                                       content: content)
        } else {
            betterNoteManager.addNote( title: title,
                                       content: content)
        }
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNote()
    }
    
}
