//
//  Drawable.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 02.03.2021.
//

import UIKit

protocol Drawable {
    var viewController: UIViewController? { get }
}

extension UIViewController: Drawable {
    var viewController: UIViewController? { return self }
}
