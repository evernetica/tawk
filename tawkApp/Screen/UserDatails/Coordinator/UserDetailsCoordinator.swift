//
//  UserDetailsCoordinator.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 04.03.2021.
//

import UIKit

class UserDetailsCoordinator: BaseCoordinator {
    
    let router: RouterProtocol
    var controller: UserDetailsViewController
    
    init(router: RouterProtocol, userName: String) {
        self.router = router
        let viewModel = UserDetailsViewModel(userName: userName)
        self.controller = UserDetailsViewController(viewModel: viewModel)
    }
    
    override func start() {
        
    }
  
}

extension UserDetailsCoordinator: Drawable {
    var viewController: UIViewController? { return controller }
}
