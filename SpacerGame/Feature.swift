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
	public var isWeapon:Bool = false
	public var weaponConf:Dictionary<String, Any>
	

	
	
	init(_ type:String, _ parentInstance: GameScene) {
		
		self.type = type
		self.parentInstance = parentInstance
		
		// перетягиваем данные о бонусе из словаря
		let str:String 	= Bonus.data[type]!["texture"] as! String
		timerCount 		= Bonus.data[type]!["duration"] as! Int
		isWeapon 		= Bonus.data[type]!["isWeapon"] as! Bool
		if (isWeapon) {
			weaponConf 	= Bonus.data[type]!["weaponConf"] as! Dictionary
		}
		else {
			weaponConf = ["0":0]
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
		if (time_TF != nil){
			return
		}
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
		
		if (timerCount == 2){
			// мигаем иконкой!
			flickering()
			if (type == Bonus.immortal){
				parentInstance.armorFlickering(true_false: true)
			}
		}
		else if (timerCount == 0){
			timer.invalidate()
			fadeOutAnimation()
			return
		}
		let str:String = timeFormatted(timerCount)
		time_TF.text = str
	}
	
	
	
	
	
	/// Мигание иконкой
	private func flickering(){
		
		let fadeOut = SKAction.fadeOut(withDuration: 0.3)
		let fadeIn = SKAction.fadeIn(withDuration: 0.3)
		
		let sequance = SKAction.sequence([fadeOut, fadeIn])
		let repeating = SKAction.repeatForever(sequance)
		
		self.run(repeating)
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
	
	
	
	/// Анимация исчезания бонуса
	private func fadeOutAnimation(){
		
		let fade = SKAction.scale(to: 0, duration: 0.5)
		fade.timingMode = .easeOut
		let remove = SKAction.run {
			// удаляем себя из массива
			self.parentInstance.takenFeatures = self.parentInstance.takenFeatures.filter{$0 != self}
			// выключаем бонус
			self.parentInstance.turnFeature(target: self, launching: false)
			self.parentInstance.resortIcons()
//			if (self.type == Bonus.immortal){
//				// выключаем бронь
//				self.parentInstance.armor(true_false: false)
//			}
			self.removeFromParent()
		}
		
		let sequence = SKAction.sequence([fade, remove])
		
		self.run(sequence)
	}
	
	
	

	
	
//	private func glowing(true_false arg:Bool){
//
//		if (arg){
//			let fadeToColor = SKAction.colorize(with: .orange, colorBlendFactor: 1, duration: 0.5)
//			let fadeToNone = SKAction.colorize(with: .orange, colorBlendFactor: 0.6, duration: 0.5)
//			let sequance = SKAction.sequence([fadeToColor, fadeToNone])
//			let repeating = SKAction.repeatForever(sequance)
//
//			parentInstance.spaceShip.run(repeating, withKey: "glowing")
//		}
//		else {
//			parentInstance.spaceShip.removeAction(forKey: "glowing")
//			parentInstance.spaceShip.run(SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.1)) // очищаем корабль от цвета (иногда остается)
//		}
//	}
	


	
	
	
//	// эффект свечения за счет блура копии текстуры, которая кладется под объект
//	private func glowing(true_false arg:Bool) {
//
//		if (arg){
//			let radius: Float = 10 // радиус размытия
//
//			let effectNode = SKEffectNode()
//			effectNode.shouldRasterize = true
//			parentInstance.spaceShip.addChild(effectNode)
//			let copyOfTexture = SKSpriteNode(texture: parentInstance.spaceShip.texture, color: .green, size: parentInstance.spaceShip.size)
//			copyOfTexture.xScale = 1.2
//			copyOfTexture.yScale = 1.2
//			copyOfTexture.run(SKAction.colorize(with: #colorLiteral(red: 1, green: 0.9880563072, blue: 0.1440601503, alpha: 1), colorBlendFactor: 1, duration: 0))
//
//			effectNode.addChild(copyOfTexture)
//			effectNode.blendMode = .add
//
//			effectNode.name = "effect"
//			effectNode.zPosition = 0
//			effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
//		}
//		else{
//			parentInstance.spaceShip.enumerateChildNodes(withName: "effect") {
//				(effect:SKNode, nil) in
//				effect.removeFromParent()
//			}
//		}
//	}
	
	

	
	
	
	
	
	
	
	
	
}
