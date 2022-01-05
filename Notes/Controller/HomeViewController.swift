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
    @IBOutlet weak var searchField: UISearchBar!
    
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
        
        searchField.delegate = self
        
        //load local storage data
        noteManager.loadLocalStorageData()
        
        
        // updates filtered Notes
        noteManager.filteredNotes = noteManager.notes
        
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
        return noteManager.filteredNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        
        // If note is secured then hide contents
        if noteManager.filteredNotes[indexPath.row].isSecured {
            cell.heading?.text = "Secured Note"
            cell.content?.text = "******"
        } else {
            
            print("\(noteManager.filteredNotes[indexPath.row].note.title): \(noteManager.filteredNotes[indexPath.row].isSecured)")
            cell.heading?.text = noteManager.filteredNotes[indexPath.row].note.title
            cell.content?.text = noteManager.filteredNotes[indexPath.row].note.content
        }
        
        
        return cell
    }
    
    
    // swipe to delete and secure/unsecure note
        
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "delete") {
            (delete,view,completion ) in
            
            // delete the note from memory
            let _ = noteManager.deleteNote(indexPath.row)
            
            // removing note from ui
              
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        let secureLabel = noteManager.filteredNotes[indexPath.row].isSecured ? "unsecure" : "secure"
        
        let toggleSecure = UIContextualAction(style: .normal, title: secureLabel) {
            (toggleSecure, view, completion) in
            
            toggleSecure.backgroundColor = UIColor.init(red: 0/255.0, green: 255/255.0, blue: 0/255.0, alpha: 0)
            
            noteManager.filteredNotes[indexPath.row].isSecured = !(noteManager.filteredNotes[indexPath.row].isSecured)
            
            //sets the value of notes same as filtered notes
            noteManager.notes = noteManager.filteredNotes
            
            //updates local storage
            noteManager.updateLocalStorage()
            
            //reloads the table
            self.table.reloadData()
            
        }
        
        return UISwipeActionsConfiguration(actions: [ delete, toggleSecure ])
    }
    
    // select a note from table view
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let addNoteVC = storyboard.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        
        let clickedNote = noteManager.filteredNotes[indexPath.row].note
        
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

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        noteManager.filteredNotes = []
        
        if searchText == "" {
            noteManager.filteredNotes = noteManager.notes
        }
        
        for noteItem in noteManager.notes {
            if noteItem.note.title.uppercased().contains(searchText.uppercased()) ||
                noteItem.note.content.uppercased().contains(searchText.uppercased())
            {
                noteManager.filteredNotes.append(noteItem)
            }
        }
        
        self.table.reloadData()
        
    }
}
