//
//  ButtonNode.swift
//  Luftwaffe
//
//  Created by Zinko Vyacheslav on 12.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import SpriteKit

class ButtonNode: SKSpriteNode {

	
	public let label:SKLabelNode = {
		let l = SKLabelNode(text: "")
		l.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		l.fontName = "AppleSDGothicNeo-Bold"
		l.fontSize = 30
		l.horizontalAlignmentMode = .center
		l.verticalAlignmentMode = .center
		l.zPosition = 2
		return l
	}()
	
	
	override init(texture: SKTexture?, color: UIColor, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
		
	}
	
	
	
	convenience init(titled title:String?, backgroundSize:CGSize){
		
		self.init(texture: nil, color: .red, size: backgroundSize)
		if let title = title {
			label.text = title.uppercased()
		}
		addChild(label)
	}
	
	
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	
	
	
}
