//
//  SMThemeGradient.swift
//  MinimalMine
//
//  Created by Jonathon Toon on 7/26/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit
import QuartzCore

class SMThemeGradient {
    
    var gradientColors: [[UIColor]] = []
    var cellGradients: [[CAGradientLayer]] = []
    
    var columns: Int = 0
    var rows: Int = 0
    
    init(numberOfColumns cols: Int, numberOfRows rows: Int, startColor: UIColor!, endColor: UIColor!) {
        
        self.columns = cols
        self.rows = rows
        
        let numberOfIntervals: Int = self.columns * self.rows
        
        let startColor: UIColor! = startColor
        var startColorR: CGFloat = startColor.cgColor.components![0]
        var startColorG: CGFloat = startColor.cgColor.components![1]
        var startColorB: CGFloat = startColor.cgColor.components![2]
       
        let endColor: UIColor! = endColor
        let endColorR: CGFloat = endColor.cgColor.components![0]
        let endColorG: CGFloat = endColor.cgColor.components![1]
        let endColorB: CGFloat = endColor.cgColor.components![2]
        
        let intervalR: CGFloat = (endColorR - startColorR) / CGFloat(numberOfIntervals)
        let intervalG: CGFloat = (endColorG - startColorG) / CGFloat(numberOfIntervals)
        let intervalB: CGFloat = (endColorB - startColorB) / CGFloat(numberOfIntervals)
    
        for c in 0..<self.columns {
            
            var gradientColorRow: [UIColor] = []
            
            for r in 0..<self.rows {
                
                var intervalColor: UIColor
                
                if c == 0 && r == 0 {
                  
                    intervalColor = startColor
                    
                } else if c == self.columns-1 && r == self.rows-1 {
                  
                    intervalColor = endColor
                    
                } else {
                    
                    startColorR += intervalR
                    startColorG += intervalG
                    startColorB += intervalB

                    intervalColor = UIColor(red: startColorR, green: startColorG, blue: startColorB, alpha: 1.0)
                }
                
                gradientColorRow.append(intervalColor)
                
            }
            
            self.gradientColors.append(gradientColorRow)
        }
        
        for c in 0..<self.columns {
            
            var cellGradientRows: [CAGradientLayer] = []
            
            for r in 0..<self.rows {
                
                let startGradientColor: UIColor = self.gradientColors[c][r]
                var endGradientColor: UIColor
                
                if c == self.columns-1 {
                    
                    if r == self.rows-1 {
                        endGradientColor = self.gradientColors[c][r]
                    } else {
                        endGradientColor = self.gradientColors[c][r+1]
                    }
                    
                } else {
                    
                    if r == self.rows-1 {
                        endGradientColor = self.gradientColors[c+1][r]
                    } else {
                        endGradientColor = self.gradientColors[c+1][r+1]
                    }
                    
                }
                
                let colors: [CGColor] = [startGradientColor.cgColor, endGradientColor.cgColor]
                
                let gradientLayer: CAGradientLayer = CAGradientLayer()
                    gradientLayer.startPoint = CGPoint.zero
                    gradientLayer.endPoint = CGPoint(x: 1, y: 1)
                    gradientLayer.colors = colors
                
                cellGradientRows.append(gradientLayer)
                
            }
            
            self.cellGradients.append(cellGradientRows)
        }
        
    }
    
}
