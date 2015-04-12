//
//  RemoteUserDefaults.swift
//  Magnify
//
//  Created by Ben Guo on 4/12/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Foundation

/// NOTE: this class assumes that all values in defaults.plist are Strings
class RemoteDefaults
{
    class func registerRemoteDefaults() {
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

    /// The base number of ticks between skips
    lazy var skipInterval: Int = {
        let maybe = self.intForKey("skipInterval")
        return maybe != nil ? maybe! : 15
    }()

    /// Skip intervals will be padded with a random number of ticks in the range [1, randomPadRange]
    lazy var randomPadRange: Int = {
        let maybe = self.intForKey("randomPadRange")
        return maybe != nil ? maybe! : 2
    }()

    /// Tracks with a popularity higher than this limit will be skipped
    lazy var popularityLimit: Int = {
        let maybe = self.intForKey("poularityLimit")
        return maybe != nil ? maybe! : 50
    }()

    /// The message for the update alert
    lazy var updateAlertMessage: String = {
        let maybe = self.stringForKey("updateAlertMessage")
        return maybe != nil ? maybe! : ""
    }()

    /// The URL of the update
    lazy var updateURL: NSURL? = {
        let maybe = self.stringForKey("updateURL")
        return maybe.flatMap { NSURL(string: $0) }
    }()

    /// Whether to display the update alert
    lazy var shouldShowUpdateAlert: Bool = {
        let maybe = self.intForKey("shouldShowUpdateAlert")
        return maybe != nil ? maybe == 1 : false
    }()

    lazy var localDefaults : NSDictionary? = {
        let path = NSBundle.mainBundle().pathForResource("defaults", ofType: "plist")
        return path.flatMap { NSDictionary(contentsOfFile: $0) }
    }()

    func stringForKey(key: String) -> String? {
        let maybeRemote: String? = NSUserDefaults.standardUserDefaults().stringForKey(key)
        if let remote = maybeRemote {
            return Optional(remote)
        }
        else {
            let maybeLocal: AnyObject? = localDefaults?[key]
            if let local: AnyObject = maybeLocal {
                return Optional(local as! String)
            }
        }
        return nil
    }

    func intForKey(key: String) -> Int? {
        let maybeString = stringForKey(key)
        return maybeString.flatMap { $0.toInt() }
    }
}
