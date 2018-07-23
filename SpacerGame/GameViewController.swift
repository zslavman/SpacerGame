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
    
    
    @IBOutlet weak var ppBttn: UIButton! // кнопка для упрпвления ее видом
    
    public var gameScene:GameScene!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let view = self.view as! SKView? {
            if let scene = GameScene(fileNamed: "GameScene") { // загружаем сцену игры из *.sks-файла
                scene.anchorPoint = CGPoint(x:0, y:0)
                scene.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                scene.scaleMode = .aspectFill
                
                scene.size = UIScreen.main.bounds.size // размеры сцены должны быть по размеру экрана устройства
                
                view.presentScene(scene)
                
                // мост в класс GameScene
                gameScene = scene
            }
            
            view.ignoresSiblingOrder = true // игнорировать очередность добавления элементов на сцену (порядок слоев)
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    
    // нажали на Play/Pause
    @IBAction func onPP_Click(_ sender: UIButton) {
        
        if gameScene.isPaused{
            gameScene.playGame()
            ppBttn.setImage(UIImage(named: "pauseBttn"), for: .normal)
        }
        else{
            gameScene.pauseGame()
            ppBttn.setImage(UIImage(named: "playBttn"), for: .normal)
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




















