//
//  Note.swift
//  Notes
//
//  Created by Gourav Kumar on 02/02/22.
//

import Foundation

struct Note: Codable {
    let id: UUID
    var title: String?
    var content: String?
    
    var isPinned: Bool
    var isSecured: Bool
    var isArchived: Bool
    
    let dateCreated: Date
    var dateModified: Date
    
    init?(id: UUID = UUID(), title: String? = nil, content: String? = nil, isPinned: Bool = false, isSecured: Bool = false, isArchived: Bool = false, dateCreated: Date = Date(), dateModified: Date = Date()) {
        if title == nil, content == nil {
            return nil
        }
        
        self.id           = id
        self.title        = title
        self.content      = content
        self.isPinned     = isPinned
        self.isSecured    = isSecured
        self.isArchived   = isArchived
        self.dateCreated  = dateCreated
        self.dateModified = dateModified
    }
}
