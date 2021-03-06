//
//  AppDelegate.swift
//  SpacerGame
//
//  Created by Viacheslav on 08.07.18.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// задерживаем экран ланчскрина на 2 с
		sleep(1)
//		// прячем статусбар
//		application.isStatusBarHidden = true
		
        return true
    }

	
	
	// выход (1)
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		
		
		// запускаем экран паузы, если не произошел геймовер и если не включена пауза
		if !GameScene.selF.isGameOver && !GameScene.selF.isPaused{
			GameViewController.selF.onPP_Click(nil)
		}
	}
		
	

	// выход (2)
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

	// запуск (1)
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

	
	// запуск (2)
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		if (GameScene.selF != nil){
			perform(#selector(selectorFunc), with: self, afterDelay: 0.01) // т.к. пауза в SpriteKit отжимается автоматически после возврата в игру - включаем ее принудительно
		}
    }
	@objc private func selectorFunc(){
		GameScene.selF.pauseGame()
	}

	
	
	
	
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		GameScene.selF.pauseGame()
    }

	
	
	
	
	
	
	
	
	
	

}

