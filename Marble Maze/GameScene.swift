//
//  GameScene.swift
//  Marble Maze
//
//  Created by Yohannes Wijaya on 10/11/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Local Methods
    
    func loadLevel() {
        if let levelPath = NSBundle.mainBundle().pathForResource("level1", ofType: "txt") {
            if let levelString = try? String(contentsOfFile: levelPath, usedEncoding: nil) {
                let lines = levelString.componentsSeparatedByString("\n")
            }
        }
    }
    
    // MARK: - Methods Override
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
