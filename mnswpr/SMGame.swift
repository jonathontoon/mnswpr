//
//  SMGame.swift
//  MinimalMine
//
//  Created by Jonathon Toon on 7/18/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit

class SMGame {

    let rows:Int
    let columns:Int
    let tileSize:CGFloat
    
    let theme: SMThemeController
    
    var tiles:[[SMTile]] = []
    
    init(numberOfRows rows:Int, numberOfColumns columns:Int, tileSize size:CGFloat) {
        
        self.rows = rows
        self.columns = columns
        self.tileSize = size
        
        self.theme = SMThemeController(initialTheme: "Royal", numberOfRows: self.rows, numberOfColumns: self.columns)

        // create tile data model for each cell
        for c in 0..<self.columns {
            var tileRow:[SMTile] = []
            
            for r in 0..<self.rows {
             
                let tile = SMTile(row: r, col: c)
                tileRow.append(tile)
                
            }
            
            tiles.append(tileRow)
        }
        
        self.resetBoard()
    }
    
    func resetBoard() {
     
        // assign mines to tiles
        for c in 0..<self.columns {
            for r in 0..<self.rows {
                self.tiles[c][r].isRevealed = false
                self.tiles[c][r].isFlagged = false
                self.calculateIsMineLocationForTile(tiles[c][r])
            }
        }
        
        // count number of neighboring tiles
        for c in 0..<self.columns {
            for r in 0..<self.rows {
                self.calculateNumNeighborMinesForTile(tiles[c][r])
            }
        }
        
    }

    // algorithm for deciding whether object will contain a mine
    func calculateIsMineLocationForTile(_ tile: SMTile) {
        tile.isMineLocation = (arc4random_uniform(10) == 0) // 1-in-7 chance that each location contains a mine
    }
    
    // how many cell adjacent to this one contain a mine
    func calculateNumNeighborMinesForTile(_ tile : SMTile) {
        
        // first get a list of adjacent tiles
        let neighbors = getNeighboringTiles(tile, includingDiagonal: true)
        var numNeighboringMines = 0
        
        // for each neighbor with a mine, add 1 to this tile's count
        for neighbortile in neighbors {
            if neighbortile.isMineLocation {
                numNeighboringMines += 1
            }
        }
        
        tile.numNeighboringMines = numNeighboringMines
    }
    
    // get array of neighboring cells' tile objects
    func getNeighboringTiles(_ tile: SMTile!, includingDiagonal isDiagonal: Bool!) -> [SMTile] {
        var neighbors:[SMTile] = []
        
        // an array of tuples containing the relative position of each neighbor to the tile
        var adjacentOffsets = [
            (0,-1), (-1,0), (1,0), (0,1)
        ]
        
        if isDiagonal == true {
            adjacentOffsets = [
                (-1,-1), (0,-1), (1,-1),
                (-1,0), (1,0),
                (-1,1), (0,1), (1,1)
            ]
        }
        
        for (rowOffset,colOffset) in adjacentOffsets {
            // getTileAtLocation might return a tile, or it might return nil, so use the optional datatype "?"
            let optionalNeighbor:SMTile? = getObjectAtLocation(tile.row+rowOffset, col: tile.column+colOffset)
            // only evaluates true if the optional tile isn't nil
            if let neighbor = optionalNeighbor {
                neighbors.append(neighbor)
            }
        }
        
        return neighbors
    }
    
    // return a tile object for a particular cell location
    func getObjectAtLocation(_ row: Int, col: Int) -> SMTile? {
        if row >= 0 && row < self.rows && col >= 0 && col < self.columns {
            return tiles[col][row]
        } else {
            return nil
        }
    }
    
    func getCurrentBoardResults() -> [Int] {
    
        var mineCount: Int = 0
        var flagCount: Int = 0
        var flaggedMineCount: Int = 0
        var revealedTileCount: Int = 0
        
        for c in 0..<self.columns {
            for r in 0..<self.rows {
                
                if self.tiles[c][r].isFlagged {
                    flagCount += 1
                    
                }
                
                if self.tiles[c][r].isMineLocation {
                    
                    mineCount += 1
                    
                }
                
                if self.tiles[c][r].isFlagged && self.tiles[c][r].isMineLocation {
                    flaggedMineCount += 1
                }
                
                if self.tiles[c][r].isRevealed {
                    revealedTileCount += 1
                }
                
            }
        }
    
        
        return [mineCount, flagCount, flaggedMineCount, revealedTileCount]
    }
}

