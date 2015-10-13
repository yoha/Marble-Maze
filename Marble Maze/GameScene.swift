//
//  GameScene.swift
//  Marble Maze
//
//  Created by Yohannes Wijaya on 10/11/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Stored Properties
    
    var player: SKSpriteNode!
    let playerStartingPosition: CGPoint = CGPoint(x: 96, y: 672)
    var lastTouchPosition: CGPoint? // <-- to stimulate gravity on the simulator
    var motionManager: CMMotionManager!
    
    var scoreLabelNode: SKLabelNode!
    var score: Int = 0 {
        didSet {
            self.scoreLabelNode.text = "Score: \(score)"
        }
    }
    var gameOver = false
    
    // MARK: - Enums
    
    enum CollisionTypes: UInt32 {
        case Player = 1
        case Wall = 2
        case Star = 4
        case Vortex = 8
        case Finish = 16
    }
    
    // MARK: - Delegate Methods
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node == self.player { self.playerCollideWithNode(contact.bodyB.node!) }
        else if contact.bodyB.node == self.player { self.playerCollideWithNode(contact.bodyA.node!) }
    }
    
    // MARK: - Local Methods
    
    func createPlayer() {
        self.player = SKSpriteNode(imageNamed: "player")
        self.player.position = self.playerStartingPosition
        
        self.player.physicsBody = SKPhysicsBody(circleOfRadius: self.player.size.width / 2)
        self.player.physicsBody!.categoryBitMask = CollisionTypes.Player.rawValue
        self.player.physicsBody!.collisionBitMask = CollisionTypes.Wall.rawValue
        self.player.physicsBody!.contactTestBitMask = CollisionTypes.Star.rawValue | CollisionTypes.Vortex.rawValue | CollisionTypes.Finish.rawValue
        self.player.physicsBody!.allowsRotation = false
        self.player.physicsBody!.linearDamping = 0.5 // <-- cause friction
        
        self.addChild(self.player)
    }
    func loadLevel() {
        if let levelPath = NSBundle.mainBundle().pathForResource("level1", ofType: "txt") {
            if let levelString = try? NSString(contentsOfFile: levelPath, usedEncoding: nil) {
                let lines = levelString.componentsSeparatedByString("\n")
                
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let nodePosition = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                        
                        switch letter {
                            
                        case "x":
                            let wallSpriteNode = SKSpriteNode(imageNamed: "block")
                            wallSpriteNode.position = nodePosition
                            
                            wallSpriteNode.physicsBody = SKPhysicsBody(rectangleOfSize: wallSpriteNode.size)
                            wallSpriteNode.physicsBody!.categoryBitMask = CollisionTypes.Wall.rawValue
                            wallSpriteNode.physicsBody!.dynamic = false
                            
                            self.addChild(wallSpriteNode)
                            
                        case "v":
                            let vortextSpriteNode = SKSpriteNode(imageNamed: "vortex")
                            vortextSpriteNode.name = "vortex"
                            vortextSpriteNode.position = nodePosition
                            
                            vortextSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: vortextSpriteNode.size.width / 2)
                            vortextSpriteNode.physicsBody!.categoryBitMask = CollisionTypes.Vortex.rawValue
                            vortextSpriteNode.physicsBody!.collisionBitMask = 0
                            vortextSpriteNode.physicsBody!.contactTestBitMask = CollisionTypes.Player.rawValue
                            vortextSpriteNode.physicsBody!.dynamic = false
                        
                            vortextSpriteNode.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 1)))
                            self.addChild(vortextSpriteNode)
                            
                        case "s":
                            let starSpriteNode = SKSpriteNode(imageNamed: "star")
                            starSpriteNode.name = "star"
                            starSpriteNode.position = nodePosition
                        
                            starSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: starSpriteNode.size.width / 2)
                            starSpriteNode.physicsBody!.categoryBitMask = CollisionTypes.Star.rawValue
                            starSpriteNode.physicsBody!.collisionBitMask = 0
                            starSpriteNode.physicsBody!.contactTestBitMask = CollisionTypes.Player.rawValue
                            starSpriteNode.physicsBody!.dynamic = false
                        
                            self.addChild(starSpriteNode)
                            
                        case "f":
                            let flagSpriteNode = SKSpriteNode(imageNamed: "finish")
                            flagSpriteNode.name = "finish"
                            flagSpriteNode.position = nodePosition
                        
                            flagSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: flagSpriteNode.size.width / 2)
                            flagSpriteNode.physicsBody!.categoryBitMask = CollisionTypes.Finish.rawValue
                            flagSpriteNode.physicsBody!.collisionBitMask = 0
                            flagSpriteNode.physicsBody!.contactTestBitMask = CollisionTypes.Player.rawValue
                            flagSpriteNode.physicsBody!.dynamic = false
                        
                            self.addChild(flagSpriteNode)
                            
                        default: break
                        }
                    }
                }
            }
        }
    }
    func loadBackgroundSpriteNode() {
        let backgroundSpriteNode = SKSpriteNode(imageNamed: "background.jpg")
        backgroundSpriteNode.position = CGPoint(x: 512, y: 384)
        backgroundSpriteNode.blendMode = .Subtract
        backgroundSpriteNode.zPosition = -1.0
        
        self.addChild(backgroundSpriteNode)
    }
    func loadScoreLabelNode() {
        self.scoreLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        self.scoreLabelNode.text = "Score: 0"
        self.scoreLabelNode.horizontalAlignmentMode = .Left
        self.scoreLabelNode.position = CGPoint(x: 16, y: 16)
        self.addChild(self.scoreLabelNode)
    }
    
    func playerCollideWithNode(node: SKNode) {
        switch node.name! {
        case "vortex":
            self.player.physicsBody!.dynamic = false
            self.gameOver = true
            --self.score
            
            let movePlayerToVortex = SKAction.moveTo(node.position, duration: 0.25)
            let scalePlayerDown = SKAction.scaleTo(0.0001, duration: 0.25)
            let removePlayer = SKAction.removeFromParent()
            let actionSequence = SKAction.sequence([movePlayerToVortex, scalePlayerDown, removePlayer])
            self.player.runAction(actionSequence, completion: { [unowned self] () -> Void in
                self.createPlayer()
                self.gameOver = false
                })
            
        case "star":
            node.hidden = true
            ++self.score
            
        case "finish":
            let movePlayerToFlag = SKAction.moveTo(node.position, duration: 0.25)
            self.player.runAction(movePlayerToFlag)
            
            let alertController = UIAlertController(title: "Congrats!", message: "You've made it to the end!", preferredStyle: .Alert)
            let alertActionToPlayNextLevel = UIAlertAction(title: "Play next level.", style: .Default, handler: nil)
            let alertActionToPlayCurrentLevel = UIAlertAction(title: "Play this level again.", style: .Default, handler: { (alertAction) -> Void in
                self.restartGame()
            })
            alertController.addAction(alertActionToPlayNextLevel)
            alertController.addAction(alertActionToPlayCurrentLevel)
            self.view!.window!.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            
        default: break
        }
    }
    
    func restartGame() {
        self.score = 0
        self.player.removeFromParent()
        self.createPlayer()
        self.enumerateChildNodesWithName("star") { (starNode, _) -> Void in
            starNode.hidden = false
        }
    }
    
    // MARK: - Methods Override
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        self.loadBackgroundSpriteNode()
        self.loadLevel()
        self.createPlayer()
        self.loadScoreLabelNode()
        
        self.motionManager = CMMotionManager()
        self.motionManager.startAccelerometerUpdates()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        guard !gameOver else { return }
        #if (arch(i386) || arch(x86_64)) // <-- if game is tested on OSX's simulators
            if let currentTouch = self.lastTouchPosition {
                let distanceBetweenTouchAndPlayer = CGPointMake(currentTouch.x - self.player.position.x, currentTouch.y - self.player.position.y)
                self.physicsWorld.gravity = CGVectorMake(distanceBetweenTouchAndPlayer.x / 100, distanceBetweenTouchAndPlayer.y / 100)
            }
        #else // <-- if game is tested on iOS devices
            if let accelerometerData = self.motionManager.accelerometerData {
                self.physicsWorld.gravity = CGVectorMake(CGFloat(accelerometerData.acceleration.y * -50), CGFloat(accelerometerData.acceleration.x * 50))
            }
        #endif
        }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentLocationInNode = touch.locationInNode(self)
            self.lastTouchPosition = currentLocationInNode
        }
        
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentLocationInNode = touch.locationInNode(self)
            self.lastTouchPosition = currentLocationInNode
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.lastTouchPosition = nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.lastTouchPosition = nil
    }
}
