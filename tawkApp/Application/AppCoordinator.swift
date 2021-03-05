//
//  AppCoordinator.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 02.03.2021.
//

import UIKit

class AppCoordinator: BaseCoordinator {
    
    let window: UIWindow
    
    init(_ window: UIWindow) {
        self.window = window
        super.init()
    }
    
    override func start() {
        childCoordinators = []
        let navigationController = UINavigationController()
        let router = Router(navigationController: navigationController)
        let viewModel = UserListViewModel()
        let coordinator = UserListCoordinator(router: router, viewModel: viewModel)
        
        store(coordinator: coordinator)
        coordinator.start()
        
        router.push(coordinator, isAnimated: true) { [weak self, weak coordinator] in
            guard let strongSelf = self, let coordinator = coordinator else { return }
            strongSelf.free(coordinator: coordinator)
        }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
}
