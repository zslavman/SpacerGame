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
}



class PauseView: UIViewController {

    
    @IBOutlet weak var resumePlay_bttn: UIButton!
    @IBOutlet weak var menu_bttn: UIButton!
    @IBOutlet weak var store_bttn: UIButton!
    public var delegate:PauseViewDelegate!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    
    
}
