//
//  NoteElementCell.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 05.03.2021.
//

import UIKit

class NoteElementCell: CustomElementModel {
    var image: UIImage?
    var username: String?
    var noteImage: UIImage?
    
    var type: CustomElementType { return .note }
    
    init(image: UIImage?, username: String, noteImage: UIImage) {
        self.image = image
        self.username = username
        self.noteImage = noteImage
    }
}
