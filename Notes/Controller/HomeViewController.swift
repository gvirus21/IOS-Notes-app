//
//  homeViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 16/12/21.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    
    var shouldShowSecureNotes = false
    
    var betterNoteManager: BetterNoteManager = {
        let date = Date(timeIntervalSince1970: 0)
        let notes: [BetterNote] = (1...5).reversed().compactMap { (idx) in
            BetterNote(title: "Automatic \(idx)",
                       content: ["Hello", "Hola", "Yo", "Sup", "Hey", "Hi", "Kaisa hai bey"].randomElement()!,
                       dateCreated: date.addingTimeInterval(TimeInterval(idx) * 10))
        }

        return BetterNoteManager(notes: notes)
    }()
    
    var notes: [BetterNote] {
        if shouldShowSecureNotes {
            return betterNoteManager.getSecuredNotes(searchTerm: searchField.text)
        } else {
            return betterNoteManager.getAllNotes(searchTerm: searchField.text)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure buttons
        configureButtons()
        
        // registering table cell
        let nib = UINib(nibName: "NoteTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "NoteTableViewCell")

        table.delegate = self
        table.dataSource = self
        searchField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.table.reloadData()
    }
    
    func configureButtons() {
        
        //Rounds the corners of add button
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.masksToBounds = true
        
        
        //Configure menu button
        
        let secureOptionTitle = shouldShowSecureNotes ? "Hide Secure notes" : "Show secure notes"
        
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Archive", handler: { (_) in self.navigateToArchive()}),  // navigate to diffrent page to show archive notes
            UIAction(title: secureOptionTitle, handler: { (_) in self.toggleSecureNoteView()}),    // should hide/show secure notes
            UIAction(title: "delete all notes", handler: { (_) in self.deleteAllNotes()}), // makes notes empty
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "list.number"), menu: menu)
    }
    
    // toggles securenoteview
    func toggleSecureNoteView() {
        shouldShowSecureNotes = !shouldShowSecureNotes
        table.reloadData()
    }
    
    func deleteAllNotes() {
        betterNoteManager.clear()
        table.reloadData()
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let sb : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        vc.betterNoteManager = betterNoteManager
        
        vc.modalPresentationStyle = .fullScreen
        self.show(vc, sender: nil)
    }
    
    //table view functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        cell.pinLabel.text = note.isPinned ? "Pinned" : ""
        cell.heading.text = note.title
        cell.content.text = note.isSecured ? "***" : note.content
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = dateFormatter.string(from: note.dateCreated)
        
        cell.DateLabel?.text = formattedDate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = notes[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "delete") { (_, _, _ ) in
            self.betterNoteManager.deleteNote(id: note.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let secureLabel = note.isSecured ? "Unsecure" : "Secure"
        let privacy = UIContextualAction(style: .normal , title: secureLabel) { (_, _, _ ) in
            self.betterNoteManager.secureNote(id: note.id, secure: !note.isSecured)
            self.table.reloadData()
        }
        
        let archive = UIContextualAction(style: .normal, title: "Archive") { (_, _, _) in
            self.betterNoteManager.archiveNote(!note.isArchived, id: note.id)
            self.table.reloadData()
        }

        let pinLabel = note.isPinned ? "Unpin" : "Pin"
        let pin = UIContextualAction(style: .normal, title: pinLabel) { (_, _, _) in
            self.betterNoteManager.pinNote(id: note.id, pin: !note.isPinned)
            self.table.reloadData()
        }
        
        pin.backgroundColor = .systemYellow
        privacy.backgroundColor = .green
        archive.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [delete, archive, privacy, pin])
    }
    
    // select a note from table view
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        vc.betterNoteManager = betterNoteManager
        vc.noteID = notes[indexPath.row].id
        
        self.show(vc, sender: nil)
    }
}


extension HomeViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        table.reloadData()
    }

}
