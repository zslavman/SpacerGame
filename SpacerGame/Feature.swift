//
//  Feature.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 10.09.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit
import SpriteKit

class Feature: SKSpriteNode {


	init(_ type:String) {
		
		var str:String = ""
		
		switch type {
		case "health":
			str = "feature_live"
		case "immortal":
			str = "feature_immortal"
		case "red_laser":
			str = "feature_red_laser"
		case "green_laser":
			str = "feature_green_laser"
		default:
			()
		}
		
		
		let thisTexture = SKTexture(imageNamed: str)
		
		super.init(texture: thisTexture, color: .red, size: thisTexture.size())
		
		self.xScale = 0.5
		self.yScale = 0.5
		
		// для столкновений необходимо создать физическое тело кораблю врага
		// физическое тело задается ТОЛЬКО после установки текстуры и ее размера, иначе оно будет не соответствовать
		physicsBody = SKPhysicsBody(texture: thisTexture, size: thisTexture.size())
		
		// принебрегаем воздействием гравитации
		physicsBody?.affectedByGravity 	= false
		// отключаем вращение (при ударении)
		physicsBody?.allowsRotation 	= false
		
		physicsBody?.categoryBitMask 	= Collision.FEATURE 		// устанавливаем битмаску столкновений
		physicsBody?.contactTestBitMask = Collision.PLAYER_SHIP		// от каких столкновений хотим получать уведомления (триггер столкновений)
		physicsBody?.collisionBitMask 	= Collision.NONE			// при каких столкновениях мы хотим чтоб фича вел себя как физическое тело
	
	}
	
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	public func fly(){
		
		if let scene = scene {
			
			position.x = CGFloat(arc4random_uniform(UInt32(scene.size.width - size.width))) + size.width / 2
			print("Координаты подарка: \(position.x)")
			// по y спавним сверху (за пределами экрана)
			position.y = scene.size.height + size.height / 2
			
			let moveDown = SKAction.moveTo(y: 0, duration: 3)
			let removeAction = SKAction.removeFromParent()
			let sequence = SKAction.sequence([moveDown, removeAction])

			run(sequence)
			
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
