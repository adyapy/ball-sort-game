//
//  GameScene.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let ballLayer = SKNode()
    
    var leftWall: SKSpriteNode!
    var rightWall: SKSpriteNode!
    
    var textureCache = [String: SKTexture]()
    var vcDelegate: VCDelegate?
    
    var isTicking: Bool = false
    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("NSCoder not supported")
//    }
//
//    init(fileNamed: String) {
//        self.isTicking = false
//
//        super.init(size)
////        self.sce = SKScene(fileNamed: "GameScene")
//
//        self.anchorPoint = CGPoint(x: 0, y: 1)
//        self.addChild(self.gameLayer)
//
//        //  Add ball layer
//        self.gameLayer.addChild(self.ballLayer)
//
//        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
//    }
    
    //  Avoid weird inherited constructur funkiness
    func initalize(view: UIView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.addChild(self.gameLayer)
        self.gameLayer.addChild(self.ballLayer)
        
        self.leftWall = self.scene?.childNode(withName: "LeftWall") as! SKSpriteNode
        self.leftWall.position = CGPoint(x: self.leftWall.size.width, y: -self.size.height / 2)
        self.leftWall.size.height = self.size.height
        
        self.rightWall = self.scene?.childNode(withName: "RightWall") as! SKSpriteNode
        self.rightWall.position = CGPoint(x: self.size.width - self.rightWall.size.width, y: -self.size.height / 2)
        self.rightWall.size.height = self.size.height
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //  Game can be paused
        if !self.isTicking {
            return
        }
        
        self.vcDelegate!.didTick()
    }
    
    func _getTextureForColor(color: Color) -> SKTexture {
        //  Load texture from cache or load new and save in cache
        var texture = self.textureCache[color.colorName]
        if texture == nil {
            texture = SKTexture(imageNamed: color.colorName)
            self.textureCache[color.colorName] = texture
        }
        return texture!
    }
    
    func addBallToScene(ball: Ball) {
        //  Load sprite
        let sprite = SKSpriteNode(texture: self._getTextureForColor(color: ball.color))
        sprite.position = ball.startingPosition
        ball.sprite = sprite
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
        sprite.physicsBody?.categoryBitMask = 0x1 << 1
        sprite.physicsBody?.collisionBitMask = 0
        
        //  Add to scene
        self.ballLayer.addChild(sprite)
    }
    
    //  Returns IDs of balls off screen
    func getOffscreenBalls(_ balls: [Ball]) -> ([Ball], Bool) {
        //  y positions are negative
        let allOffscreen = balls.filter { !self.intersects($0.sprite!) }
        let isOffBottomScreen = allOffscreen.contains { $0.sprite.position.y < -self.size.height }
        return (allOffscreen, isOffBottomScreen)
    }
    
    func startTicking() {
        self.isTicking = true
        
//        let scene: SKScene = SKScene(fileNamed: "Box")!
//        let box = scene.childNode(withName: "box")
//        box?.position = CGPoint(x: 100, y: -100)
//        box?.move(toParent: self)
    }
    
    //  Clean up and reset
    func gameOver() {
        self.ballLayer.removeAllChildren()
        self.isTicking = false
    }
}
