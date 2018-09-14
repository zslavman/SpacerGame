//
//  Configuration.swift
//  SpacerGame
//
//  Created by Zinko Vyacheslav on 15.09.2018.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit

class Configuration: UIViewController {

	
	@IBOutlet weak var tableView: UITableView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }


	
	/// Прячем статусбар
	override var prefersStatusBarHidden: Bool {
		return true
	}


}
