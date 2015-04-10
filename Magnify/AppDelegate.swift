//
//  AppDelegate.swift
//  Magnify
//
//  Created by Ben Guo on 4/9/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    lazy var statusItem: NSStatusItem = {
        let item = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        let image = NSImage(named: "statusItem")
        image?.setTemplate(true)
        item.image = image
        let altImage = NSImage(named: "statusItemAlt")
        altImage?.setTemplate(true)
        item.alternateImage = altImage
        item.highlightMode = true
        return item
    }()

    lazy var statusMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Magnify: Off", action: nil, keyEquivalent: "")
        item.enabled = false
        return item
    }()

    lazy var onOffMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Turn Magnify On", action: nil, keyEquivalent: "")
        item.enabled = true
        return item
    }()

    lazy var launchAtLoginMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "launch at login", action: nil, keyEquivalent: "")
        item.enabled = true
        return item
    }()

    lazy var quitMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Quit Magnify", action: "terminate", keyEquivalent: "")
        item.enabled = true
        return item
    }()

    lazy var menu: NSMenu = {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(self.statusMenuItem)
        menu.addItem(self.onOffMenuItem)
        menu.addItem(self.launchAtLoginMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.quitMenuItem)
        return menu
    }()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.menu = menu
        var isLoginItem = NSBundle.mainBundle().isLoginItem()
        if (isLoginItem) {
            NSBundle.mainBundle().addToLoginItems()
        }
        launchAtLoginMenuItem.title = isLoginItem ? "login item" : "not login item"
        menu.update()
    }

    func terminate() {
        NSApplication.sharedApplication().terminate(statusItem.menu)
        // Insert code here to tear down your application
    }

}

