//
//  UIViewController+Extension.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 25/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//



import Foundation
import UIKit
import MBProgressHUD


extension UIViewController {
	func showProgressHUD() {
	   DispatchQueue.main.async {
		   let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
		   loadingNotification.label.text = "Loading.."
	   }
   }

   func hideProgressHUD() {
	   DispatchQueue.main.async {
		   MBProgressHUD.hide(for: self.view, animated: true)
	   }
   }
}

extension UIViewController {
	//Check for internet connection.
    func isNetworkAvailable()->Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard appDelegate?.networkStatus == true else {
			guard let topVC = UIApplication.topViewController() else {
				return false
			}
			topVC.presentAlert(withTitle: "Sorry", message: "No internet connection")
            return false
        }
        return true
    }
}

extension UIViewController {

    func presentAlert(withTitle title: String, message: String) {
        self.presentAlert(withTitle: title, message: message) {
        }
    }
    
    func presentAlert(withTitle title: String, message : String, actionHandler:@escaping ()->Void) {
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                actionHandler()
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentDefaultErrorAlert() {
        let title = "Sorry"
        let message = "Something went wrong, please try again later."
        self.presentAlert(withTitle: title, message: message)
    }

    
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
