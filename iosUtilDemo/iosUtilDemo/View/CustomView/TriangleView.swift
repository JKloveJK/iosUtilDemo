//
//  TriangleView.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/20.
//

import Foundation
import UIKit

enum TriangleDirection {
    case up, left, down, right
}

class TriangleView: UIView {
    
    private let direction: TriangleDirection
    private let fillColor: UIColor?
    
    init(
        direction: TriangleDirection = .up,
        fillColor: UIColor? = UIColor(hex: "#4c4c4c"),
        frame: CGRect = .zero
    ) {
        self.direction = direction
        self.fillColor = fillColor
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.beginPath()
        
        switch direction {
        case .up:
            context.move(to: CGPoint(x: rect.width / 2, y: 0))
            context.addLine(to: CGPoint(x: rect.width, y: rect.height))
            context.addLine(to: CGPoint(x: 0, y: rect.height))
        case .left:
            context.move(to: CGPoint(x: 0, y: rect.height / 2))
            context.addLine(to: CGPoint(x: rect.width, y: 0))
            context.addLine(to: CGPoint(x: rect.width, y: rect.height))
        case .down:
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: rect.width, y: 0))
            context.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        case .right:
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
            context.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        
        
        context.closePath()
        fillColor?.setFill()
        context.fillPath()
    }
}
