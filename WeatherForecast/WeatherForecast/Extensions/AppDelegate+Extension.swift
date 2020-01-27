//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 25/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import Foundation
import UIKit


extension AppDelegate {

	func configureWindow() {
		let window = UIWindow(frame: UIScreen.main.bounds)

		let tabbarController = setupTabBar()
		window.rootViewController = tabbarController
		window.makeKeyAndVisible()

		self.window = window
	}

	func setupTabBar()->UITabBarController {
		let tabbar = UITabBarController()

		let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
		let homeNavController = UINavigationController(rootViewController: homeVC)
		homeNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)

		let othersVC = OthersViewController(nibName: "OthersViewController", bundle: nil)
		let othersNavController = UINavigationController(rootViewController: othersVC)
		othersNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)

		tabbar.viewControllers = [homeNavController, othersNavController]

		return tabbar
	}


	//Network Status
	func startReachability() {
		self.reachability.whenReachable = { reachability in
			// this is called on a background thread, but UI updates must
			// be on the main thread, like this:
			self.networkStatus = true
			NotificationCenter.default.post(name: Notification.Name(rawValue: "NetworkStatusChanged"), object: nil)
		}
		self.reachability.whenUnreachable = { reachability in
			// this is called on a background thread, but UI updates must
			// be on the main thread, like this:
			self.networkStatus = false
			NotificationCenter.default.post(name: Notification.Name(rawValue: "NetworkStatusChanged"), object: nil)
		}

		do {
			try self.reachability.startNotifier()
		} catch {
			print("Unable to start notifier")
		}
	}



}
