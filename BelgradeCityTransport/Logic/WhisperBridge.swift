//
//  WhisperBridge.swift
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremović on 1/31/16.
//  Copyright © 2016 Vladislav Jevremovic. All rights reserved.
//

import Foundation
import Whisper

@objc open class WhisperBridge: NSObject {

    static open func whisper(_ text: String, textColor: UIColor, backgroundColor: UIColor, toNavigationController: UINavigationController) {
        let message = Message(title: text, textColor: textColor, backgroundColor: backgroundColor)
        Whisper.show(whisper: message, to: toNavigationController)
    }

    static open func silent(_ toNavigationController: UINavigationController, silenceAfter: TimeInterval) {
        if silenceAfter > 0.1 {
            Whisper.hide(whisperFrom: toNavigationController, after: silenceAfter)
        }
    }
}
