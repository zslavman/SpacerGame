//
//  GameViewController.swift
//  SpacerGame
//
//  Created by Viacheslav on 08.07.18.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "GameScene") { // загружаем сцену игры из 'Scene.sks'
                scene.anchorPoint = CGPoint(x:0, y:0)
                
                scene.scaleMode = .aspectFill
                
                scene.size = UIScreen.main.bounds.size // размеры сцены должны быть по размеру экрана устройства
                
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }


    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
