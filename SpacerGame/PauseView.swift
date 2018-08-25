//
//  MenuView.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 24.08.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit


protocol PauseViewDelegate {
    func pauseView_ResumeClicked(_ vc:PauseView)
    func pauseView_MenuClicked(_ vc:PauseView)
    func pauseView_StoreClicked(_ vc:PauseView)
    
//    func pauseView_onSoundClick()
//    func pauseView_onMusicClick()
}



class PauseView: UIViewController {

    
    @IBOutlet weak var resumePlay_bttn: UIButton!
    @IBOutlet weak var menu_bttn: UIButton!
    @IBOutlet weak var store_bttn: UIButton!
    public var delegate:PauseViewDelegate!
    
    @IBOutlet weak var sounds_bttn: UIButton!
    @IBOutlet weak var music_bttn: UIButton!
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        changeButtonView_music(sounds_bttn)
//        changeButtonView_music(music_bttn)
        
        let buttonArray = [resumePlay_bttn, menu_bttn, store_bttn]
        
        for (index, button) in buttonArray.enumerated() {
            button?.transform = CGAffineTransform(scaleX: 0, y: 0) // определяем начальные значения кнопок
            
            let deley = Double(index) * 0.1 // задержка появления для каждой последующей кнопки
            
            // usingSpringWithDamping - как будет отскакывать, если = 1 то вообще отскакивать не будет
            // initialSpringVelocity - начальная скорость пружины
            UIView.animate(withDuration: 0.6, delay: deley, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                button?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
    
    
    @IBAction func onResumeClick(_ sender: UIButton) {
        delegate.pauseView_ResumeClicked(self)
    }
    @IBAction func onMenuClick(_ sender: UIButton) {
        delegate.pauseView_MenuClicked(self)
    }
    @IBAction func onStoreClick(_ sender: UIButton) {
        delegate.pauseView_StoreClicked(self)
    }
    
    
    @IBAction func onSoundClick(_ sender: UIButton) {
//        GameScene.sound_flag = !GameScene.sound_flag
//        changeButtonView_music(sender)
//        delegate.pauseView_onSoundClick()
    }

    @IBAction func onMusicClick(_ sender: UIButton) {
//        GameScene.music_flag = !GameScene.music_flag
//        changeButtonView_music(sender)
//        delegate.pauseView_onMusicClick()
    }
    
    
    
    
    // установка картинки кнопки в зависимости от режима - включено/выключено
//    func changeButtonView_music(_ button:UIButton){
//        
//        let boolFlag:Bool = (button == music_bttn) ? GameScene.music_flag : GameScene.sound_flag
//        
//        let str:String = (boolFlag) ? "menu_on" : "menu_off"
//        button.setImage(UIImage(named: str), for: .normal)
//    }
    
    
    
    
    
    
    
    
    
    
    
    


    
    
}
