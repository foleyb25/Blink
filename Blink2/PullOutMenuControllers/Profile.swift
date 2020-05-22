//
//  Profile.swift
//  Blink2
//
//  Created by Brian Foley on 5/21/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class Profile: UIViewController {
    
    lazy var backButton: UIButton = {
       let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setBackgroundImage(UIImage(named: "logo_no_big"), for: .normal)
        button.addTarget(self, action: #selector(dismiss(animated:completion:)), for: .touchDown)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        view.backgroundColor = UIColor.white
    }
}
