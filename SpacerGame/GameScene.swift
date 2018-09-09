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
	public static let PLAYER_SHIP	: UInt32 = 0x1 << 0
	public static let ASTEROID 		: UInt32 = 0x1 << 1
	public static let ENEMY_SHIP 	: UInt32 = 0x1 << 2
	public static let LASER 		: UInt32 = 0x1 << 3
}

// для использования энума, необходимо в конце добавлять rawValue, например:  ... = Collision.PLAYER_SHIP.rawValue
//enum Collision: UInt32 { // кейсы - степени 2-ки начиная с 0-вой степени
//	case NONE			= 1
//	case PLAYER_SHIP 	= 2
//	case ASTEROID		= 4
//	case ENEMY_SHIP		= 8
//}





class GameScene: SKScene, SKPhysicsContactDelegate {
    
	public var pgameDelegate:PGameDelegate? // делегат протокола PGameDelegate
    public var soundChanel:AVAudioPlayer!
	private var spaceShipOnFinger:Bool = false // флаг, что тач прикоснувшись попали на корабль
	public var settings: Settings!
	
	
    private var spaceShip:SKSpriteNode!
    private let w 							= UIScreen.main.bounds.size.width
    private let h							= UIScreen.main.bounds.size.height

    private let ship_speed:CGFloat			= 600// поинтов в секунду
    private let asterPerSecond:Double		= 2// кол-во астероидов в сек

    // идентификаторы столкновений (битовые маски)
//    private let chipCategory:UInt32			= 0x1 << 0// 0000..01
//    private let asterCategory:UInt32		= 0x1 << 1// 0000..10
    private var _score:Int					= 0
	private var gameFinished:Bool			= false // gameOver

	private var motionManager: CMMotionManager!
	private var starsLayer:SKNode!              // слой звезд
	private var asteroidLayer:SKNode = SKNode() // слой астероидов
	private var dY_lean_correction:Double	= 0.4// коррекция на наклон устройства

    public static var music_flag:Bool		= true
	public static var sound_flag:Bool		= true

    public var stageBacking:SKSpriteNode!
//	private var scoreLabel:SKLabelNode! // лейба с очками игрока
//	public var score:Int {
//		get { return _score }
//		set {
//			_score  		= newValue
//			scoreLabel.text = "Очки: \(_score)"
//		}
//	}

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
    
	private var lastTouchCoords:CGPoint = CGPoint.zero 	// тут будут координаты корабля в момент касания = начало координат
	private var playerImmortable:Bool = true 			// неуязвимость
    
    
    
    /// Включение фоновой музыки
    private func playBackMusic(){
        let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "m4a")!
        soundChanel = try! AVAudioPlayer(contentsOf: musicURL, fileTypeHint: nil)
        soundChanel.numberOfLoops = -1
        soundChanel.volume = 0.02
        soundChanel.play()
    }
    

	
	// стрелялка лазером
	@objc func startFire(){
		
		let redLaser = SKSpriteNode(imageNamed: "redLaser")
		redLaser.zPosition = spaceShip.zPosition - 1
		redLaser.xScale = 0.5
		redLaser.yScale = 0.5
		redLaser.name = "laser"
		
		redLaser.position = CGPoint(x: spaceShip.position.x, y: spaceShip.position.y + 10)
		
		let moveAction = SKAction.move(by: CGVector(dx: 0, dy: self.frame.height + redLaser.frame.height), duration: 0.5)
		let removeAction = SKAction.removeFromParent()
		
		let laserSequence = SKAction.sequence([moveAction, removeAction])
		
		addChild(redLaser)
		
		// задаем физическое тело
		let laserTexture = SKTexture(imageNamed: "redLaser")
		redLaser.physicsBody = SKPhysicsBody(texture: laserTexture, size: redLaser.size)
		
		// принебрегаем воздействием гравитации
		redLaser.physicsBody?.affectedByGravity 	= false
		redLaser.physicsBody?.isDynamic 			= false
	
		redLaser.physicsBody?.categoryBitMask 		= Collision.LASER 		// устанавливаем битмаску столкновений
		redLaser.physicsBody?.contactTestBitMask 	= Collision.ENEMY_SHIP 	// от каких столкновений хотим получать уведомления (триггер столкновений)
//		redLaser.physicsBody?.collisionBitMask 		= Collision.ENEMY_SHIP	// при каких столкновениях мы хотим чтоб лазер вел себя как физическое тело
		
		
		redLaser.run(laserSequence)
		
	}
	
	
	
	
    
	
    override func didMove(to view: SKView) {
		
		enemySpawn()
//        self.removeAllChildren() // очистка сцены от всего
		
        // любой рандомайзер всегда на что-то операется, в данном случае на время, потому при каждом запуске оно будет разное
        srand48(time(nil)) // "для того чтоб сид был разный"
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8) // гравитация - вектор, направленный сверху-вниз с ускорением -9,8
        
        
        // бэкграунг сцены
        stageBacking = SKSpriteNode(imageNamed: "background")
        stageBacking.anchorPoint = CGPoint(x: 0, y: 0)
        //stageBacking.size = UIScreen.main.bounds.size
        stageBacking.size = CGSize(width: frame.size.width * 1.5, height: frame.size.height * 1.5)
        addChild(stageBacking)
        
        // создаем слой звезд
        let starsPath:String = Bundle.main.path(forResource: "stars", ofType: "sks")!
        let starsEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: starsPath) as! SKEmitterNode
        starsEmitter.position = CGPoint(x: self.frame.midX, y: self.frame.height)
        starsEmitter.particlePositionRange.dx = self.frame.width
        starsEmitter.advanceSimulationTime(20) // сколько должна уже идти симуляция до запуска приложения
        
        starsLayer = SKNode()
        addChild(starsLayer)
        starsLayer.addChild(starsEmitter)
        
        // космич. корабль
        spaceShip = SKSpriteNode(imageNamed: "picSpaceShip")
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false // гравитация не должна утягивать корабль вниз
        
        // определяем с кем корабль будет сталкиваться
        spaceShip.physicsBody?.categoryBitMask = Collision.PLAYER_SHIP
        spaceShip.physicsBody?.collisionBitMask = Collision.ASTEROID
        spaceShip.physicsBody?.contactTestBitMask = Collision.ASTEROID // на что мы должны получать уведомление
        
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
        
        // лейблу очков
//        scoreLabel = SKLabelNode(text: "Очки: \(score)")
//        //scoreLabel.calculateAccumulatedFrame().height - собственная высота лейбла
//        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - scoreLabel.calculateAccumulatedFrame().height - 15)
//        scoreLabel.fontName = "Arial"
//        scoreLabel.fontSize = 17
//        addChild(scoreLabel)
		
        
        stageBacking.zPosition = 0
        starsLayer.zPosition = 1
        spaceShip.zPosition = 2
//        scoreLabel.zPosition = 3
		
		// так не работает отслеживание вылета за экран!!!
		// addChild(asteroidLayer)
		// self.asteroidLayer.zPosition = 2
		
        // генерируем астероиды
        let asteroidCreateAction = SKAction.run { 
            let asteroid = self.createAsteroid()
            asteroid.zPosition = 2
            self.addChild(asteroid)
        }
        
        
        // будет генерировать астероиды с задержкой от 1с до 1,5с
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0 / asterPerSecond, withRange: 0.25)
        
        // последовательность действий
        let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction, asteroidCreationDelay])
        
        // зацикливаем создание астероидов
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        
        // запускаем всю эту шнягу
        run(asteroidRunAction)
        
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
		
		
		// таймер стрелялки лазером
		// selector - метод который хотим вызвать
		_ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(startFire), userInfo: nil, repeats: true)
		
    }
    
    
	
	
	
	
	
    

    public func resetGame(){
		
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
		spaceShip.position = CGPoint(x: w/2, y: spaceShip.frame.size.height/2 + 50)
	}

	
    
    public func pauseGame(){
        isPaused = true
        spaceShip.removeAction(forKey: "move")
        if (soundChanel != nil) {
            soundChanel.pause()
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
	}
	

	
	
	public func enemySpawn(){
		
		let enemyAction = SKAction.run {
			let enemy = Enemy()
			enemy.zPosition = 2
			self.addChild(enemy)
			enemy.name = "enemy_clear_marker"
			enemy.fly()
		}
		
		let waitDuration = SKAction.wait(forDuration: 7, withRange: 3)
		let enemySequence = SKAction.sequence([enemyAction, waitDuration])
		let repeatSpawn	= SKAction.repeatForever(enemySequence)
		
		run(repeatSpawn, withKey: "enemySpawn")
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
				lastTouchCoords = touchLocation
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		spaceShipOnFinger = false
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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

        //asteroid.xScale = CGFloat(randFloatX)
        //asteroid.yScale = CGFloat(randFloatY)
        
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
        if stageBacking.position.x > -1 {
            stageBacking.position.x = -1
        }
        if stageBacking.position.x < (frame.width - stageBacking.frame.width + 1) {
            stageBacking.position.x = frame.width - stageBacking.frame.width + 1
        }
        if stageBacking.position.y > -1 {
            stageBacking.position.y = -1
        }
        if stageBacking.position.y < (frame.height - stageBacking.frame.height + 1) {
            stageBacking.position.y = frame.height - stageBacking.frame.height + 1
        }
        
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
            // вниз
            if (spaceShip.position.y + spaceShip.frame.height / 2 >= frame.size.height && motionVector.dy > 0) {
                motionVector.dy = 0
            }
            // вверх
            if (spaceShip.position.y - spaceShip.frame.height / 2 <= 0 && motionVector.dy < 0) {
                motionVector.dy = 0
            }
            
            
            let replaceAction = SKAction.move(by: motionVector, duration: 0.1)
            spaceShip.run(replaceAction)
            
            
            // двигаем фон
            let newVector:CGVector = CGVector(dx: (motionVector.dx / 10) * -1, dy: (motionVector.dy / 10) * -1)
            let parallaxAction = SKAction.move(by: newVector, duration: 0.1)
            stageBacking.run(parallaxAction)
            
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
    
    
    
    
    
    //MARK: делегаты расширения SKPhysicsContactDelegate

	
    /// Столкновения (начало контакта)
    ///
    /// - Parameter contact: 111
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == Collision.PLAYER_SHIP && contact.bodyB.categoryBitMask == Collision.ASTEROID || contact.bodyB.categoryBitMask == Collision.PLAYER_SHIP && contact.bodyA.categoryBitMask == Collision.ASTEROID){
			
			// устраняем множественные косания
			if (contact.bodyA.node?.name == "asteroid_out_marker"){
				contact.bodyA.categoryBitMask = Collision.NONE
			}
			else if (contact.bodyB.node?.name == "asteroid_out_marker"){
				contact.bodyB.categoryBitMask = Collision.NONE
			}

			
			if !flashingShip && !playerImmortable {
				
                flashingShip = true
				
				if (!gameFinished){
					
					// определяем анимаюци столкновения с астероидом
					let fadeOutAction = SKAction.fadeOut(withDuration: 0.1) // исчезает
					fadeOutAction.timingMode = SKActionTimingMode.easeOut
					
					let fadeInAction = SKAction.fadeIn(withDuration: 0.1) // появляется
					fadeInAction.timingMode = SKActionTimingMode.easeOut
					
					let blinkAction = SKAction.sequence([fadeOutAction, fadeInAction]) // одно моргание на основе действий выше
					let blinkRepeatAction = SKAction.repeat(blinkAction, count: 4) // 3 моргания
					
					let delayAction = SKAction.wait(forDuration: 0.3) // ожидание 0,2с
					
					// отнимаем жизни сразу а не в кложере, который запускается с задержкой delayAction
					if (settings.lives > 0){
						settings.lives -= 1
						pgameDelegate?.gameDelegateDidUpdateLives()
						print("lives = \(settings.lives)")
					}
					
					let gameOverAction = SKAction.run {
						
						if (self.settings.lives == 0){
							self.gameFinished = true
							// передаем очки классу Settings
							self.settings.recordScores(score: self.settings.currentScore)
							// передаем очки экрану геймовер
							self.pgameDelegate?.gameDelegateGameOver(score: self.settings.currentScore)
							self.pgameDelegate?.gameDelegateDidUpdateLives()
							self.pauseGame()
						}
					}
					let gameOverSequance = SKAction.sequence([blinkRepeatAction, delayAction, gameOverAction])
					spaceShip.run(gameOverSequance)
				}
            }
            if (GameScene.sound_flag){
                let hitSound = SKAction.playSoundFileNamed("hitSound", waitForCompletion: true)
                //let reduseSoundVolume = SKAction.changeVolume(by: 0.01, duration: 1)
                //let groupActions = SKAction.group([hitSound, reduseSoundVolume])
                removeAction(forKey: "shortHit")
                run(hitSound, withKey:"shortHit")
            }
		}
		
		// соприкосновение вражины с лазером
		if (contact.bodyA.categoryBitMask == Collision.LASER && contact.bodyB.categoryBitMask == Collision.ENEMY_SHIP || contact.bodyB.categoryBitMask == Collision.LASER && contact.bodyA.categoryBitMask == Collision.ENEMY_SHIP){
			
			// любое тело контакта будет удалено со сцены
			let firstBody = contact.bodyA.node
			let secondBody = contact.bodyB.node

			// для устранения множественного контакта
			firstBody?.physicsBody?.categoryBitMask = Collision.NONE
			secondBody?.physicsBody?.categoryBitMask = Collision.NONE
			
			firstBody!.removeFromParent()
			secondBody!.removeFromParent()
			addPoints(points: 5)
		}
		
		
		
    }
        
	
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        
    }
    
    
    
    
    
}





















