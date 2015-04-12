//
//  RemoteUserDefaults.swift
//  Magnify
//
//  Created by Ben Guo on 4/12/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Foundation

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
        return maybe != nil ? maybe! : 2//15
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
            if maybeLocal != nil && maybeLocal is String? {
                return maybeLocal as! String?
            }
        }
        return nil
    }

    func intForKey(key: String) -> Int? {
        let maybeRemote: Int? = NSUserDefaults.standardUserDefaults().integerForKey(key)
        if let remote = maybeRemote {
            return Optional(remote)
        }
        else {
            let maybeLocal: AnyObject? = localDefaults?[key]
            if maybeLocal != nil && maybeLocal is Int? {
                return maybeLocal as! Int?
            }
        }
        return nil
    }
}
