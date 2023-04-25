//
//  PauseNode.swift
//  IceBreaker
//
//  Created by Brandon Torres on 9/30/19.
//  Copyright © 2019 Funcade  LLC. All rights reserved.
//

import SpriteKit


class PauseNode: SKSpriteNode, ResizableNode {
    var label: SKLabelNode
    weak var delegate: ModelDialogDelegate?
    
    init(parentSize size: CGSize) {
        self.label = SKLabelNode(text: "Tap anywhere to play")
        super.init(texture: nil, color: UIGlobals.bgColor, size: size)
        label.fontColor = UIGlobals.fontColor
        label.fontName = UIGlobals.fontName
        label.verticalAlignmentMode = .center
        addChild(label)
        self.relayout(parentSize: size)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showScreen(parentSize: CGSize) {
        relayout(parentSize: parentSize)
    }
    
    private func relayoutBG(parentSize size: CGSize) {
        let wide = size.width > size.height
        
        let backgroundTexture: SKTexture
        if wide {
            backgroundTexture = SKTexture(imageNamed: "Background-landscape")
        } else {
            backgroundTexture = SKTexture(imageNamed: "Background-portrait")
        }
        
        let tH = backgroundTexture.size().height
        let tW = backgroundTexture.size().width
        
        let vH = size.height
        let vW = size.width
        
        let textureRatio = tH / tW
        let viewRatio = vH / vW
        
        let bgTexture: SKTexture
        
        switch (textureRatio - viewRatio) {
        case let x where x == 0:
            bgTexture = backgroundTexture
        case let x where x > 0:
            let scale = tW / vW;
            let dH = vH * scale
            // Shows the middle part of the landscape texture
            let subTextureRect = CGRect(x: 0, y: 0.5 - (dH / (2 * tH)), width: 1, height: dH/tH)
            bgTexture = SKTexture(rect: subTextureRect, in: backgroundTexture)
        case let x where x < 0:
            let scale = tH / vH;
            let dW = vW * scale
            // Shows the middle part of the portrait texture
            let subTextureRect = CGRect(x: 0.5 - (dW / (2 * tW)), y: 0, width: dW/tW, height: 1)
            bgTexture = SKTexture(rect: subTextureRect, in: backgroundTexture)
        default:
            // Should never happen
            bgTexture = backgroundTexture
        }
        
        self.texture = bgTexture
        self.size = size
        anchorPoint = CGPoint.zero
        position = CGPoint.zero
    }
    
    func relayout(parentSize size: CGSize) {
        relayoutBG(parentSize: size)
        
        label.adjustLabelFontSizeToFitRect(CGRect(x: UIGlobals.margin, y: 0, width: size.width - 2 * UIGlobals.margin, height: size.height), centered: true, maxFontSize: UIGlobals.maxFontSize)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.delegate?.intermediateScreenDismissed()
    }
}
