//
//  NoteCell.swift
//  Notes
//
//  Created by Gourav Kumar on 24/01/22.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    static let cellIdentifier = "NoteCell"

    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    
    @IBOutlet var containerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 40)])
        
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "NoteCell", bundle: nil)
    }
    
    func configure(viewModel: NoteCellVM) {
        headingLabel.text = viewModel.noteTitle
        contentLabel.text = viewModel.noteContent
        dateLabel.text = viewModel.modifiedDateText
        
        pinImageView.isHidden = !viewModel.isPinned
    }    
}

