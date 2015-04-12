//
//  AlertManager.swift
//  Magnify
//
//  Created by Ben Guo on 4/12/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

import Cocoa

class AlertManager: NSObject, NSAlertDelegate {

    lazy var remoteDefaults: RemoteDefaults = { RemoteDefaults() }()

    func showUpdateAlertIfNeeded() {
        let shouldShow = remoteDefaults.shouldShowUpdateAlert
        if shouldShow {
            let alert = NSAlert()
            alert.informativeText = "Update available"
            alert.messageText = remoteDefaults.updateAlertMessage
            alert.addButtonWithTitle("Download update")
            alert.addButtonWithTitle("Cancel")
            alert.delegate = self
            let button = alert.buttons.first as! NSButton
//            if let window = NSApplication.sharedApplication().mainWindow {
                alert.beginSheetModalForWindow(, completionHandler: { (response) -> Void in
                    switch (response) {
                    case NSAlertFirstButtonReturn:
                        self.remoteDefaults.updateURL.map {
                            NSWorkspace.sharedWorkspace().openURL($0)
                        }
                    default:
                        return
                    }
                })
//            }
        }
    }
}