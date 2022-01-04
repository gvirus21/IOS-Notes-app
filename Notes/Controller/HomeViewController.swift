//
//  homeViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 16/12/21.
//

import UIKit

protocol UpdateUI: AnyObject {
    func updateTableView()
}


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var table: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Rounds the corners of add button
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.masksToBounds = true
        
        // table
        
        // registering table cell
        let nib = UINib(nibName: "NoteTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "NoteTableViewCell")
        
        
        table.delegate = self
        table.dataSource = self
        
        //load local storage data
        noteManager.loadLocalStorageData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let addNoteVC = storyboard.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        
        addNoteVC.modalPresentationStyle = .fullScreen
        
        addNoteVC.delegate = self
        
        self.navigationController?.pushViewController(addNoteVC, animated: true)

            
                
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteManager.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell

        cell.heading?.text = noteManager.notes[indexPath.row].note.title
        cell.content?.text = noteManager.notes[indexPath.row].note.content
        
        return cell
    }
    
    
    // swipe to delete
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // delete the note from memory
            let _ = noteManager.deleteNote(indexPath.row)
            
            // removing note from ui
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // select a note from table view
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let addNoteVC = storyboard.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        
        let clickedNote = noteManager.notes[indexPath.row].note
        
        addNoteVC.delegate = self

        
        addNoteVC.noteTitle = clickedNote.title
        addNoteVC.noteContent = clickedNote.content
        addNoteVC.selectedRow = indexPath.row
        
        self.navigationController?.pushViewController(addNoteVC, animated: true)
    }
}

extension HomeViewController: UpdateUI {
    func updateTableView() {
        print("update the table view")

        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
}
