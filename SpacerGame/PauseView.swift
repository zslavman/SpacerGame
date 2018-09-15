//
//  MenuView.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 24.08.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit
import AVFoundation

protocol PauseViewDelegate {
    func pauseView_ResumeClicked(_ vc:PauseView)
    func pauseView_MenuClicked(_ vc:PauseView)
    func pauseView_StoreClicked(_ vc:PauseView)
}



class PauseView: UIViewController {

    
    @IBOutlet weak var resumePlay_bttn: UIButton!
    @IBOutlet weak var menu_bttn: UIButton!
    @IBOutlet weak var store_bttn: UIButton!
    public var delegate:PauseViewDelegate! // делегат протокола PauseViewDelegate

    @IBOutlet weak var sounds_bttn: UIButton!
    @IBOutlet weak var music_bttn: UIButton!
    private var opened:Bool = false

    let clickSound          = Bundle.main.url(forResource: "createPop", withExtension: "mp3")
    let robocopSound        = Bundle.main.url(forResource: "robocop4", withExtension: "mp3")

    var audioPlayer         = AVAudioPlayer()
	var audioPlayerBack 	= AVAudioPlayer()
	
	
	
	
	// сюда будут возвращаться из других экранов
	@IBAction func unwindToViewController (segue: UIStoryboardSegue){
		
		
	}
	

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // в этом нет необходимости, т.к. настройки этого контроллера запоминаются полсе его закрытия
        changeButtonView_music(sounds_bttn)
        changeButtonView_music(music_bttn)
        
        let buttonArray = [resumePlay_bttn, menu_bttn, store_bttn]
        
        if (!opened){ // анимация будет лишь при заходе сюда из другого контроллера
            for (index, button) in buttonArray.enumerated() {
                button?.transform = CGAffineTransform(scaleX: 0, y: 0) // определяем начальные значения кнопок
                
                let deley = Double(index) * 0.1 // задержка появления для каждой последующей кнопки
                
                // usingSpringWithDamping - как будет отскакывать, если = 1 то вообще отскакивать не будет
                // initialSpringVelocity - начальная скорость пружины
                UIView.animate(withDuration: 0.6, delay: deley, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    button?.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: nil)
            }
            opened = true
			UIApplication.shared.isIdleTimerDisabled = false
			
			loadBackMusic()
        }
    }
    
	
	
	/// Включаем фоновую музыку
	private func loadBackMusic(){
		
		do {
			audioPlayerBack = try AVAudioPlayer(contentsOf: robocopSound!)
			audioPlayerBack.volume = 0.3
			audioPlayerBack.numberOfLoops = -1
			if (GameScene.music_flag){
				audioPlayerBack.play()
			}
		}
		catch {
			print("couldn't load sound file")
		}
	}
	
	
	
	/// звук клика кнопок
	private func getClickSound(){
		do {
			audioPlayer = try AVAudioPlayer(contentsOf: clickSound!)
			audioPlayer.volume = 0.5
			audioPlayer.play()
		}
		catch {
			print("couldn't load sound file")
		}
	}
	
	
	
	
    
    @IBAction func onResumeClick(_ sender: UIButton) {
        delegate.pauseView_ResumeClicked(self)
		UIApplication.shared.isIdleTimerDisabled = true
		getClickSound()
    }
    @IBAction func onMenuClick(_ sender: UIButton) {
        delegate.pauseView_MenuClicked(self)
		getClickSound()
    }
    @IBAction func onStoreClick(_ sender: UIButton) {
        delegate.pauseView_StoreClicked(self)
		inNextUpdate(str: "Покупки")
		getClickSound()
    }
    
    
    @IBAction func onSoundClick(_ sender: UIButton) {
        GameScene.sound_flag = !GameScene.sound_flag
        changeButtonView_music(sender)
		
		UserDefaults.standard.set(GameScene.sound_flag, forKey: "sound")
		UserDefaults.standard.synchronize()
		getClickSound()
    }

    
    @IBAction func onMusicClick(_ sender: UIButton) {
        GameScene.music_flag = !GameScene.music_flag
        changeButtonView_music(sender)
		if (GameScene.music_flag){
			audioPlayerBack.play()
		}
		else {
			audioPlayerBack.stop()
		}
		
		getClickSound()
        UserDefaults.standard.set(GameScene.music_flag, forKey: "music")
        UserDefaults.standard.synchronize()
    }
    
	
	
	
	private func inNextUpdate(str:String){
		
		let ac = UIAlertController(title: str, message: "Доступно в будущих обновлениях", preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default)
		ac.addAction(ok)
		present(ac, animated: true, completion: nil)
	}
	
	
    
    
    // установка картинки кнопки в зависимости от режима - включено/выключено
    func changeButtonView_music(_ button:UIButton){
        
        let boolFlag:Bool = (button == music_bttn) ? GameScene.music_flag : GameScene.sound_flag
        
        let str:String = (boolFlag) ? "menu_on" : "menu_off"
        button.setImage(UIImage(named: str), for: .normal)
    }
    
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        opened = false
		audioPlayerBack.stop()
    }
    
    
    
    
    


    
    
}
