//
//  SMGameViewController.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 8/11/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit
import SpriteKit
import AudioToolbox

class SMGameViewController: UIViewController, SKSceneDelegate, SMGameEndViewControllerDelegate {

    var gameScene: SMGameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let skView = SKView(frame: self.view.bounds)
        self.view = skView
        
        if skView.scene == nil {
      
            self.gameScene = SMGameScene(size: skView.bounds.size)
            self.gameScene.scaleMode = .AspectFit
            self.gameScene.delegate = self
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            skView.presentScene(self.gameScene)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.gameScene.resetScene()
        }
    }
    
    // SMGameSceneDelegate
    
    func gameDidEnd() {

        let finalBoardResults = self.gameScene.board.getCurrentBoardResults()
        
        let gameStats = [
            "timeTaken"          : self.gameScene.gameTime,
            "mineCount"          : finalBoardResults[0],
            "flagCount"          : finalBoardResults[1],
            "flaggedMineCount"   : finalBoardResults[2],
            "revealedTileCount"  : finalBoardResults[3],
            "totalTiles"         : self.gameScene.board.columns * self.gameScene.board.rows
        ]
        
        self.gameScene.resetBoard()
        
        let gameEndedViewController = SMGameEndViewController(stats: gameStats)
            gameEndedViewController.delegate = self
            gameEndedViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        self.presentViewController(gameEndedViewController, animated: true, completion: nil)
    }
    
    // SMGameEndViewControllerDelegate
    
    func resetScene() {
        self.gameScene.resetScene()
    }
}
