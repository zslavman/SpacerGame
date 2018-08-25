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


extension GameViewController: PauseViewDelegate {
    
    func pauseView_ResumeClicked(_ vc:PauseView){
        hidePauseScreen(pauseView)
    }
    func pauseView_MenuClicked(_ vc:PauseView){ }
    func pauseView_StoreClicked(_ vc:PauseView){ }
    
//    func pauseView_onMusicClick() {
//        music_On_Off()
//    }
//    func pauseView_onSoundClick() {
//
//    }
}





class GameViewController: UIViewController {
    
    
    @IBOutlet weak var ppBttn: UIButton! // кнопка для упрпвления ее видом
    
    public var gameScene:GameScene!
    public var pauseView:PauseView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseView = storyboard?.instantiateViewController(withIdentifier: "pauseView") as! PauseView
        pauseView.delegate = self
        onLoad()
    }
    

    
    // событие поворота экрана
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        
//        if UIDevice.current.orientation.isLandscape {
//            print("Landscape")
//        }
//        else {
//            print("Portrait")
//        }
//        onLoad()
//    }
    
    

    
    
    private func onLoad(){
        
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
    
    
    
    public func showPauseScreen(_ vc:PauseView){
        addChildViewController(vc)  // добавляем к существующему ВК дочерний ВК
        view.addSubview(vc.view)    // во вьюшку существующего ВК добавляем вьюшку нового(дочернего) ВК
        vc.view.frame = view.bounds // определяем размер новой вьюшки  = размеру родительской вьюшки
        
        vc.view.alpha = 0
        UIView.animate(withDuration: 0.65) {
            vc.view.alpha = 1
        }
        
    }
    
    
    public func hidePauseScreen(_ vc:PauseView){
        vc.willMove(toParentViewController: nil) // для удаления ВК из контейнера
        vc.removeFromParentViewController()
//        vc.view.removeFromSuperview()
        
        vc.view.alpha = 1
        UIView.animate(withDuration: 0.65, animations: {
            vc.view.alpha = 0
        }, completion: {
            (_) in
            vc.view.removeFromSuperview()
            self.onPP_Click(nil)
        })
    }
    
    
    // нажали на Play/Pause
    @IBAction func onPP_Click(_ sender: UIButton?) {

        if gameScene.isPaused{
            gameScene.playGame()
            ppBttn.setImage(UIImage(named: "pauseBttn"), for: .normal)
        }
        else{
            showPauseScreen(pauseView)
            gameScene.pauseGame()
            ppBttn.setImage(UIImage(named: "playBttn"), for: .normal)
        }
    }

    
    
    
//    func music_On_Off(){
//        GameScene.userDefaults.set(GameScene.music_flag, forKey: "music")
//        GameScene.userDefaults.synchronize()
//    }
    
    

    
    
    

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




















