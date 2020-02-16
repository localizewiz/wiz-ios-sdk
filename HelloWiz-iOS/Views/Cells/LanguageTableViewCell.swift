//
//  LanguageTableViewCell.swift
//  HelloWiz-iOS
//
//  Created by John Warmann on 2020-02-15.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import UIKit
import LocalizeWiz

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet private weak var flagImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    var language: Language? {
        didSet {
            if let language = language {
                if let flagUrlString = language.flagUrl {
                    self.flagImageView.load(from: flagUrlString)
                }
                self.nameLabel.text = wiz.getString(language.englishName)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
