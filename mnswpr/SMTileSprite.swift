//
//  SMTileSprite.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 8/16/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit
import SpriteKit
import DeviceGuru

class SMTileSprite: SKSpriteNode {

    var tile: SMTile!
    var gradientLayer: CAGradientLayer!
    var gradientSprite: SKSpriteNode!
    var textSprite: SKLabelNode!
    var flagSprite: SKSpriteNode!
    var bombSprite: SKSpriteNode!

    init(forTile tile: SMTile, gradient: CAGradientLayer!, backgroundColor: UIColor!, bombColor: UIColor!, bombTexture: SKTexture!, flagTexture: SKTexture!, tileSize size: CGSize!, tilePosition position: CGPoint) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        
        self.tile = tile

        self.gradientLayer = gradient
        
        self.size = size
        self.position = position
        
        self.gradientSprite = SKSpriteNode(texture: SKTexture(CGImage: self.createImageFromGradient(size, withLayer: self.gradientLayer, withMask: nil)), color: UIColor.clearColor(), size: size)
        self.gradientSprite.userInteractionEnabled = false
        
        self.addChild(self.gradientSprite)
        
        if self.tile.numNeighboringMines > 0 && !self.tile.isMineLocation {
        
            self.textSprite = self.createTextSprite()
            self.addChild(self.textSprite)
        }
        
        self.bombSprite = self.createBombSpriteWithTexture(bombTexture, backgroundColor: backgroundColor, bombColor: bombColor)
        self.addChild(self.bombSprite)
        
        self.flagSprite = self.createFlagSpriteWithTexture(flagTexture, backgroundColor: backgroundColor, flagColor: bombColor)
        self.addChild(self.flagSprite)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createTextSprite() -> SKLabelNode {
        
        let deviceType: String = DeviceGuru.hardwareDescription()!
        
        var labelPosition: CGPoint! = self.tile.numNeighboringMines > 1 ? CGPointMake(0.5, -6.5) : CGPointMake(0, -6.5)
        
        // Is iPhone4S or 5/S/C
        if deviceType.containsString("iPhone 4") {
            labelPosition = self.tile.numNeighboringMines > 1 ? CGPointMake(0.75, -7.5) : CGPointMake(0, -7)
        } else if deviceType.containsString("iPhone 5") {
            labelPosition = CGPointMake(1, -7)
        }
        
        let label = SKLabelNode(text: self.tile.numNeighboringMines.description)
        label.fontSize = 19.0
        label.fontName = "AvenirNext-Bold"
        label.userInteractionEnabled = false
        label.position = labelPosition
        
        if let colors = self.gradientLayer.colors {
            label.fontColor = UIColor(CGColor: colors[0] as! CGColor)
        }
        
        label.alpha = 0.0
        
        return label
    }

    func createBombSpriteWithTexture(texture: SKTexture!, backgroundColor: UIColor!, bombColor: UIColor!) -> SKSpriteNode {

        let bombLayer = CALayer()
            bombLayer.frame.size = self.size
            bombLayer.backgroundColor = bombColor.CGColor
        
        let bombBackground = SKSpriteNode(texture: SKTexture(CGImage: self.createImageFromGradient(size, withLayer: bombLayer, withMask: nil)), color: bombColor, size: self.size)
            bombBackground.position = CGPointMake(0, 0)
            bombBackground.alpha = 0.0
            bombBackground.zPosition = 1.0
        
        let bombSprite = SKSpriteNode(texture: texture, color: bombColor, size: self.size)
            bombSprite.alpha = 1.0
            bombSprite.zPosition = 1.0
            
            bombBackground.addChild(bombSprite)
        
        return bombBackground
    }
    
    func createFlagSpriteWithTexture(texture: SKTexture!, backgroundColor: UIColor!, flagColor: UIColor!) -> SKSpriteNode {

        let flagLayer = CALayer()
            flagLayer.frame.size = self.size
            flagLayer.backgroundColor = flagColor.CGColor
        
        let flagBackground = SKSpriteNode(texture: SKTexture(CGImage: self.createImageFromGradient(self.size, withLayer: flagLayer, withMask: nil)), color: flagColor, size: self.size)
            flagBackground.position = CGPointMake(0, 0)
            flagBackground.alpha = 0.0
            flagBackground.zPosition = 1.0
        
        let flagSprite = SKSpriteNode(texture: texture, color: flagColor, size: self.size)
            flagSprite.alpha = 1.0
            flagSprite.zPosition = 1.0
        
            flagBackground.addChild(flagSprite)
        
        return flagBackground
    }
    
    func createImageFromGradient(size: CGSize!, withLayer layer:CALayer!, withMask mask:UIImage?) -> CGImageRef {
        
        let gradientLayer = layer
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        gradientLayer.frame = CGRectIntegral(CGRectMake(0,0, size.width, size.height))
        gradientLayer.renderInContext(context!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if mask != nil {

            let maskRef = mask!.CGImage
            let maskCreated = CGImageMaskCreate(CGImageGetWidth(maskRef),
                CGImageGetHeight(maskRef),
                CGImageGetBitsPerComponent(maskRef),
                CGImageGetBitsPerPixel(maskRef),
                CGImageGetBytesPerRow(maskRef),
                CGImageGetDataProvider(maskRef), nil, false
            )
            
            let maskedImageRef = CGImageCreateWithMask(gradientImage.CGImage, maskCreated)
            let maskedImage = UIImage(CGImage: maskedImageRef!)
            
            // returns new image with mask applied
            return maskedImage.CGImage!
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let scaledSize = ceil(size.width*0.89)
        let rect = CGRectIntegral(CGRectMake(3, 2, scaledSize, scaledSize))
        CGContextSetShouldAntialias(context, true)
        let rectPath = UIBezierPath(roundedRect: rect, cornerRadius: size.width/2)
        rectPath.addClip()
        gradientImage.drawInRect(rect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage.CGImage!
        
    }
    
    func updateSpriteTile(duration:NSTimeInterval = 0.15) {
        
        var fadeAlphaTo: CGFloat = 1.0
        
        if self.tile.isRevealed {
            
            if !self.tile.isFlagged {
            
                if self.tile.numNeighboringMines == 1 {
                    fadeAlphaTo = 0.18
                } else if self.tile.numNeighboringMines == 2 {
                    fadeAlphaTo = 0.28
                } else if self.tile.numNeighboringMines >= 3 {
                    fadeAlphaTo = 0.4
                } else {
                    fadeAlphaTo = 0.05
                }

            }
            
            let alphaAnimation = SKAction.fadeAlphaTo(fadeAlphaTo, duration: 0.15)
            let delayAnimation = SKAction.waitForDuration(duration)
            self.gradientSprite.runAction(SKAction.sequence([delayAnimation, alphaAnimation]))
            
            if self.textSprite != nil && !self.tile.isFlagged {
                self.textSprite.runAction(SKAction.sequence([delayAnimation, SKAction.fadeAlphaTo(1.0, duration: 0.15)]))
            } else if self.tile.isFlagged {
                
                if let flagSprite = self.flagSprite {
                    flagSprite.runAction(SKAction.sequence([delayAnimation, SKAction.fadeAlphaTo(1.0, duration: 0.15)]))
                }
            
            } else if self.tile.isMineLocation {
                self.bombSprite.runAction(SKAction.sequence([delayAnimation, SKAction.fadeAlphaTo(1.0, duration: 0.15)]))
            }
        
        } else {
            
            let alphaAnimation = SKAction.fadeAlphaTo(1.0, duration: 0.1)
            let delayAnimation = SKAction.waitForDuration(duration)
            let textureAnimation = SKAction.animateWithTextures([SKTexture(CGImage: self.createImageFromGradient(self.gradientSprite.size, withLayer: self.gradientLayer, withMask: nil))], timePerFrame: 0.1)
            self.gradientSprite.runAction(SKAction.sequence([delayAnimation, textureAnimation, alphaAnimation]))
            
            if let flagSprite = self.flagSprite {
                flagSprite.runAction(SKAction.sequence([delayAnimation, SKAction.fadeAlphaTo(0.0, duration: 0.1)]))
            }
            
            if let bombSprite = self.bombSprite {
                bombSprite.runAction(SKAction.sequence([delayAnimation, SKAction.fadeAlphaTo(0.0, duration: 0.1)]))
            }
            
            if let textSprite = self.textSprite {
                textSprite.runAction(SKAction.sequence([delayAnimation, SKAction.fadeAlphaTo(0.0, duration: 0.1)]))
            }
            
        }
    }
}
