//
//  ArchiveViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 12/01/22.
//

import UIKit

class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var archiveTable: UITableView!
    var betterNoteManager: BetterNoteManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Archive"
        
        let nib = UINib(nibName: "NoteTableViewCell", bundle: nil)
        archiveTable.register(nib, forCellReuseIdentifier: "NoteTableViewCell")
        
        archiveTable.delegate = self
        archiveTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return betterNoteManager.getArchivedNotes().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = betterNoteManager.getArchivedNotes()[indexPath.row]
        
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
    
    
    // table view swipe acitons
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = betterNoteManager.getArchivedNotes()[indexPath.row]
        
        let unarchive = UIContextualAction(style: .normal, title: "Unarchive") { (_, _, _) in
            self.betterNoteManager.archiveNote(!note.isArchived, id: note.id)
            self.archiveTable.reloadData()
        }
        unarchive.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [unarchive])
    }
    
}



