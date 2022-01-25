//
//  NoteCollectionViewCell.swift
//  Notes
//
//  Created by Gourav Kumar on 24/01/22.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "NoteCollectionViewCell"
    
    @IBOutlet var heading: UILabel!
    @IBOutlet var content: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var pinLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure() {

    }
    
    static func nib() -> UINib {
        
        return UINib(nibName: "NoteCollectionViewCell", bundle: nil)
    }
    
}
