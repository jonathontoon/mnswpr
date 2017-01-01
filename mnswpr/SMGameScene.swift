//
//  SMGameScene.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 8/11/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import SpriteKit
import UIColor_Hex_Swift
import DeviceKit
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
        
        size = CGSize(width: width, height: height)
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
    var longPressTimer: Timer!
    
    var gameTimer: Timer!
    var gameTime: TimeInterval = 0
    
    var gameEnded: Bool = false

    override func willMove(from view: SKView) {
        SKTexture.preload(self.boardTextures, withCompletionHandler: {
        })
    }
    
    override func didMove(to view: SKView) {
        
        let isSmallDevice = Device().isOneOf([.iPodTouch5, .iPodTouch5, .iPhone4, .iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE, .simulator(.iPodTouch5), .simulator(.iPodTouch5), .simulator(.iPhone4), .simulator(.iPhone4s), .simulator(.iPhone5), .simulator(.iPhone5c), .simulator(.iPhone5s), .simulator(.iPhoneSE)]) || Device().isPad
        let isMediumDevice = Device().isOneOf([.iPhone6, .iPhone6s, .iPhone7, .simulator(.iPhone6), .simulator(.iPhone6s), .simulator(.iPhone7)])
        let isLargeDevice = Device().isOneOf([.iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .simulator(.iPhone6Plus), .simulator(.iPhone6sPlus), .simulator(.iPhone7Plus)])
        
        if isSmallDevice {
            self.boardTextures = [SKTexture(imageNamed: "bombMaskSmall"), SKTexture(imageNamed: "flagMaskSmall")]
        } else if isMediumDevice {
            self.boardTextures = [SKTexture(imageNamed: "bombMaskMedium"), SKTexture(imageNamed: "flagMaskMedium")]
        } else if isLargeDevice {
             self.boardTextures = [SKTexture(imageNamed: "bombMaskLarge"), SKTexture(imageNamed: "flagMaskLarge")]
        }

        self.touchDownSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: NSString(format: "%@/tapMellow.wav", Bundle.main.resourcePath!) as String))
        self.touchUpSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: NSString(format: "%@/tapMellow.wav", Bundle.main.resourcePath!) as String))

        self.bombExplodeSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: NSString(format: "%@/tapMellowUp.wav", Bundle.main.resourcePath!) as String))
        
        // Setup Model
        let rows: Int = 8
        let squareSize = (self.view!.frame.size.width - CGFloat(rows)) / CGFloat(rows)
        let columns = Int((self.view!.frame.size.height - CGFloat(rows)) / squareSize)
        self.board = SMGame(numberOfRows: rows, numberOfColumns: columns, tileSize: squareSize)
        
        self.backgroundColor = UIColor(self.board.theme.getCurrentTheme().backgroundColor)
        
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
                    bombColor: UIColor(self.board.theme.getCurrentTheme().bombColor),
                    bombTexture: self.boardTextures[0],
                    flagTexture: self.boardTextures[1],
                    tileSize: CGSize(width: ceil(self.board.tileSize), height: ceil(self.board.tileSize)),
                    tilePosition: CGPoint(x: xPosition + self.board.tileSize/2, y: yPosition + self.board.tileSize/2)
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
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
                
        }
        
        self.touchDownSound!.prepareToPlay()
        self.touchUpSound!.prepareToPlay()
        self.bombExplodeSound!.prepareToPlay()
        
        self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SMGameScene.updateTime), userInfo: nil, repeats: true)
        
         NotificationCenter.default.addObserver(self, selector: #selector(SMGameScene.pauseTimer(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(SMGameScene.resumeTimer(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
                    bombColor: UIColor(self.board.theme.getCurrentTheme().bombColor),
                    bombTexture: self.boardTextures[0],
                    flagTexture: self.boardTextures[1],
                    tileSize: CGSize(width: ceil(self.board.tileSize), height: ceil(self.board.tileSize)),
                    tilePosition: CGPoint(x: xPosition + self.board.tileSize/2, y: yPosition + self.board.tileSize/2)
                )
                
                self.addChild(sprite)
                
                boardSpriteRow.append(sprite)
                
                xPosition += self.board.tileSize
            }
            
            xPosition = 0
            yPosition += self.board.tileSize
            
            self.boardSprites.append(boardSpriteRow)
        }
        
        self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SMGameScene.updateTime), userInfo: nil, repeats: true)
        self.gameTime = 0
    }

    func resetBoard() {
        
        self.board.resetBoard()
        self.gameEnded = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if !self.gameEnded {
            let location = touches.first!.location(in: self)
            let tiles = self.nodes(at: location)
            
            for tile in tiles {
                    
                if tile.isKind(of: SMTileSprite.self) {
                    
                    let mineTile: SMTileSprite = tile as! SMTileSprite
                    
                    if !mineTile.tile.isRevealed {
                        self.touchDownSound!.play()

                        self.lastTouchedSprite = mineTile
                        self.longPressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SMGameScene.addFlagToTile), userInfo: nil, repeats: false)
                        
                        let scaleAction = SKAction.scale(to: 0.9, duration: 0.1)
                        mineTile.run(scaleAction)
                        break
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
        
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.15)
        self.lastTouchedSprite.run(scaleAction)
    }
   
    func revealTileSprite(_ tileSprite: SMTileSprite!) {
        
        if !tileSprite.tile.isRevealed && !tileSprite.tile.isFlagged {
            tileSprite.tile.isRevealed = true
            
            let distanceFromStartingPoint = abs(tileSprite.tile.row-self.lastTouchedSprite.tile.row)+abs(tileSprite.tile.column-self.lastTouchedSprite.tile.column)
            
            if distanceFromStartingPoint > 0 {
                tileSprite.updateSpriteTile(TimeInterval(CGFloat(distanceFromStartingPoint)*0.05))
            } else {
                tileSprite.updateSpriteTile()
            }
            
            self.revealAdjacentTiles(tileSprite)
        }  

    }
    
    func revealAdjacentTiles(_ tileSprite: SMTileSprite!) {
        
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
                currentTileSprite.updateSpriteTile(TimeInterval(CGFloat(distanceFromStartingPoint)*0.020))
            }
        }
        
        Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(SMGameScene.reloadSprites), userInfo: nil, repeats: false)
    }
    
    func updateTime() {
        self.gameTime += 1
    }
    
    // NSNotificationCenter callbacks
    
    func pauseTimer(_ notification: Notification!) {
        if self.gameTimer != nil {
            self.gameTimer.invalidate()
        }
    }
    
    func resumeTimer(_ notification: Notification!) {
        
        if self.gameTimer != nil {
            
            self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SMGameScene.updateTime), userInfo: nil, repeats: true)
        }
    }
}
