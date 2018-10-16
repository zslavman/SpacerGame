//
//  Enemy.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 07.09.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit
import SpriteKit

class Enemy: SKSpriteNode {

	let enemyTexture = SKTexture(imageNamed: "enemySpaceship")
	init() {
		let scale = CGSize(width: enemyTexture.size().width / 1.5, height: enemyTexture.size().height / 1.5)
		super.init(texture: enemyTexture, color: .red, size: scale)
		
		// для столкновений необходимо создать физическое тело кораблю врага
		// физическое тело задается ТОЛЬКО после установки текстуры и ее размера, иначе оно будет не соответствовать
		physicsBody = SKPhysicsBody(texture: enemyTexture, size: enemyTexture.size())
		
		// принебрегаем воздействием гравитации
		physicsBody?.affectedByGravity 	= false
		// отключаем вращение (при ударении)
		physicsBody?.allowsRotation 	= false
		
		physicsBody?.categoryBitMask 	= Collision.ENEMY_SHIP 						// устанавливаем битмаску столкновений
		physicsBody?.contactTestBitMask = Collision.PLAYER_SHIP | Collision.LASER 	// от каких столкновений хотим получать уведомления (триггер столкновений)
		physicsBody?.collisionBitMask 	= Collision.ASTEROID | Collision.LASER		// при каких столкновениях мы хотим чтоб корабль вел себя как физическое тело
		
	}
	

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	public func fly() {
		
		if let scene = scene {
			let randomX = CGFloat(arc4random_uniform(UInt32(scene.size.width - size.width))) + size.width / 2
			position.x = randomX
			// по y спавним корабли сверху (за пределами экрана)
			position.y = scene.size.height + size.height / 2
			
			let wagDistance = GameScene.random(50, 200)
			
			// движения
			let moveDown = SKAction.moveBy(x: 0, y: -100, duration: 1.2)
			let moveLeft = SKAction.moveBy(x: CGFloat(-wagDistance), y: 0, duration: 1.2)
			let moveRight = SKAction.moveBy(x: CGFloat(wagDistance), y: 0, duration: 2.2)
			
			// сглаживаем движения влево, вправо
			moveLeft.timingMode = SKActionTimingMode.easeInEaseOut
			moveRight.timingMode = SKActionTimingMode.easeInEaseOut
			
			let wagMovment = SKAction.sequence([moveLeft, moveRight])
			let repeatWag = SKAction.repeatForever(wagMovment)
			
			let repeatMoveDown = SKAction.repeatForever(moveDown)
			
			let groupMovment = SKAction.group([repeatWag, repeatMoveDown])
			
			run(groupMovment)
			
		}
	}

	
	
	
	
	
	
	
	
	
	
	
	
	
}
