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
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.84)
        self.view.alpha = 0.0
        
        let faceImage = UIImageView(image: (self.endGameStats["flaggedMineCount"] as! Int) == (self.endGameStats["mineCount"] as! Int) ? UIImage(named: "happyface") : UIImage(named: "sadface"))
            faceImage.frame = CGRect(x: 0, y: 0, width: 46.0, height: 46.0)
            faceImage.center = CGPoint(x: self.view.center.x, y: self.view.center.y - (23.0 + 30.0))
        self.view.addSubview(faceImage)
        
        let timeTakenImage = UIImageView(image: UIImage(named: "clockIcon"))
            timeTakenImage.frame = CGRect(x: 30.0, y: 29.0, width: 29.0, height: 29.0)
        self.view.addSubview(timeTakenImage)
        
        let timeTakenValue = UILabel()
            timeTakenValue.text = self.stringFromTimeInterval(self.endGameStats["timeTaken"] as! TimeInterval) as String
            timeTakenValue.font = UIFont.systemFont(ofSize: 19.0, weight: UIFontWeightHeavy)
            timeTakenValue.textColor = UIColor.white
            timeTakenValue.sizeToFit()
            timeTakenValue.frame = CGRect(x: (timeTakenImage.frame.origin.x + timeTakenImage.frame.size.width) + 10.0, y: 33.0, width: timeTakenValue.frame.size.width, height: timeTakenValue.frame.size.height)
        self.view.addSubview(timeTakenValue)
        
        let boardClaimedImage = UIImageView(image: UIImage(named: "percentageIcon"))
            boardClaimedImage.frame = CGRect(x: (self.view.frame.size.width - 28.0) - 30.0, y: 30.0, width: 28.0, height: 28.0)
        self.view.addSubview(boardClaimedImage)
        
        let boardClaimedValue = UILabel()
            boardClaimedValue.text = (Int(CGFloat(self.endGameStats["revealedTileCount"] as! Int) / CGFloat(self.endGameStats["totalTiles"] as! Int) * 100)).description + "%"
            boardClaimedValue.font = UIFont.systemFont(ofSize: 19.0, weight: UIFontWeightHeavy)
            boardClaimedValue.textColor = UIColor.white
            boardClaimedValue.textAlignment = .right
            boardClaimedValue.frame = CGRect(x: (boardClaimedImage.frame.origin.x - boardClaimedImage.frame.size.width) - 42.0, y: 33.0, width: 60.0, height: 23.0)
        self.view.addSubview(boardClaimedValue)

        var labelFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 60.0, height: 150.0)
        let summaryLabel = UILabel(frame: labelFrame)
        
        let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 6.0
            paragraph.alignment = NSTextAlignment.center
        
            let attributedParentString = NSMutableAttributedString(string: "You found ")
                attributedParentString.setAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 27.0), NSParagraphStyleAttributeName : paragraph], range: NSMakeRange(0, attributedParentString.length))
        
            for i in 0..<4 {
                
                var string = ""
                var attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 27.0), NSParagraphStyleAttributeName: paragraph]
                
                if i == 0 {
                    string = (self.endGameStats["flaggedMineCount"] as! Int).description
                    attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 27.0, weight: UIFontWeightHeavy)]
                } else if i == 1 {
                    string = " out \n of "
                } else if i == 2 {
                    string = (self.endGameStats["mineCount"] as! Int).description + " mines"
                    attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 27.0, weight: UIFontWeightHeavy)]
                } else {
                    string = "."
                }
                
                let attributedChildString = NSMutableAttributedString(string: string)
                    attributedChildString.setAttributes(attributes, range: NSMakeRange(0, attributedChildString.length))
                
                attributedParentString.append(attributedChildString)
            }
        
        
            summaryLabel.attributedText = attributedParentString
            summaryLabel.textColor = UIColor.white
            summaryLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            summaryLabel.numberOfLines = 4
            summaryLabel.sizeToFit()
        
            labelFrame.size.height = summaryLabel.frame.size.height
            summaryLabel.frame = labelFrame
            summaryLabel.center = CGPoint(x: self.view.center.x, y: faceImage.center.y + 75.0)
        
        self.view.addSubview(summaryLabel)
        
        let buttonWidth = (self.view.frame.size.width - 60.0)
        self.resetButton = UIButton(frame: CGRect(x: 30.0, y: (self.view.frame.size.height - 46.0) - 30.0, width: buttonWidth, height: 46.0))
        self.resetButton.setTitle((self.endGameStats["flaggedMineCount"] as! Int) == (self.endGameStats["mineCount"] as! Int) ? "Play Again".uppercased() : "Try Again".uppercased(), for: UIControlState())
        self.resetButton.setTitleColor(UIColor.white, for: UIControlState())
        self.resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightHeavy)
        self.resetButton.backgroundColor = UIColor.clear
        self.resetButton.layer.cornerRadius = 23.0
        self.resetButton.layer.borderColor = UIColor.white.cgColor
        self.resetButton.layer.borderWidth = 3.0
        self.resetButton.addTarget(self, action: #selector(SMGameEndViewController.startReset), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.resetButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0.25, options: UIViewAnimationOptions(), animations: {
            self.view.alpha = 1.0
        }, completion: nil)
    }
    
    func stringFromTimeInterval(_ interval:TimeInterval) -> NSString! {
        
        let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [NSCalendar.Unit.minute, NSCalendar.Unit.second]
            formatter.zeroFormattingBehavior = DateComponentsFormatter.ZeroFormattingBehavior.pad
        let string = formatter.string(from: interval)
        
        return string as NSString!
    }
    
    func startReset() {
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.view.alpha = 0.0
        }, completion: {
        
            finished in
            
            if let delegate = self.delegate {
                delegate.resetScene()
            }
        
            self.dismiss(animated: false, completion: nil)
            
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}
