//
//  HelloViewController.swift
//  HelloWiz-iOS
//
//  Created by John Warmann on 2020-01-21.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import UIKit
import LocalizeWiz

class HelloViewController: UIViewController {


    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var answerLabel: UILabel!
    @IBOutlet private weak var changeButton: UIButton!
    private let mainQueue = DispatchQueue.main

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateStrings), name: NSNotification.Name.WizLanguageChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStrings()
    }


    @objc func updateStrings() {
        mainQueue.async {
            self.navigationItem.title = wiz.getString("Hello LocalizeWiz")

            self.questionLabel.text = wiz.getString("How do you say 'cat' in Japanese?")
            self.answerLabel.text = wiz.getString("Cat")
            self.changeButton.setTitle(wiz.getString("Change Language"), for: .normal)
        }
    }
}

