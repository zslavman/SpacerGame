//
//  GameScene.swift
//  SpacerGame
//
//  Created by Viacheslav on 08.07.18.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var spaceShip:SKSpriteNode!
    private let w = UIScreen.main.bounds.size.width
    private let h = UIScreen.main.bounds.size.height
    
    private let ship_speed:CGFloat = 600    // поинтов в секунду
    private let asterPerSecond:Double = 7   // кол-во астероидов в сек
    
    
    
    override func didMove(to view: SKView) {
        
        self.removeAllChildren()
        
        // бэкграунг сцены
        let stageBacking = SKSpriteNode(imageNamed: "background")
        stageBacking.anchorPoint = CGPoint(x: 0, y: 0)
        stageBacking.size = UIScreen.main.bounds.size
        stageBacking.zPosition = 0
        addChild(stageBacking)
        
        
        // космич. корабль
        spaceShip = SKSpriteNode(imageNamed: "picSpaceShip")
        spaceShip.position = CGPoint(x: 200, y: 200)
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false // гравитация не должна утягивать корабль вниз
        spaceShip.zPosition = 1
        addChild(spaceShip)
        
        
        
        // генерируем астероиды
        let asteroidCreateAction = SKAction.run { 
            let asteroid = self.createAsteroid()
            asteroid.zPosition = 1
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
    }
    

    
    


    
    // клик по экрану
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            let touchLocation = touch.location(in: self)
            
            
            let dist = distanceCalc(a: spaceShip.position, b: touchLocation)
            let time = timeToTravelDistance(distance: dist, speed: ship_speed)
            
            print("distance = \(dist)")
            print("time = \(time)")
            let moveAction = SKAction.move(to: touchLocation, duration: time)
            
            spaceShip.run(moveAction)
        }
    }
    
    
    
    // создаем астероид
    private func createAsteroid() -> SKSpriteNode{
        
        let asteroid = SKSpriteNode(imageNamed: "asteroid2")
        asteroid.position.x = CGFloat(arc4random()).truncatingRemainder(dividingBy: frame.size.width) // truncatingRemainder - равносильно остатку "%"
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        let randFloat = CGFloat(Float(random(3, 5)) / 10.0)

        //asteroid.xScale = CGFloat(randFloatX)
        //asteroid.yScale = CGFloat(randFloatY)
        
        asteroid.setScale(randFloat)
        
        // назначаем астероиду физическое тело для взаимодействия. Метод ниже определяет физ.тело на основе прозрачности слоя
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        
        return asteroid
    }
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
//        let aster = createAsteroid()
//        addChild(aster)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    public func random(_ min: Int, _ max: Int) -> Int {
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
    
    
    


}


