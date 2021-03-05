//
//  UserViewModel.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 05.03.2021.
//

import UIKit

extension UserViewModel {
    enum CustomElementType: String {
        case normal
        case note
        case open
    }
}

class UserViewModel {
    var userName: String?
    var avatarUrl: String?
    var id: Int?
    var isOpen: Bool?
    var noteText: String?
    var type: CustomElementType
    
    init(model: User) {
        userName = model.login
        avatarUrl = model.avatarUrl
        isOpen = model.isOpen
        noteText = model.note?.noteText
        id = Int(model.id)
        type = .normal
        
        if noteText != "" && noteText != nil {
            type = .note
        } else {
            type = .normal
        }
    }
}
