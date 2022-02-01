//
//  NewHomeViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 24/01/22.
//

import UIKit

class NewHomeViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var menuButton: UIButton!
    
    
    let primaryColor = UIColor(hexaString: "#08070D")
    
    @IBOutlet var collectionView: UICollectionView!
    
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
    
    func goToCreateNoteScreen() {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        vc.betterNoteManager = betterNoteManager
        
        vc.modalPresentationStyle = .fullScreen
        self.show(vc, sender: nil)
    }
    
}

//MARK: Setup functions

extension NewHomeViewController {
    func setupUI() {
        view.backgroundColor = primaryColor
        
        collectionView.backgroundColor = .clear
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.masksToBounds = true
    }
    
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
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 400, height: 150)
        
        collectionView.collectionViewLayout = layout
        collectionView.register(NoteCollectionViewCell.nib(), forCellWithReuseIdentifier: NoteCollectionViewCell.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
}

//MARK: Button Actions
extension NewHomeViewController {
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

extension NewHomeViewController: UISearchBarDelegate {

    @IBAction func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        collectionView.reloadData()
    }

}

//MARK: CollectionView delegates

extension NewHomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
            
        let sb = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "addNoteVC") as! AddNoteViewController
        vc.betterNoteManager = betterNoteManager
        vc.noteID = notes[indexPath.row].id
        
        self.show(vc, sender: nil)
    }
}

//MARK: CollectionView datasource

extension NewHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.cellIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        let note = notes[indexPath.row]
        let cellVM = NoteCollectionViewCellVM(note: note)
        cell.configure(viewModel: cellVM)
        
        cell.layer.cornerRadius = 20
        cell.backgroundColor = UIColor(hexaString: "#202240")
        
        return cell
    }
    
}


extension NewHomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 400, height: 150)
    }
}

//MARK: Read/Write from Disk
extension NewHomeViewController {
    
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
                collectionView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("error: unable to restore")
        }
    }
}

