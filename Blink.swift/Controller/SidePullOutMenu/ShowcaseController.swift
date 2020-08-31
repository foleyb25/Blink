//
//  ShowcaseController.swift
//  Blink
//
//  Created by Brian Foley on 8/31/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class ShowcaseController: UIViewController {
    
    lazy var backButton: UIButton = {
       let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.addTarget(self, action: #selector(dismiss(animated:completion:)), for: .touchDown)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        view.backgroundColor = UIColor.white
    }
}
