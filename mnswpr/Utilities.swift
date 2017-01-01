//
//  Utilities.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 8/22/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
