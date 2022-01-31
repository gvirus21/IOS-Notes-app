//
//  homeViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 16/12/21.
//

import UIKit

//Reminder: ensure each commit addressed one issue or feature
//
//on tapping on empty space of the tableView, go to new note screen - tick
//find crashes & fix - tick
//explore trailing action on left; [pin, secure] [archive, delete] - tick
//change the toggle secure menu action label
//- show archived / show normal
//- show secured / hide secured
//PP::Refactor VCs to MVVM
//PP::Introduce APIs to read/write; provider pattern
//Ready for 1huddle

class HomeViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    
    var toggleSecuredNotes = true
    var toggleArchivedNotes = false
    
    var betterNoteManager = BetterNoteManager()
    
    var notes: [BetterNote] {
        let notes = betterNoteManager.getAllNotes(searchTerm: searchField.text)
        
        if toggleArchivedNotes {
            return betterNoteManager.getArchivedNotes()
        } else {
            if toggleSecuredNotes {
                return notes
            } else {
                return notes.filter { $0.isSecured == false }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuActions()
        setupTableView()
        restoreNotes()
        detectTapInEmptyArea()
        searchField.delegate = self
    }
    
    func detectTapInEmptyArea() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureFired(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func gestureFired(_ gesture: UITapGestureRecognizer){
        goToCreateNoteScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    
    
    func setupTableView() {
        let nib = UINib(nibName: "NoteTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoteTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupMenuActions() {
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.masksToBounds = true
        
        let toggleArchived = UIAction(title: "Toggle Archived Notes") { _ in
            self.toggleArchive()
        }
        
        let toggleSecured = UIAction(title: "Toggle Secured Notes") { _ in
            self.toggleSecureNoteView()
        }
        
        let backup = UIAction(title: "Backup") { _ in
            self.backupNotes()
        }
        
        let restore = UIAction(title: "Restore") { _ in
            self.restoreNotes()
        }
        
        let deleteAll = UIAction(title: "Delete All") { _ in
            self.deleteAllNotes()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "",
                                                            image: UIImage(systemName: "list.number"),
                                                            menu: .init(title: "",
                                                                        children: [
                                                                            toggleArchived,
                                                                            toggleSecured,
                                                                            backup,
                                                                            restore,
                                                                            deleteAll,
                                                                        ]))
    }
    
}

extension HomeViewController {
    
    func toggleArchive() {
        toggleArchivedNotes = !toggleArchivedNotes
        tableView.reloadData()
    }
    
    func toggleSecureNoteView() {
        toggleSecuredNotes = !toggleSecuredNotes
        tableView.reloadData()
    }
    
    func deleteAllNotes() {
        betterNoteManager.clear()
        tableView.reloadData()
    }
    
    func goToCreateNoteScreen() {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        vc.betterNoteManager = betterNoteManager
        
        vc.modalPresentationStyle = .fullScreen
        self.show(vc, sender: nil)
    }
    
}

//MARK: Button Actions
extension HomeViewController {
    
    @IBAction func addButtonPressed(_ sender: Any) {
        goToCreateNoteScreen()
    }

}

//MARK: TableView Datasource
extension HomeViewController: UITableViewDataSource {
    
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
    
}



//MARK: TableView Delegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
        {
        let note = notes[indexPath.row]

        let secureLabel = note.isSecured ? "Unsecure" : "Secure"
            
        let privacy = UIContextualAction(style: .normal , title: secureLabel) { (_, _, _ ) in
            self.betterNoteManager.secureNote(id: note.id, secure: !note.isSecured)
            self.tableView.reloadData()
        }
        
        let pinLabel = note.isPinned ? "Unpin" : "Pin"
            
        let pin = UIContextualAction(style: .normal, title: pinLabel) { (_, _, _) in
            self.betterNoteManager.pinNote(id: note.id, pin: !note.isPinned)
            self.tableView.reloadData()
        }
            
        pin.backgroundColor = .systemYellow
        privacy.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [pin, privacy])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = notes[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _ ) in
            self.betterNoteManager.deleteNote(id: note.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let archiveLabel = note.isArchived ? "Unarchive" : "Archive"
            
        let archive = UIContextualAction(style: .normal, title: archiveLabel) { (_, _, _) in
            self.betterNoteManager.archiveNote(!note.isArchived, id: note.id)
            self.tableView.reloadData()
        }
        
        archive.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [delete, archive])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        vc.betterNoteManager = betterNoteManager
        vc.noteID = notes[indexPath.row].id
        
        self.show(vc, sender: nil)
    }
    
}

//MARK: Search bar related
extension HomeViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }

}

//MARK: Read/Write from Disk
extension HomeViewController {
    
    func backupNotes() {
        let contents = betterNoteManager.getPinnedNotes() + betterNoteManager.getNormalNotes() + betterNoteManager.getArchivedNotes()
        
        do {
            let data = try JSONEncoder().encode(contents)
            
            let filename = "notes.backup"
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) {
                try data.write(to: url)
                print("backed up successfully")
            } else {
                print("error: unable to backup")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func restoreNotes()  {
        let filename = "notes.backup"
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) {
            do {
                let data = try Data(contentsOf: url)
                let notes = try JSONDecoder().decode([BetterNote].self, from: data)
                betterNoteManager.addNotes(notes)
                tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("error: unable to restore")
        }
    }
    
}

