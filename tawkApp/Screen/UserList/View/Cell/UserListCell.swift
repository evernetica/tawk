//
//  UserListCell.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 05.03.2021.
//

import UIKit
import Combine

class UserListCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

