//
//  SMGameScene.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 8/11/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import SpriteKit
import UIColor_Hex_Swift
import DeviceGuru
import AVFoundation
import AudioToolbox

protocol SMGameSceneDelegate {
    
    func gameDidEnd()
    
}

extension SKScene {
    
    func resizeToFitChildNodes() {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for someSprite in self.children {
            let shapeNode = someSprite 
            let newWidth = shapeNode.frame.origin.x + shapeNode.frame.width
            let newHeight = shapeNode.frame.origin.y + shapeNode.frame.height
            width = max(width, newWidth)
            height = max(height, newHeight)
        }
        
        size = CGSizeMake(width, height)
    }
    
}

class SMGameScene: SKScene {
   
    var containerView: SKSpriteNode!
    var board: SMGame!
    var boardTextures: [SKTexture]!
    var boardSprites: [[SMTileSprite]] = []
    
    var touchDownSound: AVAudioPlayer!
    var touchUpSound: AVAudioPlayer!
    var bombExplodeSound: AVAudioPlayer!
    
    var lastTouchedSprite: SMTileSprite!
    var longPressTimer: NSTimer!
    
    var gameTimer: NSTimer!
    var gameTime: NSTimeInterval = 0
    
    var gameEnded: Bool = false

    override func willMoveFromView(view: SKView) {
        SKTexture.preloadTextures(self.boardTextures, withCompletionHandler: {
        
        })
    }
    
    override func didMoveToView(view: SKView) {
        
        let deviceType: String = DeviceGuru.hardwareDescription()!
        
        if deviceType.containsString("iPhone 4") || deviceType.containsString("iPhone 5") {
            
            self.boardTextures = [SKTexture(imageNamed: "bombMaskSmall"), SKTexture(imageNamed: "flagMaskSmall")]
            
        } else if deviceType.containsString("iPhone 6") {
            
            if deviceType.containsString("iPhone 6 Plus") {
                self.boardTextures = [SKTexture(imageNamed: "bombMaskLarge"), SKTexture(imageNamed: "flagMaskLarge")]
            } else {
                self.boardTextures = [SKTexture(imageNamed: "bombMaskMedium"), SKTexture(imageNamed: "flagMaskMedium")]
            }
            
        }

        self.touchDownSound = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSString(format: "%@/tapMellow.wav", NSBundle.mainBundle().resourcePath!) as String))
        self.touchUpSound = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSString(format: "%@/tapMellow.wav", NSBundle.mainBundle().resourcePath!) as String))

        self.bombExplodeSound = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSString(format: "%@/tapMellowUp.wav", NSBundle.mainBundle().resourcePath!) as String))
        
        // Setup Model
        let rows: Int = 8
        let squareSize = (self.view!.frame.size.width - CGFloat(rows)) / CGFloat(rows)
        let columns = Int((self.view!.frame.size.height - CGFloat(rows)) / squareSize)
        self.board = SMGame(numberOfRows: rows, numberOfColumns: columns, tileSize: squareSize)
        
        self.backgroundColor = UIColor(rgba: self.board.theme.getCurrentTheme().backgroundColor)
        
        var xPosition: CGFloat = 0
        var yPosition: CGFloat = xPosition
        
        // Setup Sprites
        for y in 0..<self.board.tiles.count {
            
            var boardSpriteRow: [SMTileSprite] = []
            
            for x in 0..<self.board.tiles[y].count {
                
                let sprite = SMTileSprite(
                    forTile: self.board.tiles[y][x],
                    gradient: self.board.theme.currentThemeGradient.cellGradients[y][x],
                    backgroundColor: self.backgroundColor,
                    bombColor: UIColor(rgba: self.board.theme.getCurrentTheme().bombColor),
                    bombTexture: self.boardTextures[0],
                    flagTexture: self.boardTextures[1],
                    tileSize: CGSizeMake(ceil(self.board.tileSize), ceil(self.board.tileSize)),
                    tilePosition: CGPointMake(xPosition + self.board.tileSize/2, yPosition + self.board.tileSize/2)
                )
                
                self.addChild(sprite)
                
                boardSpriteRow.append(sprite)
                
                xPosition += self.board.tileSize
            }
            
            xPosition = 0
            yPosition += self.board.tileSize
            
            self.boardSprites.append(boardSpriteRow)
        }
        
        // Resize Scene
        self.resizeToFitChildNodes()
        
        self.touchDownSound!.prepareToPlay()
        self.touchUpSound!.prepareToPlay()
        self.bombExplodeSound!.prepareToPlay()
        
        self.gameTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "pauseTimer:", name: UIApplicationWillResignActiveNotification, object: nil)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumeTimer:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
        
    func reloadSprites() {
        var xPosition: CGFloat = 0
        var yPosition: CGFloat = xPosition
        
        self.boardSprites = []
        self.removeAllChildren()
        
        // Draw Sprites
        for y in 0..<self.board.tiles.count {
            
            var boardSpriteRow: [SMTileSprite] = []
            
            for x in 0..<self.board.tiles[y].count {
                
                let sprite = SMTileSprite(
                    forTile: self.board.tiles[y][x],
                    gradient: self.board.theme.currentThemeGradient.cellGradients[y][x],
                    backgroundColor: self.backgroundColor,
                    bombColor: UIColor(rgba: self.board.theme.getCurrentTheme().bombColor),
                    bombTexture: self.boardTextures[0],
                    flagTexture: self.boardTextures[1],
                    tileSize: CGSizeMake(ceil(self.board.tileSize), ceil(self.board.tileSize)),
                    tilePosition: CGPointMake(xPosition + self.board.tileSize/2, yPosition + self.board.tileSize/2)
                )
                
                self.addChild(sprite)
                
                boardSpriteRow.append(sprite)
                
                xPosition += self.board.tileSize
            }
            
            xPosition = 0
            yPosition += self.board.tileSize
            
            self.boardSprites.append(boardSpriteRow)
        }
        
        self.gameTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        self.gameTime = 0
    }

    func resetBoard() {
        
        self.board.resetBoard()
        self.gameEnded = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if !self.gameEnded {
            let location = touches.first!.locationInNode(self)
            let tiles = self.nodesAtPoint(location)
            
            for tile in tiles {
                    
                if tile.isKindOfClass(SMTileSprite) {
                    
                    let mineTile: SMTileSprite = tile as! SMTileSprite
                    
                    if !mineTile.tile.isRevealed {
                        self.touchDownSound!.play()

                        self.lastTouchedSprite = mineTile
                        self.longPressTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("addFlagToTile"), userInfo: nil, repeats: false)
                        
                        let scaleAction = SKAction.scaleTo(0.9, duration: 0.1)
                        mineTile.runAction(scaleAction)
                        break
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.longPressTimer.invalidate()
        
        if !self.lastTouchedSprite.tile.isRevealed {
                
            if !self.lastTouchedSprite.tile.isMineLocation {
                
                self.touchUpSound!.play()
                self.revealTileSprite(self.lastTouchedSprite)
             } else {
                
                self.bombExplodeSound!.play()
                self.revealAllTilesWithBombs()
            }
        }
        
        let scaleAction = SKAction.scaleTo(1.0, duration: 0.15)
        self.lastTouchedSprite.runAction(scaleAction)
    }
   
    func revealTileSprite(tileSprite: SMTileSprite!) {
        
        if !tileSprite.tile.isRevealed && !tileSprite.tile.isFlagged {
            tileSprite.tile.isRevealed = true
            
            let distanceFromStartingPoint = abs(tileSprite.tile.row-self.lastTouchedSprite.tile.row)+abs(tileSprite.tile.column-self.lastTouchedSprite.tile.column)
            
            if distanceFromStartingPoint > 0 {
                tileSprite.updateSpriteTile(NSTimeInterval(CGFloat(distanceFromStartingPoint)*0.05))
            } else {
                tileSprite.updateSpriteTile()
            }
            
            self.revealAdjacentTiles(tileSprite)
        }  

    }
    
    func revealAdjacentTiles(tileSprite: SMTileSprite!) {
        
        if tileSprite.tile.numNeighboringMines == 0 {
            
            let neighboringTiles = self.board.getNeighboringTiles(tileSprite.tile, includingDiagonal: false)
            
            for tile in neighboringTiles {
                
                let adjacentTileSprite = self.boardSprites[tile.column][tile.row] as SMTileSprite
                self.revealTileSprite(adjacentTileSprite)
            }
        }
    }
    
    func revealAllTilesWithBombs() {
        
        for y in 0..<self.board.columns {
            
            for x in 0..<self.board.rows {
                
                let currentTileSprite = self.boardSprites[y][x] as SMTileSprite
               
                if currentTileSprite.tile.isMineLocation {
    
                    currentTileSprite.tile.isRevealed = true
                    currentTileSprite.updateSpriteTile()
                    
                }
            }
        }
        
        if let delegate = (self.delegate as? SMGameViewController) {
            self.gameEnded = true
            self.gameTimer.invalidate()
            delegate.gameDidEnd()
        }
    }
    
    func addFlagToTile() {
        
        if !self.lastTouchedSprite.tile.isFlagged && !self.lastTouchedSprite.tile.isRevealed {
                
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            self.lastTouchedSprite.tile.isFlagged = true
            self.lastTouchedSprite.tile.isRevealed = true
            
            self.lastTouchedSprite.updateSpriteTile()
            
            let boardResults = self.board.getCurrentBoardResults()
            
            if boardResults[0] == boardResults[2] {
                if let delegate = (self.delegate as? SMGameViewController) {
                    self.gameEnded = true
                    self.gameTimer.invalidate()
                    delegate.gameDidEnd()
                }
            }

        }
    }
    
    func resetScene(){
        
        for y in 0..<self.board.columns {
            
            for x in 0..<self.board.rows {
                
                let currentTileSprite = self.boardSprites[y][x] as SMTileSprite
                
                let distanceFromStartingPoint = abs(currentTileSprite.tile.row-(self.board.rows/2))+abs(currentTileSprite.tile.column-(self.board.columns/2))
                currentTileSprite.updateSpriteTile(NSTimeInterval(CGFloat(distanceFromStartingPoint)*0.020))
            }
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.45, target: self, selector: Selector("reloadSprites"), userInfo: nil, repeats: false)
    }
    
    func updateTime() {
        self.gameTime += 1
    }
    
    // NSNotificationCenter callbacks
    
    func pauseTimer(notification: NSNotification!) {
        if self.gameTimer != nil {
            self.gameTimer.invalidate()
        }
    }
    
    func resumeTimer(notification: NSNotification!) {
        
        if self.gameTimer != nil {
            
            self.gameTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        }
    }
}
