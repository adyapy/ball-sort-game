//
//  GameViewController.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol VCDelegate {
    func didTick()
    func newBall(ball: Ball)
    func getCurrentLevel() -> Int
    func setLevelColors(colors: (Color, Color))
    func setBallColor(ball: Ball, color: Color)
}

enum UserDataKeys {
    case HighScore
}

class GameViewController: UIViewController, VCDelegate {
    
    let userData = UserDefaults.standard
    
    var scene: GameScene!
    var engine: GameEngine!
    var ballGen: BallGenerator!
    
    @IBOutlet var scoreLabel: UILabel!
    
    //  Contains the game over label and buttons
    @IBOutlet var gameOverGroup: UIStackView!
    @IBOutlet var gameOverLabel: UILabel!
    @IBOutlet var playAgainButton: UIButton!
    
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var leftLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameOverGroup.isHidden = true
        
        //  Set up view
        let view = self.view as! SKView
        view.isMultipleTouchEnabled = false
        
        //  Set up scene in view
        self.scene = GameScene(size: view.bounds.size)
        self.scene.scaleMode = .aspectFill
        self.scene.vcDelegate = self
        self.scene.startTicking()
        
        //  Set up ball generator
        self.ballGen = BallGenerator(
            xCoordRange: (50, Int(view.bounds.size.width) - 50),
            delegate: self
        )
        
        //  Set up the game engine
        self.engine = GameEngine(delegate: self)
        self.scoreLabel.text = String(self.engine.score)
        
        self.ballGen.startGenerating()
        view.presentScene(self.scene)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func didTick() {
        self.scoreLabel.text = String(self.engine.score)
        
        //  Keep generating balls
        self.ballGen.tick()
        
        //  Clean up balls that have gone off screen
        var balls: [Ball] = []
        for (_, ball) in self.engine.balls {
            balls.append(ball)
        }
        let (offscreenBalls, isOffBottomScreen) = self.scene.getOffscreenBalls(balls)
        
        //  First check if game over
        if isOffBottomScreen {
            self.gameOver()
            return
        }
        
        for ball in offscreenBalls {
            self.removeBallFromScene(ball: ball)
        }
        
        //  Debug shit
        self.rightLabel.textColor = SystemColors[self.engine.levelColors.1.colorName]
        self.leftLabel.textColor = SystemColors[self.engine.levelColors.0.colorName]
    }
    
    func removeBallFromScene(ball: Ball) {
        self.engine.removeBallByKey(key: ball.id)
        ball.sprite.removeFromParent()
    }
    
    func newBall(ball: Ball) {
        self.engine.addBall(ball: ball)
        self.scene.addBallToScene(ball: ball)
    }
    
    func setLevelColors(colors: (Color, Color)) {
        self.ballGen.setLevelColors(colors: colors)
    }
    
    func setBallColor(ball: Ball, color: Color) {
        //  GameScene has to do it since it holds the texture cache
        self.scene.setBallColor(ball: ball, color: color)
    }
    
    //  Return the first ball that intersects point, or nil if none
    func getBallAtPoint(point: CGPoint) -> Ball? {
        for (_, ball) in self.engine.balls {
            if ball.sprite.contains(point) {
                return ball
            }
            
        }
        return nil
    }
    
    //  Get the ball that was swiped, or nil if none
    func getSwipedBall(_ sender: UISwipeGestureRecognizer) -> Ball? {
        let swipePoint = sender.location(in: sender.view)
        //  Convert point based on scene's coordinate system
        let swipePointInScene = self.scene.convertPoint(toView: swipePoint)
        
        return self.getBallAtPoint(point: swipePointInScene)
    }
    
    func gameOver() {
        self.scene.gameOver()
        self.engine.gameOver()
        self.scoreLabel.text = String(self.engine.score)
        self.gameOverGroup.isHidden = false
    }
    
    //  Getter for the ball gen
    func getCurrentLevel() -> Int {
        return self.engine.currentLevel
    }
    
    //  User interactions
    
    //  Ball swiping
    @IBAction func onSwipeRight(_ sender: UISwipeGestureRecognizer) {
        guard let swipedBall = self.getSwipedBall(sender) else {
            return
        }
        
        if (swipedBall.color == self.engine.levelColors.1) {
            //  Correct swipe
            self.engine.addPoint()
            
        } else {
            self.gameOver()
        }
        self.removeBallFromScene(ball: swipedBall)
    }
    
    //  Ball swiping
    @IBAction func onSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        guard let swipedBall = self.getSwipedBall(sender) else {
            return
        }
        
        if (swipedBall.color == self.engine.levelColors.0) {
            //  Correct swipe
            self.engine.addPoint()
        } else {
            self.gameOver()
        }
        self.removeBallFromScene(ball: swipedBall)
    }
    
    //  PLaying again after game over
    @IBAction func onClickPlayAgain(_ sender: UIButton) {
        self.gameOverGroup.isHidden = true
        self.engine.setNewColors()
        self.scene.isTicking = true
    }
}
