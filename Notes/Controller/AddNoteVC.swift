//
//  addNoteViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 16/12/21.
//

import UIKit

class AddNoteVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    var betterNoteManager: BetterNoteManager!
    var noteID: UUID? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDelegates()
        setNote()
        
    }
    
    func setUI() {
        view.backgroundColor = UIColor(hexaString: "#202240")
        
        titleTextField.backgroundColor = .clear
        titleTextField.textColor = .white
        titleTextField.placeholder = "Title"
        
        //setting placeholder text color
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Title",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
            
        )
        
        noteTextView.backgroundColor = .clear
        noteTextView.textColor = .white
    }
    
    func setDelegates() {
        titleTextField?.delegate = self
        noteTextView?.delegate = self
    }
    
    func setNote() {
      
        var note = betterNoteManager.getArchivedNotes().first { $0.id == noteID }
        
        if note == nil {
            note = betterNoteManager.getNormalNotes().first { $0.id == noteID }
        }
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
