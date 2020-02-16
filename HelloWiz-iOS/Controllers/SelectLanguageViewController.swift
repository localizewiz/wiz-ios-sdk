//
//  SelectLanguageViewController.swift
//  HelloWiz-iOS
//
//  Created by John Warmann on 2020-02-14.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import UIKit
import LocalizeWiz

class SelectLanguageViewController: UIViewController {

    private var languages: [Language]? = nil
    private var selectedLanguage: Language? = nil
    private let mainQueue = DispatchQueue.main
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.languages = wiz.project?.languages

        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()

        NotificationCenter.default.addObserver(self, selector: #selector(updateStrings), name: NSNotification.Name.WizLanguageChanged, object: nil)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStrings()
    }
    
    @IBAction private func dismiss(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction private func save(_ sender: Any) {
        if let language = self.selectedLanguage {
            wiz.setLanguage(language.isoCode) { (languageSet) in
                self.updateStrings()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                    self.dismiss(self)
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func language(at indexPath: IndexPath) -> Language? {
        if let languages = self.languages, languages.count > indexPath.row {
            return languages[indexPath.row]
        }
        return nil
    }

    @objc private func updateStrings() {
        self.mainQueue.async {
            self.navigationItem.title = wiz.getString("Select A Language")
            self.navigationItem.leftBarButtonItem?.title = wiz.getString("Cancel")
            self.navigationItem.rightBarButtonItem?.title = wiz.getString("Save")
            self.tableView.reloadData()
        }
    }
}

extension SelectLanguageViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark

        self.selectedLanguage = self.language(at: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        self.selectedLanguage = nil
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            self.selectedLanguage = nil
            return nil
        }
        return indexPath
    }
}

extension SelectLanguageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.languages?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell", for: indexPath)
        if let language = self.language(at: indexPath), let cell = cell as? LanguageTableViewCell {
            cell.language = language
        }
        return cell
    }
}
