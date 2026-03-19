//
//  Notifier.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-06-11.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

class Notifier: Observable {
    private var observers = NSHashTable<AnyObject>(options: .weakMemory)

    public typealias Observer = WizLocalizationChangeObzerver

    func addObserver(_ observer: WizLocalizationChangeObzerver) {
        self.observers.add(observer)
    }

    func removeObserver(_ observer: WizLocalizationChangeObzerver) {
        self.observers.remove(observer)
    }

    func notifyObservers(ofEvent event: WizEvent) {
        // Superseded by Wiz actor's direct observer management (Wiz.notifyObservers).
        // Notifier is retained for source compatibility but is no longer called.
    }

    public func registerChangeObserver(_ observer: WizLocalizationChangeObzerver) {
        return self.addObserver(observer)
    }

    public func unregisterChangeOhangeObserver(_ observer: WizLocalizationChangeObzerver) {
        self.removeObserver(observer)
    }
}
