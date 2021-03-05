//
//  BaseCoordinator.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 02.03.2021.
//

import Foundation

protocol Coordinator: class {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func store(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        debugPrint("STORE \(String(describing: coordinator))")
        
    }
    
    func free(coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        debugPrint("FREE \(String(describing: coordinator))")
    }
}

class BaseCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var isCompleted: NavigationBackClosure?
    
    func start() {
        fatalError("Children should implement `start`.")
    }
    
    deinit {
        debugPrint("DEINITED \(String(describing: self))")
    }
}
