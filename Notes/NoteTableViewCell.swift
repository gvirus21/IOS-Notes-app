//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by Gourav Kumar on 22/12/21.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    @IBOutlet var heading: UILabel!
    @IBOutlet var content: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
    }
}
