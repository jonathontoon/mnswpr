//
//  Utilities.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 8/22/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
