//
//  SMThemeController.swift
//  MinimalMine
//
//  Created by Jonathon Toon on 7/20/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit

class SMThemeController {
    
    var boardThemes: [String: (startGradientColor: String, endGradientColor: String, bombColor: String, backgroundColor: String)]!
    
    var currentThemeName: String
    
    let rows: Int
    let columns: Int
    
    var currentThemeGradient: SMThemeGradient
    
    init(initialTheme: String, numberOfRows rows: Int, numberOfColumns cols: Int) {
        
        self.currentThemeName = initialTheme
        
        self.boardThemes = [
            "Fire": (
                startGradientColor: "#FF5E3A",
                endGradientColor: "#FF2A68",
                bombColor: "#FFFFFF",
                backgroundColor: "#1E1313"
            ),
            "Neon": (
                startGradientColor: "#23C67D",
                endGradientColor: "#23C67D",
                bombColor: "#ffffff",
                backgroundColor: "#271731"
            ),
            "Cold": (
                startGradientColor: "#8E54E9",
                endGradientColor: "#4776E6",
                bombColor: "#FFFFFF",
                backgroundColor: "#181A27"
            ),
            "Royal": (
                startGradientColor: "#7b4397",
                endGradientColor: "#C02F39",
                bombColor: "#F0F0F0",
                backgroundColor: "#181A27"
            )
        ]
        
        self.rows = rows
        self.columns = cols
        
        self.currentThemeGradient = SMThemeGradient(
            numberOfColumns: self.columns,
            numberOfRows: self.rows,
            startColor: UIColor(self.boardThemes[self.currentThemeName]!.startGradientColor),
            endColor: UIColor(self.boardThemes[self.currentThemeName]!.endGradientColor)
        )
    }

    func getCurrentTheme() -> (startGradientColor: String, endGradientColor: String, bombColor: String, backgroundColor: String) {
    
        return self.boardThemes[self.currentThemeName]!
        
    }
    
    class func bombLevelColor() -> UIColor {
        return UIColor("#FF2828")
    }
}
