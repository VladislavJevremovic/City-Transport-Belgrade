//
//  WhisperBridge.swift
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremović on 1/31/16.
//  Copyright © 2016 Vladislav Jevremovic. All rights reserved.
//

import Foundation
import Whisper

@objc public class WhisperBridge: NSObject {

    static public func whisper(text: String, textColor: UIColor, backgroundColor: UIColor, toNavigationController: UINavigationController) {
        let message = Message(title: text, textColor: textColor, backgroundColor: backgroundColor)
        Whisper(message, to: toNavigationController)
    }

    static public func silent(toNavigationController: UINavigationController, silenceAfter: NSTimeInterval) {
        if silenceAfter > 0.1 {
            Silent(toNavigationController, after: silenceAfter)
        }
    }

}