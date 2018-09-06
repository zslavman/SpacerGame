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
	public var settings:Settings!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }

	
	override func viewDidAppear(_ animated: Bool) {
		scoreTF.text = String(settings.currentScore)
		
		super.viewDidAppear(animated)
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
