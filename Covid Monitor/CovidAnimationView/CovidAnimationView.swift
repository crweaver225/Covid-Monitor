//
//  CovidAnimationView.swift
//  Covid Monitor
//
//  Created by Christopher Weaver on 8/23/21.
//

import UIKit

@IBDesignable
class Ball: UIView {

    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}

class CovidAnimationView: UIView {

    private var leftLines: [Ball] = []
    private var rightLines: [Ball] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        insertRightLines()
        insertLeftLines()
    }
    
    private func insertLeftLines() {
        let number = Int(self.frame.height / 30)
        for lIndex in 0...number {
            let ball = Ball(frame: CGRect(x: 25, y: (Int(self.frame.height) / number) * lIndex, width: 50, height: 20))
            ball.backgroundColor = .blue
            ball.layer.cornerRadius = 15
            leftLines.append(ball)
            self.addSubview(ball)
        }
    }
    
    private func insertRightLines() {
        let number = Int(self.frame.height / 30)
        for lIndex in 0...number {
            let ball = Ball(frame: CGRect(x: Int(self.frame.width) - 75, y: (Int(self.frame.height) / number) * lIndex, width: 50, height: 20))
            ball.backgroundColor = .blue
            ball.layer.cornerRadius = 15
            rightLines.append(ball)
            self.addSubview(ball)
        }
    }
    
    func animateView() {
        
        for (index,line) in leftLines.enumerated() {
            let delay = Double(index) * 0.3
            
            line.moveX(self.frame.width / 2).duration(2).easing(.swiftOut).delay(delay)
                .then().moveX(-self.frame.width / 2).rotateY(1.43).easing(.swiftOut)
                .makeColor(UIColor.green).repeatCount(100)
                .reverses().duration(2).animate()
         }
                
         for (index,line) in rightLines.enumerated() {
            let delay = Double(index) * 0.3
            
            line.moveX(-self.frame.width / 2).duration(2).easing(.swiftOut).delay(delay)
                .then().moveX(self.frame.width / 2).rotateY(1.43).easing(.swiftOut)
                .makeColor(UIColor.purple).repeatCount(100)
                .reverses().duration(2).animate()
         }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
