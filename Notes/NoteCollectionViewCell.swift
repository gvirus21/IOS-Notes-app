//
//  NoteCollectionViewCell.swift
//  Notes
//
//  Created by Gourav Kumar on 24/01/22.
//

import UIKit

struct NoteCollectionViewCellVM {
    let note: BetterNote
    
    var noteTitle: String { note.title ?? "" }
    var noteContent: String { note.content ?? "" }
    var modifiedDateText: String { "Jan 1, 1970" }
}

class NoteCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "NoteCollectionViewCell"
    
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pinLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "NoteCollectionViewCell", bundle: nil)
    }
    
    func configure(viewModel: NoteCollectionViewCellVM) {
        headingLabel.text = viewModel.noteTitle
        contentLabel.text = viewModel.noteContent
        dateLabel.text = viewModel.modifiedDateText
    }    
}
