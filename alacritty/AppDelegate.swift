//
//  AppDelegate.swift
//  alacritty
//
//  Created by ka2n on 2017/01/09.
//  Copyright © 2017 Katsuma Ito. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var tasks = DispatchGroup()
    
    var atomicQueue = DispatchQueue(label: "com.ktmtt.alacritty.atomic")
    var exitHandlerRegistered = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        launchShell()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        launchShell()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func launchShell() {
        tasks.enter()
        let task = Process()
        task.launchPath = "/usr/local/bin/alacritty"
        task.launch()
        task.terminationHandler = { [unowned self] _ in
            self.tasks.leave()
        }
        
        atomicQueue.sync {
            if !exitHandlerRegistered {
                exitHandlerRegistered = true
                tasks.notify(queue: DispatchQueue.main) { [unowned self] in
                    NSApplication.shared().terminate(self)
                }
            }
        }
    }
}
