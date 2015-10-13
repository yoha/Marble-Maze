//
//  GameScene.swift
//  Marble Maze
//
//  Created by Yohannes Wijaya on 10/11/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    enum CollisionTypes: UInt32 {
        case Player = 1
        case Wall = 2
        case Star = 4
        case Vortex = 8
        case Finish = 16
    }
    
    // MARK: - Local Methods
    
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
    
    // MARK: - Methods Override
    
    override func didMoveToView(view: SKView) {
        self.loadBackgroundSpriteNode()
        self.loadLevel()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
