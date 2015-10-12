//
//  SMGameEndViewController.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 9/24/15.
//  Copyright © 2015 Jonathon Toon. All rights reserved.
//

import UIKit

protocol SMGameEndViewControllerDelegate {
    
    func resetScene()
    
}

class SMGameEndViewController: UIViewController {

    var delegate: SMGameEndViewControllerDelegate!
    
    var endGameStats: NSDictionary!
    
    var shareButton: UIButton!
    var resetButton: UIButton!
    
    init(stats: NSDictionary) {
        super.init(nibName: nil, bundle: nil)
        
        self.endGameStats = stats
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.84)
        self.view.alpha = 0.0
        
        let faceImage = UIImageView(image: (self.endGameStats["flaggedMineCount"] as! Int) == (self.endGameStats["mineCount"] as! Int) ? UIImage(named: "happyface") : UIImage(named: "sadface"))
            faceImage.frame = CGRectMake(0, 0, 46.0, 46.0)
            faceImage.center = CGPointMake(self.view.center.x, self.view.center.y - (23.0 + 30.0))
        self.view.addSubview(faceImage)
        
        let timeTakenImage = UIImageView(image: UIImage(named: "clockIcon"))
            timeTakenImage.frame = CGRectMake(30.0, 29.0, 29.0, 29.0)
        self.view.addSubview(timeTakenImage)
        
        let timeTakenValue = UILabel()
            timeTakenValue.text = self.stringFromTimeInterval(self.endGameStats["timeTaken"] as! NSTimeInterval) as String
            timeTakenValue.font = UIFont.systemFontOfSize(19.0, weight: UIFontWeightHeavy)
            timeTakenValue.textColor = UIColor.whiteColor()
            timeTakenValue.sizeToFit()
            timeTakenValue.frame = CGRectMake((timeTakenImage.frame.origin.x + timeTakenImage.frame.size.width) + 10.0, 33.0, timeTakenValue.frame.size.width, timeTakenValue.frame.size.height)
        self.view.addSubview(timeTakenValue)
        
        let boardClaimedImage = UIImageView(image: UIImage(named: "percentageIcon"))
            boardClaimedImage.frame = CGRectMake((self.view.frame.size.width - 28.0) - 30.0, 30.0, 28.0, 28.0)
        self.view.addSubview(boardClaimedImage)
        
        let boardClaimedValue = UILabel()
            boardClaimedValue.text = (Int(CGFloat(self.endGameStats["revealedTileCount"] as! Int) / CGFloat(self.endGameStats["totalTiles"] as! Int) * 100)).description + "%"
            boardClaimedValue.font = UIFont.systemFontOfSize(19.0, weight: UIFontWeightHeavy)
            boardClaimedValue.textColor = UIColor.whiteColor()
            boardClaimedValue.textAlignment = .Right
            boardClaimedValue.frame = CGRectMake((boardClaimedImage.frame.origin.x - boardClaimedImage.frame.size.width) - 42.0, 33.0, 60.0, 23.0)
        self.view.addSubview(boardClaimedValue)

        var labelFrame = CGRectMake(0, 0, self.view.frame.size.width - 60.0, 150.0)
        let summaryLabel = UILabel(frame: labelFrame)
        
        let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 6.0
            paragraph.alignment = NSTextAlignment.Center
        
            let attributedParentString = NSMutableAttributedString(string: "You found ")
                attributedParentString.setAttributes([NSFontAttributeName : UIFont.systemFontOfSize(27.0), NSParagraphStyleAttributeName : paragraph], range: NSMakeRange(0, attributedParentString.length))
        
            for i in 0..<4 {
                
                var string = ""
                var attributes = [NSFontAttributeName : UIFont.systemFontOfSize(27.0), NSParagraphStyleAttributeName: paragraph]
                
                if i == 0 {
                    string = (self.endGameStats["flaggedMineCount"] as! Int).description
                    attributes = [NSFontAttributeName : UIFont.systemFontOfSize(27.0, weight: UIFontWeightHeavy)]
                } else if i == 1 {
                    string = " out \n of "
                } else if i == 2 {
                    string = (self.endGameStats["mineCount"] as! Int).description + " mines"
                    attributes = [NSFontAttributeName : UIFont.systemFontOfSize(27.0, weight: UIFontWeightHeavy)]
                } else {
                    string = "."
                }
                
                let attributedChildString = NSMutableAttributedString(string: string)
                    attributedChildString.setAttributes(attributes, range: NSMakeRange(0, attributedChildString.length))
                
                attributedParentString.appendAttributedString(attributedChildString)
            }
        
        
            summaryLabel.attributedText = attributedParentString
            summaryLabel.textColor = UIColor.whiteColor()
            summaryLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            summaryLabel.numberOfLines = 4
            summaryLabel.sizeToFit()
        
            labelFrame.size.height = summaryLabel.frame.size.height
            summaryLabel.frame = labelFrame
            summaryLabel.center = CGPointMake(self.view.center.x, faceImage.center.y + 75.0)
        
        self.view.addSubview(summaryLabel)
        
        let buttonWidth = (self.view.frame.size.width - 60.0)
        self.resetButton = UIButton(frame: CGRectMake(30.0, (self.view.frame.size.height - 46.0) - 30.0, buttonWidth, 46.0))
        self.resetButton.setTitle((self.endGameStats["flaggedMineCount"] as! Int) == (self.endGameStats["mineCount"] as! Int) ? "Play Again".uppercaseString : "Try Again".uppercaseString, forState: UIControlState.Normal)
        self.resetButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.resetButton.titleLabel?.font = UIFont.systemFontOfSize(18.0, weight: UIFontWeightHeavy)
        self.resetButton.backgroundColor = UIColor.clearColor()
        self.resetButton.layer.cornerRadius = 23.0
        self.resetButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.resetButton.layer.borderWidth = 3.0
        self.resetButton.addTarget(self, action: "startReset", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.resetButton)
    }

    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 1.0
        }, completion: nil)
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString! {
        
        let formatter = NSDateComponentsFormatter()
            formatter.allowedUnits = [NSCalendarUnit.Minute, NSCalendarUnit.Second]
            formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.Pad
        let string = formatter.stringFromTimeInterval(interval)
        
        return string
    }
    
    func startReset() {
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0.0
        }, completion: {
        
            finished in
            
            if let delegate = self.delegate {
                delegate.resetScene()
            }
        
            self.dismissViewControllerAnimated(false, completion: nil)
            
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
