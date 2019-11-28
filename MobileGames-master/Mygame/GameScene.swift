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

class GameScene: SKScene, SKPhysicsContactDelegate {
    let dragon = SKSpriteNode(imageNamed: "Dragon")
    
    var Platforms :[SKSpriteNode] = [SKSpriteNode]()
    let platform = SKSpriteNode(imageNamed: "Platform")
    let platform2 = SKSpriteNode(imageNamed: "Platform")
    let platform3 = SKSpriteNode(imageNamed: "Platform")
    let platform4 = SKSpriteNode(imageNamed: "Platform")
    let platform5 = SKSpriteNode(imageNamed: "Platform")
    let platform6 = SKSpriteNode(imageNamed: "Platform")
    let platform7 = SKSpriteNode(imageNamed: "Platform")
    let platform8 = SKSpriteNode(imageNamed: "Platform")
    
   
    
    var DragonHalfHeight = CGFloat(0.0)
    var PlatformHalfHeight = CGFloat(0.0)
    var DragonHalfWidth = CGFloat(0.0)
    var PlatformHalfWidth = CGFloat(0.0)
    var minYDistance = CGFloat(0.0)
    var minXDistance = CGFloat(0.0)
     
    var RandomX = 0
    var RandomY = 0
    var motionManager: CMMotionManager?
    
    let Jump = SKAction.moveBy(x: 0, y: 400, duration: 1.5)
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
        self.physicsWorld.contactDelegate = self
        Platforms.append(platform2)
        Platforms.append(platform3)
        Platforms.append(platform4)
        Platforms.append(platform5)
        Platforms.append(platform6)
        Platforms.append(platform7)
        Platforms.append(platform8)
        let PlayerCategory:UInt32 = 0x1 << 0;
        let PlatformCategory:UInt32 = 0x1 << 1;
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.8
        background.zPosition = -2
        addChild(background)
        
        platform.position = CGPoint(x: frame.width/2, y: 20)
        platform.size = CGSize(width: 75, height: 15)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size, center: platform.centerRect.origin)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = PlatformCategory
        platform.physicsBody?.contactTestBitMask = PlayerCategory
        platform.physicsBody?.collisionBitMask = PlayerCategory
        addChild(platform)
        
        for platform in Platforms
        {
            platform.position = CGPoint(x: Int.random(in:0...300), y: Int.random(in: 0...800))
            platform.size = CGSize(width: 75, height: 15)
            platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size, center: platform.centerRect.origin)
            platform.physicsBody?.affectedByGravity = false
            platform.physicsBody?.allowsRotation = false
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.categoryBitMask = PlatformCategory
            platform.physicsBody?.contactTestBitMask = PlayerCategory
            platform.physicsBody?.collisionBitMask = PlayerCategory
            addChild(platform)
        }
        
        

        
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
        //dragon.physicsBody?.categoryBitMask = PlayerCategory
        dragon.physicsBody?.contactTestBitMask = PlatformCategory
        //dragon.physicsBody?.collisionBitMask = 0
        addChild(dragon)

                
        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: -400, left:-50, bottom:0, right: -50)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity.dx = CGFloat(accelerometerData.acceleration.x * 50)
        }
        //jump()
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
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if (!isJumping)
        {
            DebugLabel.text = "collided"
            dragon.run(Jump)
            isJumping = true
        }
        else
        {
            dragon.isPaused = true
            dragon.run(Jump)
        }
    }
    func didEnd(_ contact: SKPhysicsContact)
    {
        isJumping = false
        DebugLabel.text = "Stoped-colliding"
    }
    
       
        
    
}


