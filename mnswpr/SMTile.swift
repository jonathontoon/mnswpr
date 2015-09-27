//
//  SMTile.swift
//  MinimalMine
//
//  Created by Jonathon Toon on 7/18/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import Foundation

class SMTile {
    
    let row:Int
    let column:Int
    
    // give these default values that we will re-assign later with each new game
    var numNeighboringMines = 0
    var isMineLocation = false
    var isRevealed = false
    var isFlagged = false
    
    init(row:Int, col:Int) {
        //store the row and column of the square in the grid
        self.row = row
        self.column = col
    }
}