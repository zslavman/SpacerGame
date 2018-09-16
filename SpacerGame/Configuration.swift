//
//  Configuration.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 15.09.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit

class Configuration: UIViewController {

	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }


	
	/// Прячем статусбар
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	@IBAction func onBackClick(_ sender: UIButton) {

		// удаляем текущий вьюконтроллер
		self.dismiss(animated: true){
			// обновляем вьюшку PauseView
			let topController = self.getTopController() as! GameViewController // т.к. PauseView открыт модально, он не является presentedViewController
			topController.pauseView.opened = true
			topController.pauseView.update()
		}
		// 1)
//		let storyBoard = UIStoryboard(name: "Main", bundle:nil)
//		let resultViewController = storyBoard.instantiateViewController(withIdentifier: "gvc") as! GameViewController
//		self.present(resultViewController, animated:true){
//			// обновляем вьюшку PauseView
//			// resultViewController.viewDidLayoutSubviews()
//			resultViewController.pauseView.TTT()
//		}

		// 2) удаляет из стека только текущий вьюконтр
//		presentedViewController?.dismiss(animated: true, completion: {
//			print("successful dismissed")
//		})
		
		// 3) очищает весь стек вьюшек приложения
//		presentingViewController?.dismiss(animated: true, completion: {
//			print("successful dismissed")
//		})
	}
	
	
	/// Ищем активную вьюшку
	private func getTopController() -> UIViewController {
		
		var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
		while (topController.presentedViewController != nil) {
			topController = topController.presentedViewController!
		}
		return topController
	}
	
	
	
	
	
	
	
	
	


}
