//
//  AlertManager.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 04.03.2021.
//

import UIKit

public class Alert: UIViewController {
    
    public static func presentAlert(title: String, message: String, vc: UIViewController) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(ok)
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
}
