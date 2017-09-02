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
    var url: String?
    var token: String?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setup()
        let cmd = "/usr/sbin/screencapture"
        let task = Process()
        task.launchPath = cmd
        task.arguments = ["-i","-c","tmp.png"]
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
    
    func setup() {
        do {
            let jsonData = try Data(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".nyozo/config").appendingPathExtension("json"))
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            guard let dict = json as? Dictionary<String, Any> else { fatalError("invalid config.json") }
            guard let services = dict["services"] as? Array<Dictionary<String, Any>> else { fatalError("invalid config.json") }
            url = services.first?["url"] as? String
            token = services.first?["token"] as? String
        } catch(let e) {
            print(e)
        }
    }
    
    func post(_ image: Data) {
        guard let urlStr = self.url, let url = URL(string: urlStr) else { fatalError("invalid url") }
        
        let request = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "POST"
        request.timeoutInterval = 30.0
        request.setValue("Gyazo", forHTTPHeaderField: "User-Agent")
        
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
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request as URLRequest) { (data, r, e) in
            if let d = data, let str = String(data:d, encoding: .utf8), let url = URL(string: str) {
                NSWorkspace.shared().open(url)
            }
            NSApp.terminate(nil)
        }
        task.resume()
    }
    
}

