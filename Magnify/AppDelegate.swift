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

    lazy var remoteDefaults: RemoteDefaults = {
        return RemoteDefaults()
    }()

    lazy var bundleName: String = {
        let maybeName: AnyObject? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")
        let maybeString: String? = maybeName.map { $0 is String ? $0 : "Magnify"} as! String?
        if let string = maybeString { return string }
        else { return "Magnify" }
    }()

    var _isEnabled = false
    var isEnabled: Bool {
        get { return _isEnabled }
        set(enabled) {
            _isEnabled = enabled
            self.statusMenuItem.title = enabled ? "\(bundleName): On" : "\(bundleName): Off"
            self.onOffMenuItem.title = enabled ? "Turn \(bundleName) Off" : "Turn \(bundleName) On"
            self.updateStatusItem()
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
    var targetTickCount: Int = 0
    lazy var timer: NSTimer = {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "timerTick", userInfo: nil, repeats: true)
    }()

    lazy var statusItem: NSStatusItem = { NSStatusBar.systemStatusBar().statusItemWithLength(-1) }()

    func updateStatusItem() { statusItem.image = isEnabled ? NSImage.statusItemOn() : NSImage.statusItemOff() }

    lazy var statusMenuItem: NSMenuItem = { NSMenuItem(title: "\(self.bundleName): Off", action: nil, enabled: false) }()

    lazy var onOffMenuItem: NSMenuItem = {
        NSMenuItem(title: "Turn \(self.bundleName) On", action: "toggleOnOff", enabled: true)
    }()

    lazy var launchAtLoginMenuItem: NSMenuItem = {
        NSMenuItem(title: "Launch at login", action: "toggleLaunchAtLogin", enabled: true)
    }()

    func updateLaunchAtLoginMenuItem() {
        launchAtLoginMenuItem.state = NSBundle.mainBundle().isLoginItem() ? NSOnState : NSOffState
    }

    func updatePlayCountMenuItem() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let count = defaults.integerForKey(UserDefaultsKeys.totalPlayCount)
        let s = count == 1 ? "" : "s"
        playCountMenuItem.title = "\(count) play\(s)"
    }

    lazy var playCountMenuItem: NSMenuItem = {
        NSMenuItem(title: "", action: "toggleLaunchAtLogin", enabled: false)
    }()

    lazy var quitMenuItem: NSMenuItem = {
        NSMenuItem(title: "Quit \(self.bundleName)", action: "terminate", enabled: true)
    }()

    lazy var menu: NSMenu = {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(self.statusMenuItem)
        menu.addItem(self.onOffMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.launchAtLoginMenuItem)
        menu.addItem(self.playCountMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.quitMenuItem)
//        menu.addItem(NSMenuItem(title:"debug", action:"debug", keyEquivalent:""))
        return menu
    }()

    func debug() {
        print(SpotifyController.currentTrackPopularity())
    }

    func timerTick() {
        tickCount++
        skipIfPopular()
        if tickCount >= targetTickCount {
            resetTickCount()
            randomStep()

            // increment play count
            let defaults = NSUserDefaults.standardUserDefaults()
            let totalPlays = defaults.integerForKey(UserDefaultsKeys.totalPlayCount)
            defaults.setInteger(totalPlays+1, forKey: UserDefaultsKeys.totalPlayCount)
            updatePlayCountMenuItem()
        }
    }

    func resetTickCount() {
        tickCount = 0
        let randomPad = Int(arc4random_uniform(UInt32(remoteDefaults.randomPadRange)) + 1)
        targetTickCount = remoteDefaults.skipInterval + randomPad
    }

    /// skip track if it's over the popularity limit
    func skipIfPopular() {
        let maybePopularity = SpotifyController.currentTrackPopularity()
        if let popularity = maybePopularity {
            if popularity > remoteDefaults.popularityLimit {
                resetTickCount()
                randomStep()
            }
        }
    }

    func randomStep() {
        let shouldNext = arc4random_uniform(2) == 0
        if shouldNext {
            SpotifyController.nextTrack()
        }
        else {
            SpotifyController.previousTrack()
            SpotifyController.previousTrack()
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.menu = menu
        updateLaunchAtLoginMenuItem()
        updatePlayCountMenuItem()
        updateStatusItem()
        RemoteDefaults.registerRemoteDefaults()
    }

    func applicationWillTerminate(notification: NSNotification) {
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func toggleOnOff() {
        self.isEnabled = !self.isEnabled
    }

    func toggleLaunchAtLogin() {
        var isLoginItem = NSBundle.mainBundle().isLoginItem()
        if (isLoginItem) { NSBundle.mainBundle().removeFromLoginItems() }
        else { NSBundle.mainBundle().addToLoginItems() }
        updateLaunchAtLoginMenuItem()
    }

    func terminate() {
        NSApplication.sharedApplication().terminate(statusItem.menu)
    }
}

