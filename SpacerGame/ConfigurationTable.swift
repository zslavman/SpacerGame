//
//  Tab.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 15.09.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit

class ConfigurationTable: UITableViewController {

	
	
	@IBOutlet weak var switcher_accelerometer: UISwitch! 	// tag 0
	@IBOutlet weak var switcher_music: UISwitch! 			// tag 1
	@IBOutlet weak var switcher_sound: UISwitch! 			// tag 2
	@IBOutlet weak var switcher_immortal: UISwitch! 		// tag 3
	@IBOutlet weak var switcher_vibro: UISwitch! 			// tag 4
	
	@IBOutlet weak var meteorits_count_TF: UILabel!
	@IBOutlet weak var enemys_count_TF: UILabel!
	@IBOutlet weak var bonuses_count_TF: UILabel!
	
	
	@IBOutlet weak var stepper1: UIStepper!
	@IBOutlet weak var stepper2: UIStepper!
	@IBOutlet weak var slider1: UISlider!
	

	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setSwitchers()
		setTextToLabels()
		
		// Значения по дефолту для степперов и слайдера
		stepper1.value = GameScene.asterPerSecond
		stepper2.value = GameScene.enemySpawnInterval
		slider1.value = Float(GameScene.featureSpawnInterval)
		
		// let io = #keyPath(switcher_accelerometer)
	}
	
	
	


	
	
	/// Тыцнули на свитчер
	@IBAction func onSwitcherChange(_ sender: UISwitch) {
	
		switch sender.tag {
		case 0:
			GameScene.accelerometer_flag = sender.isOn
		case 1:
			GameScene.music_flag = sender.isOn
			UserDefaults.standard.set(GameScene.music_flag, forKey: "music")
			UserDefaults.standard.synchronize()
		case 2:
			GameScene.sound_flag = sender.isOn
			UserDefaults.standard.set(GameScene.music_flag, forKey: "sound")
			UserDefaults.standard.synchronize()
		case 3:
			GameScene.god_flag = sender.isOn
		case 4:
			GameScene.vibro_flag = sender.isOn
			UserDefaults.standard.set(GameScene.vibro_flag, forKey: "vibro")
			UserDefaults.standard.synchronize()
		default: ()
		}
	}
	
	
	
	
	// степпер
	@IBAction func onStepperChange(_ sender: UIStepper) {
	
		switch sender.tag {
		case 100:
			GameScene.asterPerSecond = Double(sender.value)
		case 101:
			GameScene.enemySpawnInterval = TimeInterval(sender.value)
		default: ()
		}
		setTextToLabels()
	}
	
	
	
	// слайдер
	@IBAction func onSliderChange(_ sender: UISlider) {
		
		switch sender.tag {
		case 101:
			GameScene.featureSpawnInterval = TimeInterval(sender.value)
		default: ()
		}
		setTextToLabels()
	}
	
	
	
	
	private func setSwitchers(){
		
		switcher_accelerometer.isOn = GameScene.accelerometer_flag
		switcher_music.isOn			= GameScene.music_flag
		switcher_sound.isOn			= GameScene.sound_flag
		switcher_immortal.isOn		= GameScene.god_flag
		switcher_vibro.isOn			= GameScene.vibro_flag
	}
	
	
	
	
	
	private func setTextToLabels(){
		
		meteorits_count_TF.text = String(Int(GameScene.asterPerSecond))
		enemys_count_TF.text = String(Int(GameScene.enemySpawnInterval))
		bonuses_count_TF.text = String(Int(GameScene.featureSpawnInterval))
	}

	
	
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// перезапускаем спавн метеоритов
		GameScene.selF.asteroidSpawn()
		
		// перезапускаем спавн подарков
		GameScene.selF.featureSpawn()
		
		// перезапускаем спавн врагов
		GameScene.selF.enemySpawn()
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	




}
