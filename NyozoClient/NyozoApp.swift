//
//  NyozoApp.swift
//  NyozoClient
//
//  Created by Naoto Horiguchi on 2017/08/31.
//  Copyright © 2017年 naonya3. All rights reserved.
//

import Cocoa

class NyozoApp: NSApplication {
    let strongDelegate = AppDelegate()
    override init() {
        super.init()
        self.delegate = strongDelegate
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
