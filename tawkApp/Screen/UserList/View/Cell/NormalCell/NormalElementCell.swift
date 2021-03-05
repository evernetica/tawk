//
//  NormalElementCell.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 05.03.2021.
//

import UIKit

class NormalElementCell: CustomElementModel {
    
    var userName: String?
    var avatarUrl: String?
    var id: Int?
    var isOpen: Bool?
    var noteText: String?
    var type: CustomElementType { return .normal}
    
    init(model: User) {
        userName = model.login
        avatarUrl = model.avatarUrl
        isOpen = model.isOpen
        noteText = model.note?.noteText
        id = Int(model.id)
    }
    
}
