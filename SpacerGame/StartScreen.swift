//
//  StartScreen.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 09.09.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit

class StartScreen: UIViewController {

	@IBOutlet weak var startBttn:UIButton!
	@IBOutlet weak var crownImage: UIImageView!
	
	private var maxPosition:Bool = true
	private var rotationRadians:CGFloat = 0  // угол поворота для анимации короны
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		startButtonAnimation()
		startCrownAnnimation()
    }

	
	
	
	
	/// Анимация кнопки
	private func startButtonAnimation(){
		
		maxPosition = !maxPosition
		
		let duration:Double = 1
		let fullCircle = 2 * Double.pi //  полный оборот
	
		// определиение направления масштаба
		let upAndDown = (maxPosition) ? CGFloat(-1 * fullCircle / 16) : CGFloat(fullCircle / 16)
		// тип имеет вид кортежа
		let scale:(CGFloat, CGFloat) = (maxPosition) ? (1.0, 1.0) : (1.15, 1.15)
	
		// запуск анимации
		// allowUserInteraction - при анимации кнопка перестает быть кнопкой, а нам нужно отлавливать события клика
		UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
			
			let rotationAnim = CGAffineTransform(rotationAngle: upAndDown)
			let scaleAnim = CGAffineTransform(scaleX: scale.0, y: scale.1)
		
			// т.к. эти две анимации нужно запустить одновременно - их нужно объединить
			self.startBttn.transform = rotationAnim.concatenating(scaleAnim)
		
		}) { (finished) in
			self.startButtonAnimation()
		}
	
	}
	
	
	
	
	
	
	
	
	/// Анимация (вращение) короны
	private func startCrownAnnimation(){
		
		UIView.animate(withDuration: 0.02, delay: 0, options: [.curveLinear], animations: {
			
			self.crownImage.transform = CGAffineTransform(rotationAngle: self.rotationRadians)
			
		}, completion: { (finished) in
			self.rotationRadians += CGFloat(Double.pi / 180) // прирощение следующего угла поворота в 1 градус
			self.startCrownAnnimation()
		})
	}
		
		
		
		


	

	
	
	
	
	
	
	

}
