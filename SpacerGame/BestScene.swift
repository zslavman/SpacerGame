//
//  BestScene.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 16.10.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import SpriteKit
import UIKit

class BestScene: SKScene { // отключена

	
	override func didMove(to view: SKView) {
		
		self.backgroundColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1).withAlphaComponent(0.7)

		// кн. возврата на предыдущий экран
		let back = ButtonNode(titled: "back", backgroundSize: CGSize(width: 150, height: 50))
		back.position = CGPoint(x: self.frame.midX, y: 150)
		back.name = "back"
		back.label.name = "back"
		addChild(back)
	}
		
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let location = touches.first!.location(in: self)
		let node = atPoint(location)
		
		// после твина появления экрана возвращается сюда обратно!!!!
		if node.name == "back"{
			self.removeFromParent()
			GameViewController.selF.showXScreen(GameViewController.selF.gameOverView)
		}
	}
	
	
	
}
