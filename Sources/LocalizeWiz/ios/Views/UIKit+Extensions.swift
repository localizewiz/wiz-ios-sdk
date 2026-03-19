//
//  UIKit+Extensions.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-21.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

// These UInt8 values are used only as stable pointer addresses for
// objc_getAssociatedObject keys. They are `var` because Swift requires `&variable`
// for pointer coercion; `nonisolated(unsafe)` satisfies Swift 6 global mutable
// state rules. They are never actually mutated.
private nonisolated(unsafe) var wizStorageKey: UInt8 = 0
private nonisolated(unsafe) var wizStorageKey1: UInt8 = 1
private nonisolated(unsafe) var wizStorageKey2: UInt8 = 2
private nonisolated(unsafe) var autoLocalizeKey: UInt8 = 4

// @MainActor: all UIKit types conforming to this protocol are main-actor-isolated.
// Without this, Swift 6 flags the conformances as crossing actor isolation.
@MainActor
public protocol WizLocalizable {
    func wizLocalize()
}

#if os(iOS) || os(tvOS)

import UIKit

extension NSCoding {
    /// Get associated property by IBInspectable var.
    fileprivate func localizedValueFor(key: UnsafePointer<UInt8>) -> String? {
        return objc_getAssociatedObject(self, key) as? String
    }

    /// Set associated property by IBInspectable var.
    fileprivate func setLocalized(value: String?, key: UnsafePointer<UInt8>) {
        guard let value = value else { return }
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN)
    }

    /// Get associated autoLocalize property.
    fileprivate func autoLocalizeValue() -> Bool {
        return objc_getAssociatedObject(self, &autoLocalizeKey) as? Bool ?? true
    }

    /// Set associated autoLocalize property.
    fileprivate func setAutoLocalizeValue(value: Bool) {
        objc_setAssociatedObject(self, &autoLocalizeKey, value, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension UILabel: WizLocalizable {
    @IBInspectable public var localizeKey: String? {
        get { localizedValueFor(key: &wizStorageKey) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let key = localizeKey {
            self.text = Wiz.shared.getString(forKey: key)
        }
    }
}

extension UIButton: WizLocalizable {
    @IBInspectable public var localizeKey: String? {
        get { localizedValueFor(key: &wizStorageKey) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let key = localizeKey {
            let text = Wiz.shared.getString(forKey: key)
            titleLabel?.text = text
            let states: [UIControl.State] = [.normal, .highlighted, .selected, .disabled]
            for state in states { setTitle(text, for: state) }
        }
    }
}

extension UIBarItem: WizLocalizable {
    @IBInspectable public var localizeKey: String? {
        get { localizedValueFor(key: &wizStorageKey) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let key = localizeKey {
            title = Wiz.shared.getString(forKey: key)
        }
    }
}

extension UINavigationItem: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get { localizedValueFor(key: &wizStorageKey) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalizeTitle()
        }
    }

    private func wizLocalizeTitle() {
        if let key = localizeTextKey {
            title = Wiz.shared.getString(forKey: key)
        }
    }

    #if os(iOS)
    @IBInspectable public var localizePromptKey: String? {
        get { localizedValueFor(key: &wizStorageKey1) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey1)
            wizLocalizePrompt()
        }
    }

    private func wizLocalizePrompt() {
        if let key = localizePromptKey {
            prompt = Wiz.shared.getString(forKey: key)
        }
    }
    #endif

    public func wizLocalize() {
        wizLocalizeTitle()
        #if os(iOS)
        wizLocalizePrompt()
        #endif
    }
}

extension UISearchBar: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get { localizedValueFor(key: &wizStorageKey) }
        set { setLocalized(value: newValue, key: &wizStorageKey) }
    }

    @IBInspectable public var localizePlaceholderKey: String? {
        get { localizedValueFor(key: &wizStorageKey1) }
        set { setLocalized(value: newValue, key: &wizStorageKey1) }
    }

    @IBInspectable public var localizePromptKey: String? {
        get { localizedValueFor(key: &wizStorageKey2) }
        set { setLocalized(value: newValue, key: &wizStorageKey2) }
    }

    public func wizLocalize() {
        if let key = localizeTextKey { text = Wiz.shared.getString(forKey: key) }
        if let key = localizePlaceholderKey { placeholder = Wiz.shared.getString(forKey: key) }
        if let key = localizePromptKey { placeholder = Wiz.shared.getString(forKey: key) }
    }
}

extension UITextField: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get { localizedValueFor(key: &wizStorageKey) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            if let key = newValue { text = Wiz.shared.getString(forKey: key) }
        }
    }

    @IBInspectable public var localizePlaceholderKey: String? {
        get { localizedValueFor(key: &wizStorageKey1) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey1)
            if let key = newValue { placeholder = Wiz.shared.getString(forKey: key) }
        }
    }

    public func wizLocalize() {
        if let key = localizeTextKey { text = Wiz.shared.getString(forKey: key) }
        if let key = localizePlaceholderKey { placeholder = Wiz.shared.getString(forKey: key) }
    }
}

extension UITextView: WizLocalizable {
    @IBInspectable public var localizeTextKey: String? {
        get { localizedValueFor(key: &wizStorageKey) }
        set {
            setLocalized(value: newValue, key: &wizStorageKey)
            wizLocalize()
        }
    }

    public func wizLocalize() {
        if let key = localizeTextKey {
            text = Wiz.shared.getString(forKey: key)
        }
    }
}

#endif
