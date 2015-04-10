//
//  AppDelegate.swift
//  Magnify
//
//  Created by Ben Guo on 4/9/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Cocoa

struct Constants {
    // The number of timer ticks between skips
    static let skipInterval = 2

    // The range (in timer ticks) of the random padding
    static let randomPadRange = 2
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var _isEnabled = false
    var isEnabled: Bool {
        get {
            return _isEnabled
        }
        set(enabled) {
            _isEnabled = enabled
            self.statusMenuItem.title = enabled ? "Magnify: On" : "Magnify: Off"
            self.onOffMenuItem.title = enabled ? "Turn Magnify Off" : "Turn Magnify On"
            if (enabled) {
                SpotifyController.setRepeating(true)
                self.timer.fireDate = NSDate(timeIntervalSinceNow: 1)
            }
            else {
                SpotifyController.setRepeating(false)
                self.timer.fireDate = NSDate.distantFuture() as! NSDate
            }
        }
    }

    var tickCount: Int = 0
    var targetTickCount: Int = Constants.skipInterval
    lazy var timer: NSTimer = {
        return NSTimer.scheduledTimerWithTimeInterval(2,
            target: self, selector: "timerTick", userInfo: nil, repeats: true)
    }()

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
        let item = NSMenuItem(title: "Turn Magnify On", action: "toggleOnOff", keyEquivalent: "")
        item.enabled = true
        return item
    }()

    lazy var launchAtLoginMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Launch at login", action: "toggleLaunchAtLogin", keyEquivalent: "")
        item.enabled = true
        item.state = NSOffState
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
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.launchAtLoginMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.quitMenuItem)
        return menu
    }()

    func timerTick() {
        tickCount++
        if tickCount >= targetTickCount {
            tickCount = 0
            let randomPad = Int(arc4random_uniform(UInt32(Constants.randomPadRange)))
            targetTickCount = Constants.skipInterval + randomPad
            SpotifyController.nextTrack()
            print("next\n")
        }
        print("tick\n")
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.menu = menu
        updateLaunchAtLoginMenuItem()
    }

    func applicationWillTerminate(notification: NSNotification) {

    }

    func toggleOnOff() {
        self.isEnabled = !self.isEnabled
    }

    func updateLaunchAtLoginMenuItem() {
        let isLoginItem = NSBundle.mainBundle().isLoginItem()
        launchAtLoginMenuItem.state = isLoginItem ? NSOnState : NSOffState
    }

    func toggleLaunchAtLogin() {
        var isLoginItem = NSBundle.mainBundle().isLoginItem()
        if (isLoginItem) {
            NSBundle.mainBundle().removeFromLoginItems()
        }
        else {
            NSBundle.mainBundle().addToLoginItems()
        }
        updateLaunchAtLoginMenuItem()
    }

    func terminate() {
        NSApplication.sharedApplication().terminate(statusItem.menu)
    }

}

