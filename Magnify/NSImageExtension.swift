//
//  NSImageExtension.swift
//  Magnify
//
//  Created by Ben Guo on 4/12/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Cocoa

extension NSImage {

    class func statusItemOn() -> NSImage? {
        let image = NSImage(named: "statusItemOn")
        image?.setTemplate(true)
        return image
    }

    class func statusItemOff() -> NSImage? {
        let image = NSImage(named: "statusItemOff")
        image?.setTemplate(true)
        return image
    }

}
