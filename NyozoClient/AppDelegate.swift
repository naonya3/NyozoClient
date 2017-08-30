//
//  AppDelegate.swift
//  NyozoClient
//
//  Created by Naoto Horiguchi on 2017/08/30.
//  Copyright © 2017年 naonya3. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let cmd = "/usr/sbin/screencapture"
        let task = Process()
        task.launchPath = cmd
        task.arguments  = ["-i","-c","tmp.png"]
        task.launch()
        task.waitUntilExit()
        
        let board = NSPasteboard.general()
        if board.canReadObject(forClasses: [NSImage.self], options: nil) {
            guard let image = board.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
                fatalError()
            }
            guard let d = image.tiffRepresentation, let b = NSBitmapImageRep(data: d), let data = b.representation(using: .PNG, properties: [:]) else {
                fatalError()
            }
            post(data)
        } else {
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func post(_ image: Data) {
        let url = URL(string: "http://example.com/upload.cgi")!
        let request = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "POST"
        request.timeoutInterval = 30.0
        
        let boundary:String = "---------------------------skdjalksdjl"
        var body = Data()
        var postData = ""
        
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        postData += "--\(boundary)\r\n"
        postData += "Content-Disposition: form-data; name=\"imagedata\"; filename=\"name\"\r\n"
        postData += "Content-Type: image/png\r\n\r\n"

        body.append(postData.data(using: String.Encoding.utf8)!)
        body.append(image)
        
        postData = String()
        postData += "\r\n"
        postData += "\r\n--\(boundary)--\r\n"
        
        body.append(postData.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request as URLRequest) { (d, r, e) in
            print(d,r,e)
            NSApp.terminate(nil)
        }
        task.resume()
    }
    
}

