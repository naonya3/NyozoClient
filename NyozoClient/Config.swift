//
//  Config.swift
//  NyozoClient
//
//  Created by Naoto Horiguchi on 2017/09/04.
//  Copyright © 2017年 naonya3. All rights reserved.
//

import Foundation

typealias ConfigJson = Dictionary<String, Any>
/*
 // CONFIG JSON
 {
 "services":    [ServiceJson]
 }
 */

typealias ServiceJson = Dictionary<String, Any>
/*
 // SERVICE JSON
 {
 "identifier":  String,
 "url":         String,
 "authType":    String? (none, nyozo, basic) default = none
 "name":        String? (basic user, nyozo service name) default = identifier
 "password":    String?
 "userAgent":   String?
 "loginUrl":    String? required if authType == nyozo
 }
 */

struct Config {
    let services: [Service]
    static func parse(json: ConfigJson) -> Config? {
        guard let services = json["services"] as? Array<ServiceJson> else {
            print("invalid config json")
            return nil
        }
        var arr = [Service]()
        for s in services {
            if let service = Service.parse(json: s) {
                arr.append(service)
            } else {
                print("invalid service json")
                continue
            }
        }
        return Config(services: arr)
    }
}

struct Service {
    let identifier: String
    let url: URL // upload url
    let authType: AuthType // default .none
    let name: String // Basic user name or Nyozo service name(default = identifier)
    let userAgent: String? // custom user agent
    let token: String? // あとで消す
    static func parse(json: ServiceJson) -> Service? {
        guard let identifier = json["identifier"] as? String else {
            return nil
        }
        guard let urlStr = json["url"] as? String , let url = URL(string: urlStr) else {
            return nil
        }
        let authType = AuthType.parse(json: json)
        let name = json["name"] as? String ?? identifier
        let userAgent = json["userAgent"] as? String
        let token = json["token"] as? String
        return Service(identifier: identifier, url: url, authType: authType, name: name, userAgent: userAgent, token: token)
    }
}

enum AuthType {
    case none
    case nyozo(loginURL:URL, password:String)
    case basic(password: String)
    static func parse(json: ServiceJson) -> AuthType {
        guard let authType = json["authType"] as? String else {
            return .none
        }
        guard let password = json["password"] as? String else {
            print("require password")
            return .none
        }
        switch authType {
        case "nyozo":
            if let urlStr = json["loginURL"] as? String, let url = URL(string: urlStr) {
                return .nyozo(loginURL: url, password: password)
            }
            print("invalid login url")
            return .none
        case "basic":
            return .basic(password: password)
        default:
            print("invalid authType")
            return .none
        }
    }
}


