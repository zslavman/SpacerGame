//
//  GameScene.swift
//  SpacerGame
//
//  Created by Viacheslav on 08.07.18.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

// для передачи очков из этого класса в GameOverView
protocol PGameDelegate {
	func gameDelegateDidUpdateScore(score:Int)
	func gameDelegateGameOver(score:Int) // будет передавать очки
	func gameDelegateReset()
	
	func gameDelegateDidUpdateLives()
}

// для доступа извне определяем битовые маски через struct/enum
struct Collision {
	public static let NONE 			: UInt32 = 0
	public static let PLAYER_SHIP	: UInt32 = 0x1 << 0 // = 1
	public static let ASTEROID 		: UInt32 = 0x1 << 1 // = 2
	public static let ENEMY_SHIP 	: UInt32 = 0x1 << 2 // = 4
	public static let LASER 		: UInt32 = 0x1 << 3 // = 8
	public static let FEATURE 		: UInt32 = 0x1 << 4 // = 16
}

// для использования энума, необходимо в конце добавлять rawValue, например:  ... = Collision.PLAYER_SHIP.rawValue
//enum Collision: UInt32 { // кейсы - степени 2-ки начиная с 0-вой степени
//	case NONE			= 1
//	case PLAYER_SHIP 	= 2
//	case ASTEROID		= 4
//	case ENEMY_SHIP		= 8
//}


struct Bonus {
	public static let health:String 		= "health"
	public static let immortal:String 		= "immortal"
	public static let red_laser:String 		= "red_laser"
	public static let green_laser:String 	= "green_laser"
	
	public static let allFeatures = [  		// все виды выпадающей амуниции
		Bonus.health,
		Bonus.immortal,
		Bonus.red_laser,
		Bonus.green_laser
	]
	
	public static let data:Dictionary = [
		red_laser:[
			"duration"	: 10,
			"texture"	: "feature_red_laser",
			"type"		: "red_laser",
			"isWeapon"	: true,
			"weaponConf":[
				"fireRate"		: 0.1,
				"bulet_speed"	: 0.5,
				"bulet_texture"	:"redLaser",
				"sound"			: "red_laser_sound"
			]
		],
		green_laser:[
			"duration"	: 15,
			"texture"	: "feature_green_laser",
			"type"		: "green_laser",
			"isWeapon"	: true,
			"weaponConf":[
				"fireRate"		: 0.8,
				"bulet_speed"	: 0.3,
				"bulet_texture"	:"greenLaser",
				"sound"			: "rail_gun"
			]
		],
		immortal:[
			"duration"	: 15,
			"texture"	: "feature_immortal",
			"type"		: "immortal",
			"isWeapon"	: false,
			"weaponConf": []
		],
		health:[
			"duration"	: 0,
			"texture"	: "feature_live",
			"type"		: "health",
			"isWeapon"	: false,
			"weaponConf": []
		]
	]
	
	
}




class GameScene: SKScene, SKPhysicsContactDelegate {

	
	public var pgameDelegate:PGameDelegate? // делегат протокола PGameDelegate
    public var soundChanel:AVAudioPlayer!
	private var spaceShipOnFinger:Bool = false // флаг, что тач прикоснувшись попали на корабль
	public var settings: Settings!
	
	
    public var spaceShip:SKSpriteNode!
    private let w 							= UIScreen.main.bounds.size.width
    private let h							= UIScreen.main.bounds.size.height

    private let ship_speed:CGFloat			= 600 // поинтов в секунду
	

    private var _score:Int					= 0
	private var gameFinished:Bool			= false // gameOver

	private var motionManager: CMMotionManager!
	private var asteroidLayer:SKNode = SKNode() // слой астероидов
	private var dY_lean_correction:Double	= 0.4// коррекция на наклон устройства

	private var lastTouchCoords:CGPoint 	= CGPoint.zero 	// тут будут координаты корабля в момент касания = начало координат

    // мигание корабля
    private var _flashingShip:Bool    = false
    private var colorActionRepeat:SKAction!
    public var flashingShip:Bool {
        get {
            return _flashingShip
        }
        set {
            if newValue {
                if (!_flashingShip){
                    _flashingShip = true
                    spaceShip.run(colorActionRepeat, completion: {
                        self._flashingShip = false
                    })
                }
            }
            else {
                spaceShip.removeAllActions()
                _flashingShip = false
            }
        }
	}
	
    
	public var takenFeatures:Array<Feature> = [] 			// массив взятых финтиклюшек (жизнь сюда не входит)
	public var activeWeapon:Feature! 						// тут будет храниться активное оружие
	private var weaponTimer:Timer!
    private let backingContainer = SKNode()					// контейнер для фонов
	private var starsEmitter:SKEmitterNode!					// слой звезд

	private var playerImmortable:Bool 		= false 		// неуязвимость
	private var asteroidDestructible:Bool 	= true 			// астероиды разрушаются лазером
	
	
	public static var selF:GameScene!
	
	public static var music_flag:Bool			= true
	public static var sound_flag:Bool			= true
	public static var accelerometer_flag:Bool 	= false
	public static var god_flag:Bool 			= false
	public static var asterPerSecond:Double		= 3 				// кол-во астероидов в сек
	public static var enemySpawnInterval:TimeInterval		= 6
	public static var featureSpawnInterval: TimeInterval 	= 12

	
	
    override func didMove(to view: SKView) {
		
		enemySpawn()
		featureSpawn()
		asteroidSpawn()
		
        // любой рандомайзер всегда на что-то операется, в данном случае на время, потому при каждом запуске оно будет разное
        srand48(time(nil)) // "для того чтоб сид был разный"
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8) // гравитация - вектор, направленный сверху-вниз с ускорением -9,8

		// бэкграунг сцены
		addChild(backingContainer)
		backingContainer.position = CGPoint(x: frame.midX, y: frame.midY)
		// бэк1
        let stageBacking1 = SKSpriteNode(imageNamed: "background")
        backingContainer.addChild(stageBacking1)
		// бэк2
		let stageBacking2 = SKSpriteNode(imageNamed: "background")
		stageBacking2.position.y = stageBacking2.size.height
		backingContainer.addChild(stageBacking2)
		// экшн который будет их двигать
		let offsetPosY:Int = Int(abs((stageBacking2.size.height - self.frame.size.height) / 2) + 1)
		print("offsetPosY = \(offsetPosY)")
		let moveDown = SKAction.moveTo(y: -stageBacking2.size.height + CGFloat(offsetPosY), duration: 10)
		let startPos = SKAction.run {
			self.backingContainer.position.y = CGFloat(offsetPosY)
		}
		
		let seq = SKAction.sequence([moveDown, startPos])
		let repeatAct = SKAction.repeatForever(seq)
		backingContainer.run(repeatAct)
		
		
		
        // создаем слой звезд
        let starsPath:String = Bundle.main.path(forResource: "stars", ofType: "sks")!
		starsEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: starsPath) as! SKEmitterNode
        starsEmitter.particlePositionRange.dx = frame.size.width
        starsEmitter.advanceSimulationTime(20) // сколько должна уже идти симуляция до запуска приложения
		starsEmitter.position = CGPoint(x: frame.midX, y: frame.size.height) // странное размещение в симуляторе слоев, но иначе не работает
		addChild(starsEmitter)
		
        // космич. корабль
        spaceShip = SKSpriteNode(imageNamed: "picSpaceShip")
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false // гравитация не должна утягивать корабль вниз
        
        // определяем с кем корабль будет сталкиваться
        spaceShip.physicsBody?.categoryBitMask = Collision.PLAYER_SHIP
        spaceShip.physicsBody?.collisionBitMask = Collision.ASTEROID
        spaceShip.physicsBody?.contactTestBitMask = Collision.ASTEROID // на что мы должны получать уведомление
        spaceShip.name = "personage"
        addChild(spaceShip)
        
        // левый двигатель
        let enginePath:String = Bundle.main.path(forResource: "fireParticles", ofType: "sks")!
        let engine1 = NSKeyedUnarchiver.unarchiveObject(withFile: enginePath) as! SKEmitterNode
        engine1.advanceSimulationTime(5)
        spaceShip.addChild(engine1)
        engine1.position = CGPoint(x: -28, y: -spaceShip.frame.height/2 + 5)
        engine1.zPosition = spaceShip.self.zPosition - 1
        
        // правый двигатель
        let engine2 = NSKeyedUnarchiver.unarchiveObject(withFile: enginePath) as! SKEmitterNode
        engine2.advanceSimulationTime(5)
        spaceShip.addChild(engine2)
        engine2.position = CGPoint(x: 28, y: -spaceShip.frame.height/2 + 5)
        engine2.zPosition = spaceShip.self.zPosition - 1
//        engine2.targetNode = self // оставляет шлейф за огнем
        
		backingContainer.zPosition = 0
//        stageBacking.zPosition = 0
        starsEmitter.zPosition = 1
        spaceShip.zPosition = 2

		
		// так не работает отслеживание вылета за экран!!!
		// addChild(asteroidLayer)
		// self.asteroidLayer.zPosition = 2
		
        
        // запускаем считывание акселерометра
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.15
        motionManager.startAccelerometerUpdates()
        
        
        // для мигания корабля
        let colorAct1 = SKAction.colorize(with: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), colorBlendFactor: 1, duration: 0.2)
        let colorAct2 = SKAction.colorize(with: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), colorBlendFactor: 0, duration: 0.2)
        let colorSequenceAnimation = SKAction.sequence([colorAct1, colorAct2])
        colorActionRepeat = SKAction.repeat(colorSequenceAnimation, count: 4)
		
		// проверяем, включена ли музыка
		let s_flag = UserDefaults.standard.object(forKey: "music")
		GameScene.music_flag = (s_flag == nil) ? true : s_flag as! Bool
		// проверяем, включены ли звуки
		let m_flag = UserDefaults.standard.object(forKey: "sound")
		GameScene.sound_flag = (m_flag == nil) ? true : m_flag as! Bool
		
		resetGame()
		
        if GameScene.music_flag {
            playBackMusic()
        }
		GameScene.selF = self
    }
    
    
	
	
	
	/// Включение фоновой музыки
	private func playBackMusic(){
		let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "m4a")!
		soundChanel = try! AVAudioPlayer(contentsOf: musicURL, fileTypeHint: nil)
		soundChanel.numberOfLoops = -1
		soundChanel.volume = 0.08
		soundChanel.play()
	}
	
	
	
	
	// стрелялка лазером
	@objc func startFire(){
		
		if (activeWeapon == nil){
			return
		}
		
		let buletTexture = activeWeapon.weaponConf["bulet_texture"] as! String
		let buletSpeed = activeWeapon.weaponConf["bulet_speed"] as! Double
		
		
		let bulet = SKSpriteNode(imageNamed: buletTexture)
		bulet.zPosition = spaceShip.zPosition - 1
		bulet.xScale = 0.5
		bulet.yScale = 0.2
		bulet.name = "laser"
		
		bulet.position = CGPoint(x: spaceShip.position.x, y: spaceShip.position.y + 10)
		
		let moveAction = SKAction.move(by: CGVector(dx: 0, dy: self.frame.height + bulet.frame.height), duration: buletSpeed)
		let removeAction = SKAction.removeFromParent()
		let buletSequence = SKAction.sequence([moveAction, removeAction])
		
		addChild(bulet)
		
		// задаем физическое тело
		let laserTexture = SKTexture(imageNamed: buletTexture)
		bulet.physicsBody = SKPhysicsBody(texture: laserTexture, size: bulet.size)
		
		// принебрегаем воздействием гравитации
		bulet.physicsBody?.affectedByGravity 	= false
		bulet.physicsBody?.isDynamic 			= false
		
		bulet.physicsBody?.categoryBitMask 		= Collision.LASER 								// устанавливаем битмаску столкновений
		bulet.physicsBody?.contactTestBitMask 	= Collision.ENEMY_SHIP | Collision.ASTEROID 	// от каких столкновений хотим получать уведомления (триггер столкновений)
		
		if (buletTexture == "greenLaser"){
			let tailFile = Bundle.main.path(forResource: "rail_tail", ofType: "sks")!
			let tail = NSKeyedUnarchiver.unarchiveObject(withFile: tailFile) as! SKEmitterNode
			tail.position = CGPoint(x: 0, y: bulet.frame.height / 2)
			tail.zPosition = -1
			tail.targetNode = self
			tail.particleScale = 0.05
			tail.particleAlpha = 0.05
			bulet.addChild(tail)
		}
		
		bulet.run(buletSequence)
		playSound(activeWeapon.weaponConf["sound"] as! String)
		
	}
	
	
    

    public func resetGame(){
		
		spaceShip.removeAction(forKey: "gameOverSequance") // фикс обездвиженого корабля после ресета
		isPaused = false
		gameFinished = false
		if (settings != nil){
			settings.reset()
		}
		pgameDelegate?.gameDelegateReset()
		
		// удаляем все астероиды
		enumerateChildNodes(withName: "asteroid_out_marker") {
			(node:SKNode, nil) in
			node.removeFromParent()
		}
		// удаляем всех врагов
		enumerateChildNodes(withName: "enemy_clear_marker") {
			(node:SKNode, nil) in
			node.removeFromParent()
		}
		// удаляем все лазерные выстрелы
		enumerateChildNodes(withName: "laser") {
			(node:SKNode, nil) in
			node.removeFromParent()
		}
		
		if (weaponTimer != nil){
			weaponTimer.fire()
			weaponTimer.invalidate()
			activeWeapon = nil
		}
		
		spaceShip.position = CGPoint(x: w/2, y: spaceShip.frame.size.height/2 + 50)
	}

	
    
    public func pauseGame(){
		
		isPaused = true
        spaceShip.removeAction(forKey: "move")
        if (soundChanel != nil) {
            soundChanel.pause()
        }
		
		for value in takenFeatures{
			if value.timer != nil{
				value.timer.invalidate()
			}
		}
		
		if (activeWeapon != nil){
			weaponTimer.invalidate()
		}
		
	}
	
	
	
	
	
	/// Возврат к игре после отжатия паузы
	public func playGame(){
        if motionManager.accelerometerData != nil {
            dY_lean_correction = (motionManager.accelerometerData?.acceleration.y)!
        }
        print("dy_lean_correction = \(dY_lean_correction)")
        isPaused = false
        
        if (GameScene.music_flag){
            if (soundChanel != nil) {
                soundChanel.play()
            }
            else {
                playBackMusic()
            }
        }
		
		for value in takenFeatures{
			value.runTimer()
		}
		
		if (activeWeapon != nil){
			turnFeature(target: activeWeapon, launching: true)
		}
	}
	

	
	
	public func enemySpawn(){
		
		self.removeAction(forKey: "enemySpawn")
		
		let enemyAction = SKAction.run {
			let enemy = Enemy()
			enemy.zPosition = 2
			self.addChild(enemy)
			enemy.name = "enemy_clear_marker"
			enemy.fly()
		}
		
		let waitDuration = SKAction.wait(forDuration: GameScene.enemySpawnInterval, withRange: 3)
		let enemySequence = SKAction.sequence([enemyAction, waitDuration])
		let repeatSpawn	= SKAction.repeatForever(enemySequence)
		
		run(repeatSpawn, withKey: "enemySpawn")
	}
	
	
	
	
	
	public func featureSpawn(){
		
		self.removeAction(forKey: "featureSpawn")

		let featureAction = SKAction.run {
			let bonus = Feature(GameScene.randArrElemen(array: Bonus.allFeatures))
			bonus.zPosition = 2
			self.addChild(bonus)
			bonus.name = "enemy_clear_marker"
			bonus.fly()
		}

		let waitDuration = SKAction.wait(forDuration: GameScene.featureSpawnInterval, withRange: 2)
		let featureSequence = SKAction.sequence([featureAction, waitDuration])
		let repeatSpawn	= SKAction.repeatForever(featureSequence)
		
		run(repeatSpawn, withKey: "featureSpawn")
	}
	
	
	
	
	
	// генерируем астероиды
	public func asteroidSpawn(){
		
		self.removeAction(forKey: "asteroidRunAction")
		
		let asteroidCreateAction = SKAction.run {
			let asteroid = self.createAsteroid()
			asteroid.zPosition = 2
			self.addChild(asteroid)
		}
		
		let asteroidCreationDelay = SKAction.wait(forDuration: 1.0 / GameScene.asterPerSecond, withRange: 0.5)
		let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction, asteroidCreationDelay])
		let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
		
		// запускаем всю эту шнягу
		run(asteroidRunAction, withKey: "asteroidRunAction")
	}
	
	
	
	
	
    

    
    // клик по экрану
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first, !isPaused, !gameFinished {
            let touchLocation = touch.location(in: self)
            
//            let dist = distanceCalc(a: spaceShip.position, b: touchLocation)
//            let time = timeToTravelDistance(distance: dist, speed: ship_speed)
//
//            let moveAction = SKAction.move(to: touchLocation, duration: time)
//
//            // добавим релистичности движения корабля (плавный старт и остановка)
//            moveAction.timingMode = .easeInEaseOut
//
//            spaceShip.run(moveAction, withKey: "move")
//
//            // экшн-параллакс эффект при движении корабля (100 - в 100 раз меньше движения корабля)
//            let bgMoveAction = SKAction.move(to: CGPoint(x: -touchLocation.x / 10, y: -touchLocation.y / 10), duration: time)
//            stageBacking.run(bgMoveAction)
//            starsLayer.run(bgMoveAction)
			
			// если тыкнули по кораблю
			if (atPoint(touchLocation) == spaceShip) {
				// коррекция дёргания при косании
				lastTouchCoords = touchLocation
				
				// чтоб палец не закрывал корабль
				let sTouch = touch.location(in: spaceShip)
				if (sTouch.y >= -10){
					let newY = touchLocation.y + spaceShip.frame.height / 2
					let newX = touchLocation.x
					let corectionAct = SKAction.move(to: CGPoint(x: newX, y: newY), duration: 0.1)
					spaceShip.run(corectionAct, withKey: "corectionAct")
				}
				spaceShipOnFinger = true
			}
		}
    }
	
	
	
	// таскание нашего корабля пальцем
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first, !isPaused, !gameFinished {
			let touchLocation = touch.location(in: self)
			if (spaceShipOnFinger){
				let translation = CGPoint(x: touchLocation.x - lastTouchCoords.x, y: touchLocation.y - lastTouchCoords.y)
				spaceShip.position.x += translation.x
				spaceShip.position.y += translation.y
				
				// параллакс для фона
				backingContainer.position.x -= translation.x / 8
				
				// параллакс для звезд
				starsEmitter.position.x -= translation.x / 12
				
				lastTouchCoords = touchLocation
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		spaceShip.removeAction(forKey: "corectionAct")
		spaceShipOnFinger = false
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		spaceShip.removeAction(forKey: "corectionAct")
		spaceShipOnFinger = false
	}
    
    
    
    // создаем астероид
    private func createAsteroid() -> SKSpriteNode{
        
        let asterSkinsArray:Array = ["asteroid", "asteroid2"]
        
		let randomIndex = GameScene.random(0, asterSkinsArray.count - 1)
        
        let asteroid = SKSpriteNode(imageNamed: asterSkinsArray[randomIndex])
        asteroid.position.x = CGFloat(arc4random()).truncatingRemainder(dividingBy: frame.size.width) // truncatingRemainder - равносильно остатку "%"
        asteroid.position.y = frame.size.height + asteroid.size.height
        
		let randFloat = CGFloat(Float(GameScene.random(3, 5)) / 10.0)

        asteroid.setScale(randFloat)
        
        // назначаем астероиду физическое тело для взаимодействия. Метод ниже определяет физ.тело на основе прозрачности слоя
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.name = "asteroid_out_marker" // дали имя для отлавливания вылета за сцену
        
        asteroid.physicsBody?.categoryBitMask = Collision.ASTEROID
        asteroid.physicsBody?.collisionBitMask = Collision.PLAYER_SHIP | Collision.ASTEROID | Collision.ENEMY_SHIP // астероид может сталкиваться с кораблем и с астероидами
        asteroid.physicsBody?.contactTestBitMask = Collision.PLAYER_SHIP
        
        // добавим угловой скорости астероиду (рад/с)
        asteroid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3 // в итоге итерация будет в диапазоне [-1 ; 1] * 3
        let speedX:CGFloat = 100.0
        asteroid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * speedX
        // вращение вокруг собственной оси
        asteroid.physicsBody?.angularDamping = CGFloat(drand48() * 2 - 1)
        
        return asteroid
    }
    
	
	
	
    // метод, срабатываемый после просчета физики в каждом кадре ENTERFRAME
    // метод перебирает все ноды сцены c указанным именем;
    // stop - прекращает работу метода/перебора нодов
    override func didSimulatePhysics() {
		
		// убиваем астероиды
        enumerateChildNodes(withName: "asteroid_out_marker") {
            (node:SKNode, nil) in
			
            if node.position.y < -20 {
                node.removeFromParent()
                self.addPoints(points: 1)
            }
        }
		// убиваем вражеские корабли
		enumerateChildNodes(withName: "enemy_clear_marker") {
			(enemy:SKNode, nil) in
			
			if enemy.position.y < -20 {
				enemy.removeFromParent()
			}
		}
		
	}
	
	
    
	private func addPoints(points:Int){
		settings.currentScore += points
		pgameDelegate?.gameDelegateDidUpdateScore(score: self.settings.currentScore)
	}
    
    
    
    
    
    
    
    
    /// Аля ENTERFRAME
    ///
    /// - Parameter currentTime: время
    override func update(_ currentTime: TimeInterval) {

        // поправка для корабля
        if spaceShip.position.x < 0 {
            spaceShip.position.x = 0
        }
        if spaceShip.position.x > frame.size.width {
            spaceShip.position.x = frame.size.width
        }
        if spaceShip.position.y - spaceShip.frame.height / 2 < 0 {
            spaceShip.position.y = spaceShip.frame.height / 2
        }
        if spaceShip.position.y + spaceShip.frame.height / 2 > frame.size.height {
            spaceShip.position.y = frame.size.height - spaceShip.frame.height / 2
        }

        // поправка для фона
//        if stageBacking.position.x > frame.width / 2 {
//            stageBacking.position.x = frame.width / 2
//        }
//        if stageBacking.position.x < frame.width / 2 {
//            stageBacking.position.x = frame.width / 2
//        }
//        if stageBacking.position.y > -1 {
//            stageBacking.position.y = -1
//        }
//        if stageBacking.position.y < (frame.height - stageBacking.frame.height + 1) {
//            stageBacking.position.y = frame.height - stageBacking.frame.height + 1
//        }
		
		if (GameScene.accelerometer_flag) {
			acelerometrrControled()
		}
		
	}
	
	
	
	
	
	
    
    
    
    /// Управление кораблем с помощью акселерометра
	private func acelerometrrControled(){
		
		if let acelerometerData = motionManager.accelerometerData {
			
			let force = 25.0 // усиление
			//let dy_lean_correction = (acelerometerData.acceleration.y + 0.4) * force // коррекция наклона устройства для нормального держания в руках
			
			var motionVector:CGVector = CGVector(dx: acelerometerData.acceleration.x * force, dy: (acelerometerData.acceleration.y + abs(dY_lean_correction)) * force)
			
			if abs(motionVector.dx) < 0.2 && abs(motionVector.dy) < 0.2 {
				return
			}
			
			//***********************
			// ограничения движения *
			//***********************
			
			// влево
			if (spaceShip.position.x <= 0 && motionVector.dx < 0) {
				motionVector.dx = 0
			}
			// вправо
			if (spaceShip.position.x >= frame.size.width && motionVector.dx > 0) {
				motionVector.dx = 0
			}
//			// вниз
//			if (spaceShip.position.y + spaceShip.frame.height / 2 >= frame.size.height && motionVector.dy > 0) {
//				motionVector.dy = 0
//			}
//			// вверх
//			if (spaceShip.position.y - spaceShip.frame.height / 2 <= 0 && motionVector.dy < 0) {
//				motionVector.dy = 0
//			}
			
			let replaceAction = SKAction.move(by: motionVector, duration: 0.1)
			spaceShip.run(replaceAction)
			
			// двигаем фон
			let newVector:CGVector = CGVector(dx: (motionVector.dx / 10) * -1, dy: (motionVector.dy / 10) * -1)
			let parallaxAction = SKAction.move(by: newVector, duration: 0.1)
			backingContainer.run(parallaxAction)
			
		}
	}
    
    
    
    
    
    
    
    
    /// Рандом генератор
    ///
    /// - Parameters:
    ///   - min: минимальное значение
    ///   - max: максимальное значение
    /// - Returns: число между min и max
    public static func random(_ min: Int, _ max: Int) -> Int {
        guard min < max else {return min}
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
    
    
    
    public func distanceCalc(a:CGPoint, b:CGPoint) -> CGFloat{
        return sqrt(pow((b.x - a.x), 2) + pow((b.y - a.y), 2))
    }
    
    
    public func timeToTravelDistance(distance:CGFloat, speed:CGFloat) -> TimeInterval{
        let time = distance / speed
        return TimeInterval(time)
    }
    
	
	
	/// Возвращает рандомный элемент массива
	///
	/// - Parameter arr: массив
	public static func randArrElemen<T>(array arr:Array<T>) -> T{
		
		let randomIndex = Int(arc4random_uniform(UInt32(arr.count)))
		return arr[randomIndex]
	}
    
	
	
	/// Проигрывает короткий звук (контакт с камнем, например)
	///
	/// - Parameter name: название звука, который нужно проиграть
	private func playSound(_ name:String){
		if (!GameScene.sound_flag){
			return
		}
		let hitSound = SKAction.playSoundFileNamed(name, waitForCompletion: true)
		removeAction(forKey: "shortHit")
		run(hitSound, withKey:"shortHit")
	}
	
	
	
	
	/// мигание + ожидание
	private func blinking() -> SKAction{
		// определяем анимаюци столкновения с астероидом
		let fadeOutAction = SKAction.fadeOut(withDuration: 0.1) // исчезает
		fadeOutAction.timingMode = SKActionTimingMode.easeOut
		
		let fadeInAction = SKAction.fadeIn(withDuration: 0.1) // появляется
		fadeInAction.timingMode = SKActionTimingMode.easeOut
		
		let blinkAction = SKAction.sequence([fadeOutAction, fadeInAction]) // одно моргание на основе действий выше
		let blinkRepeatAction = SKAction.repeat(blinkAction, count: 4) // 3 моргания
		
		let delayAction = SKAction.wait(forDuration: 0.3) // ожидание 0,2с
		
		return SKAction.sequence([blinkRepeatAction, delayAction])
	}
	
	
	
	
	
	
	/// Отнимание жизней
	private func minusLives(){
		
		if flashingShip || playerImmortable || gameFinished || GameScene.god_flag {
			return
		}
		
		// отнимаем жизни сразу а не в кложере, который запускается с задержкой delayAction
		if (settings.lives > 0){
			settings.lives -= 1
			pgameDelegate?.gameDelegateDidUpdateLives()
			flashingShip = true
		}
		else {
			let gameOverAction = SKAction.run {
				self.gameFinished = true
				// передаем очки классу Settings
				self.settings.recordScores(score: self.settings.currentScore)
				// передаем очки экрану геймовер
				self.pgameDelegate?.gameDelegateGameOver(score: self.settings.currentScore)
				self.pgameDelegate?.gameDelegateDidUpdateLives()
				self.pauseGame()
			}
			let gameOverSequance = SKAction.sequence([blinking(), gameOverAction])
			spaceShip.run(gameOverSequance, withKey: "gameOverSequance")
		}
	}
	
	
	

	
	
	/// Взятие бонуса
	///
	/// - Parameter target: бонус
	private func useMaterial(_ target:Feature){
		
		// считаем где разместить взятый бонус
		let pointY = CGFloat(takenFeatures.count) * (target.size.height + 15)
		var replTarget:Feature!
		
		if (target.type != Bonus.health){
			if (activeWeapon != nil && target.isWeapon){
				// ищем в массиве бонусов оружие и направляем бонус на его место
				for eachElement in takenFeatures{
					if eachElement.isWeapon {
						replTarget = eachElement
						break
					}
				}
			}
			else {
				// если массив взятых бонусов уже содержит такой же бонус
				for eachElement in takenFeatures{
					if eachElement.type == target.type{
						replTarget = eachElement
						break
					}
				}
			}
			takenFeatures.append(target)
		}
		
		if (target.isWeapon){
			if (activeWeapon == nil){ // если до этого оружия небыло
				activeWeapon = target
			}
			else{
				turnFeature(target: activeWeapon, launching: false)
				activeWeapon = target
			}
		}

		// включение бонуса (не оружие)
		turnFeature(target: target, launching: true)
		
		let defaultPoint = CGPoint(x: frame.size.width - target.size.width / 2 - 10, y: frame.size.height - target.size.height / 2 - 60)

		// выбираем точку в которую будет лететь бонус
		let newPoint: CGPoint!
		if (target.type == Bonus.health){
			newPoint = CGPoint(x: 30, y: 20)
		}
		else {
			if (replTarget != nil){
				newPoint = replTarget.position
			}
			else {
				newPoint = CGPoint(x: defaultPoint.x, y: defaultPoint.y - pointY)
			}
		}
		// экшн полета
		let moveAct = SKAction.move(to: newPoint, duration: 0.6)
		moveAct.timingMode = .easeOut
		
		// по завершению полета
		target.run(moveAct) {
			target.alpha = 0.65
			if (replTarget != nil){
				// удаляем старый элемент из массива (на место которого хотим поставить новый)
				self.takenFeatures = self.takenFeatures.filter{$0 != replTarget}
				replTarget.timer.invalidate()
				self.armorFlickering(true_false: false)
				replTarget.removeFromParent()
			}
			
			if (target.type == Bonus.health){
				target.removeFromParent()
				if (self.settings.lives < self.settings.startingLives) {
					self.settings.lives += 1
					self.pgameDelegate?.gameDelegateDidUpdateLives()
				}
			}
			else{
				// запускаем таймер на бонусе
				target.runTimer()
			}
		}
	}

	
	
	

	
	
	
	
	
	/// Вкл/Выкл пойманых бонусов
	///
	/// - Parameters:
	///   - target: бонус
	///   - launching: флаг включать или выключать
	public func turnFeature(target:Feature, launching:Bool){
		
		switch target.type {
		case Bonus.immortal:
			if (launching){
				playerImmortable = true
				armor(true_false: true)
			}
			else{
				playerImmortable = false
				armor(true_false: false)
			}
		case Bonus.red_laser:
			if (launching){
				// таймер стрелялки лазером
				weaponTimer = Timer.scheduledTimer(timeInterval: target.weaponConf["fireRate"] as! TimeInterval, target: self, selector: #selector(startFire), userInfo: nil, repeats: true)
			}
			else{
				weaponTimer.fire()
				weaponTimer.invalidate()
				activeWeapon = nil
			}
		case Bonus.green_laser:
			if (launching){
				weaponTimer = Timer.scheduledTimer(timeInterval: target.weaponConf["fireRate"] as! TimeInterval, target: self, selector: #selector(startFire), userInfo: nil, repeats: true)
			}
			else{
				weaponTimer.fire()
				weaponTimer.invalidate()
				activeWeapon = nil
			}
		default: ()
		}
	}
		
	
	
	
	
	
	/// Перестановка иконок, для устранения пустого места
	public func resortIcons(){
		
		if (takenFeatures.isEmpty){
			return
		}
		
		let defaultPoint = CGPoint(x: frame.size.width - takenFeatures.first!.size.width / 2 - 10, y: frame.size.height - takenFeatures.first!.size.height / 2 - 60)
		var posY:CGFloat = 0
		
		for (index, value) in takenFeatures.enumerated(){
			// новая Y-координата
			posY = defaultPoint.y - CGFloat(index) * (value.size.height + 15)
			if (posY > defaultPoint.y) { // костыль, потому что иногда выезжает выше чем допустимо
				posY = defaultPoint.y
			}
			// проверка, не будет ли наезжать на предыдущий
			if (index > 0){
				if (posY == takenFeatures[index - 1].position.y){
					posY = takenFeatures[index - 1].position.y - (value.size.height + 15)
				}
			}
			// экшн сдвига
			let moveAction = SKAction.move(to: CGPoint(x: defaultPoint.x, y: posY), duration: 0.6)
			moveAction.timingMode = .easeOut

			value.run(moveAction)
		}
		
	}
	
	
	
	
	
	// эффект брони за счет копирования слоя
	public func armor(true_false arg:Bool) {
		
		if (arg){
			// сначала очищаем от мусора
			spaceShip.enumerateChildNodes(withName: "effect") {
				(armor:SKNode, nil) in
				
				armor.removeAction(forKey: "armorFlickering")
				armor.run(SKAction.fadeIn(withDuration: 0))
				armor.removeFromParent()
			}
			
			let copyOfTexture = SKSpriteNode(texture: spaceShip.texture, color: .green, size: spaceShip.size)
			spaceShip.addChild(copyOfTexture)
			copyOfTexture.xScale = 1.1
			copyOfTexture.yScale = 1.1
			copyOfTexture.position.y = 5
			copyOfTexture.blendMode = .add
			copyOfTexture.name = "effect"
			copyOfTexture.zPosition = -1
			copyOfTexture.run(SKAction.colorize(with: #colorLiteral(red: 1, green: 0.9880563072, blue: 0.1440601503, alpha: 1), colorBlendFactor: 1, duration: 0))
		}
		else{
			spaceShip.enumerateChildNodes(withName: "effect") {
				(armor:SKNode, nil) in
				armor.removeFromParent()
			}
		}
	}
	
	
	/// Мерцание броней (когда пропадает)
	public func armorFlickering(true_false arg:Bool){
		
		spaceShip.enumerateChildNodes(withName: "effect") {
			(armor:SKNode, nil) in
			
			if (arg){
				let fadeOut = SKAction.fadeOut(withDuration: 0.15)
				let fadeIn = SKAction.fadeIn(withDuration: 0.15)
				let sequence = SKAction.sequence([fadeOut, fadeIn])
				let repeatAct = SKAction.repeatForever(sequence)
				
				armor.run(repeatAct, withKey: "armorFlickering")
			}
			else {
				armor.removeAction(forKey: "armorFlickering")
				armor.run(SKAction.fadeIn(withDuration: 0))
			}
			
		}
	}
	
	
	
	
	
	
	
	
    //MARK: делегаты расширения SKPhysicsContactDelegate

	
    /// Столкновения (начало контакта)
    ///
    func didBegin(_ contact: SKPhysicsContact) {

		let contactRate = contact.bodyA.categoryBitMask + contact.bodyB.categoryBitMask
		let bodies:Array = [contact.bodyA, contact.bodyB]
		
		// на реальных устройтвах бывают странные косания, между телом и nil!!
		if (contact.bodyA.node == nil || contact.bodyB.node == nil){
			return
		}
		
		// 3  - корабль с астероидом
		// 5  - корабль с врагом
		// 17 - корабль с бонусом
		// 12 - лазер с врагом
		// 10 - лазер с астероидом
		
		switch contactRate {
		case 3:
			if (playerImmortable){
				for item in bodies {
					if (item.node?.name != "personage"){
						item.categoryBitMask = Collision.NONE
						smallExplosion(tar: item.node!)
						break
					}
				}
				playSound("enemy_down")
				addPoints(points: 5)
			}
			else{
				for item in bodies {
					if (item.node?.name != "personage"){
						item.categoryBitMask = Collision.NONE
						item.node?.alpha = 0.45
						break
					}
				}
				playSound("hitSound")
				minusLives()
			}
			
		case 5:
			for item in bodies {
				if (item.node?.name != "personage"){
					item.categoryBitMask = Collision.NONE
					smallExplosion(tar: item.node!)
					break
				}
			}
			playSound("hitSound")
			minusLives()
			
		case 17:
			for item in bodies {
				if (item.node?.name != "personage"){
					item.categoryBitMask = Collision.NONE
					item.node?.removeAction(forKey: "bonusFly")
					useMaterial(item.node as! Feature)
					break
				}
			}
			playSound("take_bonus")
			
		case 12:
			for item in bodies {
				// зеленый лазер после повержения врага летит дальше
				if (activeWeapon != nil && activeWeapon.type == Bonus.green_laser){
					if (item.node?.name != "laser"){
						smallExplosion(tar: item.node!)
					}
				}
				else {
					item.categoryBitMask = Collision.NONE
					smallExplosion(tar: item.node!)
				}
			}
			playSound("enemy_down")
			addPoints(points: 5)
			
		case 10:
			for item in bodies {
				// зеленый лазер после повержения врага летит дальше
				if (activeWeapon != nil && activeWeapon.type == Bonus.green_laser){
					if (item.node?.name != "laser"){ // странный НИЛ на телефоне з!!!
						smallExplosion(tar: item.node!)
					}
				}
				else{
					item.categoryBitMask = Collision.NONE
					smallExplosion(tar: item.node!)
				}
			}
			playSound("enemy_down")
			addPoints(points: 1)
			
		default: ()
		}
	}


	
	
	
	
	func didEnd(_ contact: SKPhysicsContact) { }
	
	
	
	

	private func smallExplosion(tar:SKNode){
		
		if let explosionFile = Bundle.main.path(forResource: "explosion", ofType: "sks"){
			let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionFile) as! SKEmitterNode
			explosion.particleScale = 0.2
			addChild(explosion)
			explosion.position = tar.position
			tar.removeFromParent()
			
			let fade = SKAction.fadeIn(withDuration: 0.3)
			let remove = SKAction.removeFromParent()
			
			let seq = SKAction.sequence([fade, remove])
			explosion.run(seq)
		}
	}
	
	
	
	

	
	
	
	
	
	
	
	
    
    
    
    
    
}





















