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
    
    
    override func didMove(to view: SKView) {
        
        self.removeAllChildren()
        
        SceneSetting()
        
        spaceShip = SKSpriteNode(imageNamed: "picSpaceShip")
        spaceShip.position = CGPoint(x: 200, y: 200)
        addChild(spaceShip)
    }

    
    
    
    private func SceneSetting(){
        
        //backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        let stageBacking = SKSpriteNode(imageNamed: "background")
        stageBacking.anchorPoint = CGPoint(x: 0, y: 0)
        stageBacking.size = UIScreen.main.bounds.size
        
        addChild(stageBacking)
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            let touchLocation = touch.location(in: self)
            
            let moveAction = SKAction.move(to: touchLocation, duration: 0.5)
            
            spaceShip.run(moveAction)
        }
            
            
        
    }


}


