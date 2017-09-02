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
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.service]
        return touchBar
    }
}

fileprivate extension NSTouchBarItemIdentifier {
    static let service = NSTouchBarItemIdentifier("me.naonya3.NyozoClient.touchbar.service")
}

extension NyozoApp: NSTouchBarDelegate {
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.service:
            let custom = NSCustomTouchBarItem(identifier: .service)
            custom.customizationLabel = "TouchBar Catalog Label"
            let label = NSTextField.init(labelWithString: "Catalog")
            custom.view = label
            return custom
        default:
            return nil
        }
    }
    
    
}
