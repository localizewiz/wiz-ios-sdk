//
//  DateExtensions.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-01-21.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

extension Date {
    
   func toString() -> String {
      return Log.dateFormatter.string(from: self as Date)
   }
}
