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
	public var pauseView:PauseView!
    public var gameOverView:GameOverView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseView = storyboard?.instantiateViewController(withIdentifier: "pauseView") as! PauseView
        pauseView.delegate = self
		
		gameOverView = storyboard?.instantiateViewController(withIdentifier: "goView") as! GameOverView
		gameOverView.delegate = self
		
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
				gameScene.pgameDelegate = self
			}
            view.ignoresSiblingOrder = true // игнорировать очередность добавления элементов на сцену (порядок слоев)
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    

	
	/// Показываем переданный экран
	///
	/// - Parameter vc: экран-контроллер
	public func showXScreen<T>(_ vc:T){
		
		let newView = vc as! UIViewController
		
		addChildViewController(newView)  // добавляем к существующему ВК дочерний ВК
		view.addSubview(newView.view)    // во вьюшку существующего ВК добавляем вьюшку нового(дочернего) ВК
		newView.view.frame = view.bounds // определяем размер новой вьюшки  = размеру родительской вьюшки
		
		newView.view.alpha = 0
		UIView.animate(withDuration: 0.65) {
			newView.view.alpha = 1
		}
	}
	

	
	
	/// Прячем переданный экран
	///
	/// - Parameter vc: экран-контроллер
	public func hideXScreen<T>(_ vc:T){
		
		let newView = vc as! UIViewController
		
		newView.willMove(toParentViewController: nil) // для удаления ВК из контейнера
		newView.removeFromParentViewController()
		
		newView.view.alpha = 1
		UIView.animate(withDuration: 0.65, animations: {
			newView.view.alpha = 0
		}, completion: {
			(_) in
			newView.view.removeFromSuperview()
			if (newView is PauseView){
				self.onPP_Click(nil)
			}
		})
	}
	
	
	
    
    
    // нажали на Play/Pause
    @IBAction func onPP_Click(_ sender: UIButton?) {

        if gameScene.isPaused{
            gameScene.playGame()
            ppBttn.setImage(UIImage(named: "pauseBttn"), for: .normal)
        }
        else{
            showXScreen(pauseView)
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



//MARK: расширение, чтоб добратся до этого класса из PauseView
extension GameViewController: PauseViewDelegate {
	
	func pauseView_ResumeClicked(_ vc:PauseView){
		hideXScreen(pauseView)
	}
	func pauseView_MenuClicked(_ vc:PauseView){ }
	func pauseView_StoreClicked(_ vc:PauseView){ }
}


extension GameViewController: GameOverDelegate {
	
	func gameOver_onResetClick(){
		gameScene.resetGame()
		hideXScreen(gameOverView)
	}
	func gameOver_onMenuClick(){}
	func gameOver_onTopClick(){}
}


extension GameViewController: PGameDelegate {

	func gameDelegateUpdateScore(score:Int){}
	func gameDelegateGameOver(score:Int){
		print("Трындец!")
		showXScreen(gameOverView)
	}
}













