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

    override func viewDidLoad() {
        super.viewDidLoad()
        wiz.registerChangeObserver(self)

        // Do any additional setup after loading the view.

        // Load Japanese strings explicitly since we want to show Japanese translation for "Cat".
        // Translations for the current locale are automatically loaded
        self.loadJapanese()
        self.updateStrings()

    }

    deinit {
        // Do not forget to unregister your change observers
        wiz.unregisterChangeOhangeObserver(self)
    }

    private func loadJapanese() {
        wiz.fetchStrings(languageCode: "ja")
    }

    @objc func updateStrings() {
        self.navigationItem.title = wiz.getString("Hello LocalizeWiz")

        self.questionLabel.text = wiz.getString("How do you say 'cat' in Japanese?")
        self.answerLabel.text = wiz.getString("Cat", languageCode: "ja")
        self.changeButton.setTitle(wiz.getString("Change Language"), for: .normal)
    }
}

extension HelloViewController: WizLocalizationChangeObzerver {
    func handleEvent(_ event: WizEvent) {
        switch event {
        case .languageChanged(_):
            self.updateStrings()
            break
        default:
            break
        }
    }
}
