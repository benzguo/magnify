//
//  NSMenuItemExtension.swift
//  Magnify
//
//  Created by Ben Guo on 4/12/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Cocoa

extension NSMenuItem {

    convenience init(title: String, action: Selector, enabled: Bool) {
        self.init(title: title, action: action, keyEquivalent: "")
        self.enabled = enabled
    }

}