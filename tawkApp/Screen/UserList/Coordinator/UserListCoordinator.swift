//
//  UserListCoordinator.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 02.03.2021.
//

import UIKit
import Combine

class UserListCoordinator: BaseCoordinator {
    
    let router: RouterProtocol
    var controller: UserListViewController
    private var subscriptions = Set<AnyCancellable>()
    
    init(router: RouterProtocol, viewModel: UserListViewModel ) {
        self.router = router
        self.controller = UserListViewController(viewModel: viewModel)
    }
    
    override func start() {
        controller.viewModel.$selectUserName.sink { [weak self] userName in
            if !userName.isEmpty {
            self?.showUserDetails(userName: userName)
            }
        }
        .store(in: &subscriptions)
        
    }
    
    private func showUserDetails(userName: String) {
        let coordinator = UserDetailsCoordinator(router: router, userName: userName)
        coordinator.start()
        self.store(coordinator: coordinator)
        
        router.push(coordinator, isAnimated: true) { [weak self, weak coordinator] in
            guard let strongSelf = self, let coordinator = coordinator else { return }
            strongSelf.free(coordinator: coordinator)
        }
    }
}

extension UserListCoordinator: Drawable {
    var viewController: UIViewController? { return controller }
}
