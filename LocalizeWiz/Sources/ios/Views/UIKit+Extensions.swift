//
//  UIKit+Extensions.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-21.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

private var wizStorageKey: UInt8 = 0
private var wizStorageKey1: UInt8 = 1
private var wizStorageKey2: UInt8 = 2
private var autoLocalizeKey: UInt8 = 4

public protocol WizLocalizable {
    func wizLocalize()
}

private var wiz = Wiz.sharedInstance

#if os(iOS) || os(tvOS)
// Code to exclude from Mac.

import UIKit

extension NSCoding {
    /// Get associated property by IBInspectable var.
    fileprivate func localizedValueFor(key: UnsafeMutablePointer<UInt8>) -> String? {
        return objc_getAssociatedObject(self, key) as? String
    }

    /// Set associated property by IBInspectable var.
    fileprivate func setLocalized(value: String?, key: UnsafeMutablePointer<UInt8>) {
        guard let value = value else { return }
        let policy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
        objc_setAssociatedObject(self, key, value, policy)
    }

    /// Get associated autoLocalize property by IBInspectable var.
    fileprivate func autoLocalizeValue() -> Bool {
        return objc_getAssociatedObject(self, &autoLocalizeKey) as? Bool ?? true
    }

    /// Set associated autoLocalize property by IBInspectable var.
    fileprivate func setAutoLocalizeValue(value: Bool) {
        let policy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
        objc_setAssociatedObject(self, &autoLocalizeKey, value, policy)
    }
}

extension UILabel: WizLocalizable {
    @IBInspectable public var localizeKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let localizeKey = localizeKey {
            self.text = wiz.getString(localizeKey)
        }
    }
}

extension UIButton: WizLocalizable {
    @IBInspectable public var localizeKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let localizeKey = localizeKey {
            let localizedText = wiz.getString(localizeKey)
            titleLabel?.text = localizedText
            let states: [UIControl.State] = [.normal, .highlighted, .selected, .disabled]
            for state in states {
                setTitle(localizedText, for: state)
            }
        }
    }
}

extension UIBarItem: WizLocalizable {
    @IBInspectable public var localizeKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let localizeKey = localizeKey {
            title = wiz.getString(localizeKey)
        }
    }
}

extension UINavigationItem: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalizeTitle()
        }
    }

    @IBInspectable public var localizePromptKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey1)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey1)
            wizLocalizePrompt()
        }
    }

    public func wizLocalize() {
        wizLocalizeTitle()
        wizLocalizePrompt()
    }

    private func wizLocalizeTitle() {
        if let localizeTextKey = localizeTextKey {
            title = wiz.getString(localizeTextKey)
        }
    }

    private func wizLocalizePrompt() {
        if let localizePromptKey = localizePromptKey {
            prompt = wiz.getString(localizePromptKey)
        }
    }
}

extension UISearchBar: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
        }
    }

    @IBInspectable public var localizePlaceholderKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey1)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey1)
        }
    }

    @IBInspectable public var localizePromptKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey2)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey2)
        }
    }

    public func wizLocalize() {
        wizLocalizeText()
        wizLocalizePlaceholder()
        wizLocalizePrompt()
    }

    private func wizLocalizeText() {
        if let localizeTextKey = localizeTextKey {
            text = wiz.getString(localizeTextKey)
        }
    }

    private func wizLocalizePlaceholder() {
        if let localizePlaceholderKey = localizePlaceholderKey {
            placeholder = wiz.getString(localizePlaceholderKey)
        }
    }

    private func wizLocalizePrompt() {
        if let localizePromptKey = localizePromptKey {
            placeholder = wiz.getString(localizePromptKey)
        }
    }
}

extension UITextField: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalizeText()
        }
    }

    @IBInspectable public var localizePlaceholderKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey1)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey1)
            wizLocalizePlaceholder()
        }
    }

    public func wizLocalize() {
        wizLocalizeText()
        wizLocalizePlaceholder()
    }

    private func wizLocalizeText() {
        if let localizeTextKey = localizeTextKey {
            text = wiz.getString(localizeTextKey)
        }
    }

    private func wizLocalizePlaceholder() {
        if let localizePlaceholderKey = localizePlaceholderKey {
            placeholder = wiz.getString(localizePlaceholderKey)
        }
    }

}

extension UITextView: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get {
            return localizedValueFor(key: &wizStorageKey)
        }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let localizeTextKey = localizeTextKey {
            text = wiz.getString(localizeTextKey)
        }
    }
}

#endif
