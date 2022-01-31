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
    
    
    static let primaryColor = UIColor(hexaString: "#08070D")
    
    @IBOutlet var collectionView: UICollectionView!
    
    var toggleSecuredNotes = true
    var toggleArchivedNotes = false
    
    var betterNoteManager = BetterNoteManager()
    
    var notes: [BetterNote] {
        let notes = betterNoteManager.getAllNotes(searchTerm: searchField.text)
        print("notes: \(notes)")
        
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
        setupSearchField()
        setupCollectionView()
        restoreNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        print("appered")
        print(notes)
    }

    func setupUI() {
        view.backgroundColor = Self.primaryColor
        
        collectionView.backgroundColor = .clear
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.masksToBounds = true
    }
    
    func setupSearchField() {
        let primaryColor = UIColor(hexaString: "#08070D")

        searchField.placeholder = "search"
        searchField.isTranslucent = true
        searchField.barTintColor = primaryColor
        searchField.searchTextField.textColor = .white
        searchField.backgroundColor = primaryColor
        self.tabBarController?.navigationItem.titleView = searchField
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 400, height: 150)
        
        collectionView.collectionViewLayout = layout
        collectionView.register(NoteCollectionViewCell.nib(), forCellWithReuseIdentifier: NoteCollectionViewCell.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
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

//MARK: CollectionView delegates

extension NewHomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
    }
}

//MARK: CollectionView datasource

extension NewHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(notes)
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

