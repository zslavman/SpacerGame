//
//  Settings.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 06.09.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit

class Settings: NSObject {

	var highScore:Int
	var currentScore:Int
	var lastScore:Int
	
	let keyHighScore = "highScore"
	let keyLastScore = "lastScore"
	
	
	override init() {
		
		highScore = 0
		currentScore = 0
		lastScore = 0
		
		super.init()
		
		loadSettings()
	}
	
	
	
	
	
	public func recordScores(score:Int){
		if (score > highScore){
			highScore = score
		}
		lastScore = score
		saveSettings()
	}
	
	
	
	
	private func saveSettings(){
		UserDefaults.standard.set(highScore, forKey: keyHighScore)
		UserDefaults.standard.set(lastScore, forKey: keyLastScore)
	}
	
	

	
	private func loadSettings(){
		highScore = UserDefaults.standard.integer(forKey: keyHighScore)
		lastScore = UserDefaults.standard.integer(forKey: keyLastScore)
	}
	
	
	

	/// вычисляемое свойство для распечатки класса
	override var description: String {
		return "highScore: \(highScore), lastScore: \(lastScore), currentScore: \(currentScore)"
	}
	
	
	
	
	public func reset(){
		currentScore = 0
	}
	
	
	
	public func resetHighScore(){
		highScore = 0
		lastScore = 0
		saveSettings()
	}
	
	
	
	
	
	
	
	
	
	
	
	
}
