//
//  GameScene.swift
//  Mygame
//
//  Created by BIRCH, ADAM on 04/11/2019.
//  Copyright © 2019 BIRCH, ADAM. All rights reserved.
//
import CoreMotion
import SpriteKit
import GameplayKit


class Ball: SKSpriteNode { }

class GameScene: SKScene {
    let dragon = SKSpriteNode(imageNamed: "Dragon")
    
    let platform = SKSpriteNode(imageNamed: "Platform")
    
    
    var DragonHalfHeight = CGFloat(0.0)
    var PlatformHalfHeight = CGFloat(0.0)
    var DragonHalfWidth = CGFloat(0.0)
    var PlatformHalfWidth = CGFloat(0.0)
    var minYDistance = CGFloat(0.0)
    var minXDistance = CGFloat(0.0)
    
    var motionManager: CMMotionManager?
    
    let Jump = SKAction.moveBy(x: 0, y: 200, duration: 0.5)
    //let Fall = SKAction.moveBy(x: 0, y: -200, duration: 0.4)
    let scoreLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
    let DebugLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
    let isAlive = true
    let startingHeight = 50
    var HighestHeight = 50
    var delay = 30
    var isJumping = false
   
    
    var score = 0{
        didSet{
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE: \(formattedScore)"
        }
    }
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.8
        background.zPosition = -2
        addChild(background)
        
        platform.position = CGPoint(x: 200, y: 180)
        platform.size = CGSize(width: 75, height: 15)
        addChild(platform)

        
        scoreLabel.fontSize = 22
        scoreLabel.position = CGPoint(x: 150, y: 350)
        scoreLabel.text = "score 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
        
        DebugLabel.fontSize = 22
        DebugLabel.position = CGPoint(x: 50, y: 550)
        DebugLabel.text = "NotCollided"
        DebugLabel.zPosition = 100
        DebugLabel.horizontalAlignmentMode = .center
        addChild(DebugLabel)
        
        let dragonRadius = dragon.frame.width/2
        
        dragon.position = CGPoint(x: 50, y: 200)
        
        dragon.physicsBody = SKPhysicsBody(circleOfRadius: dragonRadius)
        dragon.physicsBody?.allowsRotation = false
        dragon.physicsBody?.restitution = 0
        dragon.physicsBody?.friction = 0
        addChild(dragon)

                
        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 100, left:0, bottom:0, right: 0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity.dx = CGFloat(accelerometerData.acceleration.x * 50)
        }
        GetDistanceBetween()
        jump()
        if ((Int)(dragon.position.y) > HighestHeight)
        {
            HighestHeight = (Int)(dragon.position.y)
            
            score = HighestHeight - startingHeight
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let Offset = CGPoint(x:0.0, y: 40.0)
        if let particles = SKEmitterNode(fileNamed: "Flames"){
            particles.position = CGPoint(x: dragon.position.x + Offset.x, y: dragon.position.y + Offset.y)
            particles.zPosition = -1
                           addChild(particles)
            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3),
                                                     SKAction.removeFromParent()])
            particles.run(removeAfterDead)
        }
    }
    
    func jump()
    {
        
       delay = delay + 1
       if(isAlive == true && delay >= 30)
                 {
                    isJumping=true
                    dragon.run(Jump)
                    delay = 0
                 }
        if(delay < 29)
        {
            isJumping=false
        }
        
    }
    func Doublejump()
    {
        
       delay = delay + 1
       if(isAlive == true && delay >= 30)
                 {
                    isJumping=true
                    dragon.run(Jump)
                    delay = 0
                 }
        
    }
    func GetDistanceBetween()
    {
        DragonHalfHeight = (dragon.frame.height)/2
        PlatformHalfHeight = (platform.frame.height)/2
        DragonHalfWidth = (dragon.frame.width)/2
        PlatformHalfWidth = (platform.frame.width)/2
        minYDistance = DragonHalfHeight + PlatformHalfHeight
        minXDistance = DragonHalfWidth + PlatformHalfWidth
        if (platform.position.y - dragon.position.y < minYDistance && platform.position.x - dragon.position.x < minXDistance)
        {
            DebugLabel.text = "Collided"
            delay = 30
            Doublejump()
        }
        else{
            return
        }
        
    }

}


