//
//  NewHomeViewController.swift
//  Notes
//
//  Created by Gourav Kumar on 24/01/22.
//

import UIKit

class NewHomeViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
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
        title = "Notes"
        
        setupUI() 
        setupCollectionView()
    }
    
    func setupUI() {
        let primaryColor = UIColor(hexaString: "#082032")
        view.backgroundColor = primaryColor
        
        collectionView.backgroundColor = .clear
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.masksToBounds = true
    }
    
    func setupCollectionView() {
        
        let layout = UICollectionViewLayout()
 //     layout.itemSize = CGSize(width: 200, height: 200)
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(NoteCollectionViewCell.nib(), forCellWithReuseIdentifier: NoteCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
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

extension NewHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.identifier, for: indexPath) as! NoteCollectionViewCell
        return cell
    }
    
}

extension NewHomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 200, height: 200)
    }
}
