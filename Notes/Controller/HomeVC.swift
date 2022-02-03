//
//  HomeVC.swift
//  Notes
//
//  Created by Gourav Kumar on 24/01/22.
//

import UIKit

class HomeVC: UIViewController {
    
    var cellIdentifier: String { "NoteCell" }
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var menuButton: UIButton!
    
    
    let primaryColor = UIColor(hexaString: "#08070D")
    let secondaryColor = UIColor(hexaString: "#202240")
    
    @IBOutlet var collectionView: UICollectionView!
    
    var toggleSecuredNotes = true
    var toggleArchivedNotes = false
    
    var betterNoteManager = BetterNoteManager()
    
    var notes: [Note] {
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
        title = "Notes"
        
        setupUI()
        setupMenuButton()
        setupSearchField()
        setupCollectionView()
        restoreNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        self.backupNotes()
    }
    
    func setupUI() {
        view.backgroundColor = primaryColor
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.masksToBounds = true
    }
    
    func setupSearchField() {
        searchField.placeholder = "search"
        searchField.isTranslucent = true
        searchField.barTintColor = primaryColor
        searchField.searchTextField.textColor = .white
        searchField.backgroundColor = primaryColor
        self.tabBarController?.navigationItem.titleView = searchField
        
        searchField.delegate = self
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        
        let nib = UINib(nibName: "NoteCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func goToCreateNoteScreen() {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteVC
        vc.betterNoteManager = betterNoteManager
        
        vc.modalPresentationStyle = .fullScreen
        self.show(vc, sender: nil)
    }
    
}

//MARK: Setup functions

extension HomeVC {
    
    func setupMenuButton() {
        menuButton.sizeToFit()
        setupMenuActions()
    }
    
    func toggleArchive() {
        toggleArchivedNotes = !toggleArchivedNotes
        collectionView.reloadData()
    }
    
    func toggleSecureNoteView() {
        toggleSecuredNotes = !toggleSecuredNotes
        collectionView.reloadData()
    }
    
    func deleteAllNotes() {
        betterNoteManager.clear()
        collectionView.reloadData()
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

//MARK: Button Actions
extension HomeVC {
    @IBAction func addButtonPressed(_ sender: Any) {
        goToCreateNoteScreen()
    }
}


//MARK: UIColor extension

extension UIColor {
    convenience init(hexaString: String, alpha: CGFloat = 1) {
        let chars = Array(hexaString.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]),nil,16))/255,
                  green: .init(strtoul(String(chars[2...3]),nil,16))/255,
                  blue:  .init(strtoul(String(chars[4...5]),nil,16))/255,
                  alpha: alpha)}
}

//MARK: Searchbar extension

extension HomeVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        collectionView.reloadData()
    }

}

//MARK: CollectionView delegates

extension HomeVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
            
        let sb = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteVC
        vc.betterNoteManager = betterNoteManager
        vc.noteID = notes[indexPath.row].id
        
        self.show(vc, sender: nil)
    }
        
    // longpress action on collectionviewcell
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let note = self.notes[indexPath.row]
        
        let pinAction: UIAction = {
            let title = note.isPinned ? "Unpin" : "Pin"
            let imageName = note.isPinned ? "pin.circle.fill" : "pin.circle"
            
            let image = UIImage(systemName: imageName)
            
            return UIAction(title: title, image: image) { _ in
                let shouldPin = !note.isPinned
                self.betterNoteManager.pinNote(id: note.id, pin: shouldPin)
                self.collectionView.reloadData()
            }
        }()
        
        let secureAction: UIAction = {
            let title = note.isSecured ? "Unsecure" : "Secure"
            let imageName = note.isSecured ? "lock.circle.fill" : "lock.circle"
            
            let image = UIImage(systemName: imageName)
            
            return UIAction(title: title, image: image) { _ in
                let shouldSecure = !note.isSecured
                self.betterNoteManager.secureNote(id: note.id, secure: shouldSecure)
                self.collectionView.reloadData()
            }
        }()
        
        let archiveAction = UIAction(title: "Archive", image: UIImage(systemName: "archivebox.circle")) { _ in
            let _archive = note.isArchived ? false : true
            self.betterNoteManager.archiveNote(id: note.id, archive: _archive)
            self.collectionView.reloadData()
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.circle")) { _ in
            self.betterNoteManager.deleteNote(id: note.id)
            self.collectionView.reloadData()
            self.backupNotes()
        }
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "",
                          image: nil,
                          identifier: nil,
                          options: UIMenu.Options.displayInline,
                          children: [pinAction,
                                     secureAction,
                                     archiveAction,
                                     deleteAction]
            )
        }
        
        return config
    }

}

//MARK: CollectionView datasource

extension HomeVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! NoteCell
        
        let note = notes[indexPath.row]
        let cellVM = NoteCellVM(note: note)
        cell.configure(viewModel: cellVM)
        cell.backgroundColor = secondaryColor
        cell.layer.cornerRadius = 16
        
        return cell
    }
    
}

//MARK: Read/Write from Disk
extension HomeVC {
    
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
                let notes = try JSONDecoder().decode([Note].self, from: data)
                betterNoteManager.addNotes(notes)
                collectionView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("error: unable to restore")
        }
    }
}

