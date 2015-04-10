//
//  AppDelegate.swift
//  Magnify
//
//  Created by Ben Guo on 4/9/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Cocoa

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

struct Constants {
    /// The base number of ticks between skips
    /// This should be >= 15
    static let skipInterval = 2//15

    /// Skip intervals will be padded with a random number of ticks 
    /// in the range [1, randomPadRange]
    static let randomPadRange = 2

    /// Skip tracks with a popularity higher than this limit
    static let popularityLimit = 50
}

struct UserDefaultsKeys {
    /// total number of plays
    static let totalPlayCount = "MagnifyTotalPlayCount"
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
    var targetTickCount: Int = Constants.skipInterval
    lazy var timer: NSTimer = {
        return NSTimer.scheduledTimerWithTimeInterval(2,
            target: self, selector: "timerTick", userInfo: nil, repeats: true)
    }()

    func updateStatusItem() {
        if isEnabled {
            let image = NSImage(named: "statusItemOn")
            image?.setTemplate(true)
            statusItem.image = image
        }
        else {
            let image = NSImage(named: "statusItemOff")
            image?.setTemplate(true)
            statusItem.image = image
        }
    }

    lazy var statusItem: NSStatusItem = {
        let item = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        item.highlightMode = true; return item
    }()

    lazy var statusMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Magnify: Off", action: nil, keyEquivalent: "")
        item.enabled = false; return item
    }()

    lazy var onOffMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Turn Magnify On", action: "toggleOnOff", keyEquivalent: "")
        item.enabled = true; return item
    }()

    func updateLaunchAtLoginMenuItem() {
        let isLoginItem = NSBundle.mainBundle().isLoginItem()
        launchAtLoginMenuItem.state = isLoginItem ? NSOnState : NSOffState
    }

    lazy var launchAtLoginMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Launch at login", action: "toggleLaunchAtLogin", keyEquivalent: "")
        item.enabled = true; item.state = NSOffState; return item
    }()

    func updatePlayCountMenuItem() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let count = defaults.integerForKey(UserDefaultsKeys.totalPlayCount)
        let s = count == 1 ? "" : "s"
        playCountMenuItem.title = "\(count) play\(s)"
    }

    lazy var playCountMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "", action: "toggleLaunchAtLogin", keyEquivalent: "")
        item.enabled = false; return item
    }()

    lazy var playlistMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Open Magnify Playlist", action: "openMagnifyPlaylist", keyEquivalent: "")
        item.enabled = true; return item
    }()

    lazy var quitMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Quit Magnify", action: "terminate", keyEquivalent: "")
        item.enabled = true; return item
    }()

    lazy var menu: NSMenu = {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(self.statusMenuItem)
        menu.addItem(self.onOffMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.launchAtLoginMenuItem)
        menu.addItem(self.playlistMenuItem)
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
        let randomPad = Int(arc4random_uniform(UInt32(Constants.randomPadRange)) + 1)
        targetTickCount = Constants.skipInterval + randomPad
    }

    /// skip track if it's over the popularity limit
    func skipIfPopular() {
        let maybePopularity = SpotifyController.currentTrackPopularity()
        if let popularity = maybePopularity {
            if popularity > Constants.popularityLimit {
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
        registerRemoteUserDefaults()
    }

    func applicationWillTerminate(notification: NSNotification) {
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func registerRemoteUserDefaults() {
        NSUserDefaults.configureResponseSerializer()
        let defaults = NSUserDefaults.standardUserDefaults()
        // TODO: should host this plist somewhere else
        let url = NSURL(string: "https://raw.githubusercontent.com/benzguo/magnify/master/defaults.plist")
        defaults.registerDefaultsWithURL(url,
            success: { defaults -> Void in
            })
            { err -> Void in
                // TODO: log error
        }
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

    func openMagnifyPlaylist() {
        let url = NSUserDefaults.standardUserDefaults().stringForKey("MagnifyPlaylist")
        url.map { SpotifyController.play($0) }
    }

    func terminate() {
        NSApplication.sharedApplication().terminate(statusItem.menu)
    }
}

