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

	private var parentInstance:GameScene!
	
	public var type:String
	public var timer:Timer!
	private var timerCount:Int = 10 // длительность действия бонуса
	private var time_TF:SKLabelNode!
	public var weapon:Bool = false
	
	init(_ type:String, _ parentInstance: GameScene) {
		
		self.type = type
		self.parentInstance = parentInstance
		
		// перетягиваем данные о бонусе из словаря
		let str:String 	= Bonus.data[type]!["texture"] as! String
		timerCount 		= Bonus.data[type]!["duration"] as! Int
		weapon 			= Bonus.data[type]!["isWeapon"] as! Bool
	
		
		
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
			// по y спавним сверху (за пределами экрана)
			position.y = scene.size.height + size.height / 2
			
			let moveDown = SKAction.moveTo(y: 0, duration: 3)
			let removeAction = SKAction.removeFromParent()
			let sequence = SKAction.sequence([moveDown, removeAction])

			run(sequence, withKey: "bonusFly")
		}
	}
	
	
	
	
	public func runTimer(){
		
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRuningFunc), userInfo: nil, repeats: true)
		
		// лейбла оставшегося времени
		time_TF = SKLabelNode(text: timeFormatted(timerCount))
		//time_TF.calculateAccumulatedFrame().height - собственная высота лейбла
		// сверху слева - начало координат, пивоты по центру спрайта
		time_TF.position = CGPoint(x: 0, y: -frame.size.height - time_TF.frame.size.height / 2 - 10)
		time_TF.fontName = "Arial"
		time_TF.fontSize = 23
		time_TF.horizontalAlignmentMode = .center


		
		addChild(time_TF)
	}
	
	
	
	
	
	
	@objc private func timerRuningFunc(){
		
		timerCount -= 1
		if (timerCount == 0){
			timer.invalidate()
			fadeAnimation()
			return
		}
		let str:String = timeFormatted(timerCount)
//		print("time = \(str)")
		time_TF.text = str
		
	}
	
	
	
	
	
	///  Преобразовывает время в привычный формат "00:34"
	///
	/// - Parameter totalSeconds: кол-во секунд
	private func timeFormatted(_ totalSeconds: Int) -> String {
		
		//     let hours: Int = totalSeconds / 3600
		let minutes: Int = (totalSeconds / 60) % 60
		let seconds: Int = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
	
	
	private func fadeAnimation(){
		
		let fade = SKAction.scale(to: 0, duration: 0.5)
		fade.timingMode = .easeOut
		let remove = SKAction.run {
			// удаляем себя из массива
			self.parentInstance.takenFeatures = self.parentInstance.takenFeatures.filter{$0 != self}
			// выключаем бонус
			self.parentInstance.turnFeature(target: self, launching: false)
			self.removeFromParent()
		}
		
		let sequence = SKAction.sequence([fade, remove])
		
		self.run(sequence)
	}
	
	
	
	
	
	
	
	
	
	
}
