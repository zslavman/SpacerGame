//
//  GameOverView.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 26.08.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit


protocol GameOverDelegate {
	func gameOver_onResetClick()
	func gameOver_onMenuClick()
	func gameOver_onTopClick()
}




class GameOverView: UIViewController {

	@IBOutlet weak var scoreTF: UILabel!
	
	public var delegate:GameOverDelegate! // делегат протокола GameOverDelegate
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	
	@IBAction func onResetClick(_ sender: UIButton) {
		delegate.gameOver_onResetClick()
	}
	
	@IBAction func onMenuClick(_ sender: UIButton) {
		delegate.gameOver_onMenuClick()
	}
	
	
	@IBAction func onTopClick(_ sender: UIButton) {
		delegate.gameOver_onTopClick()
	}
	
	
}
