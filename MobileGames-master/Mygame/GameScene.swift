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
    let Meteor = SKSpriteNode(imageNamed: "Meteor")
    var Platforms :[SKSpriteNode] = [SKSpriteNode]()
    let platform = SKSpriteNode(imageNamed: "Platform")
    let platform2 = SKSpriteNode(imageNamed: "Platform")
    let platform3 = SKSpriteNode(imageNamed: "Platform")
    let platform4 = SKSpriteNode(imageNamed: "Platform")
    let platform5 = SKSpriteNode(imageNamed: "Platform")
    let platform6 = SKSpriteNode(imageNamed: "Platform")
    let platform7 = SKSpriteNode(imageNamed: "Platform")
    let platform8 = SKSpriteNode(imageNamed: "Platform")
    let platform9 = SKSpriteNode(imageNamed: "Platform")
    
    let PlayerCategory:UInt32 = 0x3 << 0;
    let PlatformCategory:UInt32 = 0x3 << 1;
    let MeteorCategory:UInt32 = 0x3 << 2;
    let BulletCategory:UInt32 = 0x3 << 3;
    
    var isFalling = false
    
    
    var DragonHalfHeight = CGFloat(0.0)
    var PlatformHalfHeight = CGFloat(0.0)
    var DragonHalfWidth = CGFloat(0.0)
    var PlatformHalfWidth = CGFloat(0.0)
    var minYDistance = CGFloat(0.0)
    var minXDistance = CGFloat(0.0)
     
    var motionManager: CMMotionManager?
    
    let Jump = SKAction.moveBy(x: 0, y: 150, duration: 0.7)
    let die = SKAction.move(to: CGPoint(x: 150, y: 100), duration: 0)
    let InitJump = SKAction.moveBy(x: 0, y: 400, duration: 0.5)
    let fall = SKAction.moveBy(x:0, y: -300, duration: 0.5)
    let shoot = SKAction.moveBy(x:0, y: 800, duration: 1)
    let KillMeteor = SKAction.move(to: CGPoint(x: Int.random(in: 20...280), y: 700), duration: 0)
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
      
        
        setupPlatforms()
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.8
        background.zPosition = -2
        addChild(background)
        
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
        
        dragon.position = CGPoint(x:150, y: 100)
        
        dragon.physicsBody = SKPhysicsBody(circleOfRadius: dragonRadius)
        dragon.physicsBody?.isDynamic = false
        dragon.physicsBody?.allowsRotation = false
        dragon.physicsBody?.restitution = 0
        dragon.physicsBody?.friction = 0
        dragon.physicsBody?.categoryBitMask = PlayerCategory
        dragon.physicsBody?.contactTestBitMask = PlatformCategory
        dragon.physicsBody?.collisionBitMask = PlatformCategory
        addChild(dragon)
        
        Meteor.position = CGPoint(x:150, y: 1500)
        let meteorRadius = Meteor.frame.width/2
        Meteor.physicsBody = SKPhysicsBody(circleOfRadius: meteorRadius)
        Meteor.physicsBody?.isDynamic = false
        Meteor.physicsBody?.allowsRotation = false
        Meteor.physicsBody?.restitution = 0
        Meteor.physicsBody?.friction = 0
        Meteor.physicsBody?.categoryBitMask = MeteorCategory
        Meteor.physicsBody?.contactTestBitMask = (PlayerCategory|BulletCategory)
        Meteor.physicsBody?.collisionBitMask = (PlayerCategory|BulletCategory)
        addChild(Meteor)
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity.dx = CGFloat(accelerometerData.acceleration.x * 20)
        }
        if (dragon.physicsBody?.isDynamic == true)
        {
            MoveMeteor()
        }
        fallOutOfFrame()
        for platform in Platforms{
            if(platform.position.y >= dragon.position.y)
            {
                platform.physicsBody?.categoryBitMask = 0
                platform.physicsBody?.contactTestBitMask = 0
                platform.physicsBody?.collisionBitMask = 0
            }
            if(platform.position.y < dragon.position.y)
            {
                platform.physicsBody?.categoryBitMask = PlatformCategory
                platform.physicsBody?.contactTestBitMask = PlayerCategory
                platform.physicsBody?.collisionBitMask = PlayerCategory
            }
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
            let FireShot = SKSpriteNode(imageNamed: "Fire")
            let ShotRadius = FireShot.frame.width/2
            FireShot.position = particles.position
            FireShot.physicsBody = SKPhysicsBody(circleOfRadius: ShotRadius)
            FireShot.physicsBody?.affectedByGravity = false
            FireShot.physicsBody?.categoryBitMask = BulletCategory
            FireShot.physicsBody?.contactTestBitMask = MeteorCategory
            FireShot.physicsBody?.collisionBitMask = MeteorCategory
            addChild(FireShot)
            FireShot.run(shoot)
                
            
            FireShot.run(removeAfterDead)
            particles.run(removeAfterDead)
            if dragon.physicsBody!.isDynamic{
                       return
                   }
                   dragon.physicsBody?.isDynamic=true
                   isJumping = true
            dragon.run(InitJump, completion: {self.isJumping = false})
                   
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if (contact.bodyA.categoryBitMask == PlatformCategory && contact.bodyB.categoryBitMask == PlayerCategory || contact.bodyB.categoryBitMask == PlatformCategory && contact.bodyA.categoryBitMask == PlayerCategory)
        {
            score += 150
            if(!isJumping && !isFalling)
            {
                isFalling = true
                for platform in Platforms
                {
                    platform.run(fall, completion: {self.isFalling = false})
                }
                
                dragon.run(Jump, completion: {self.isJumping=false})
    
                isJumping = true
                
            }
        }
        if (contact.bodyA.categoryBitMask == MeteorCategory && contact.bodyB.categoryBitMask == PlayerCategory || contact.bodyB.categoryBitMask == MeteorCategory && contact.bodyA.categoryBitMask == PlayerCategory)
        {
            lose()
        }
        if(contact.bodyA.categoryBitMask == MeteorCategory && contact.bodyB.categoryBitMask == BulletCategory || contact.bodyB.categoryBitMask == MeteorCategory && contact.bodyA.categoryBitMask == BulletCategory)
        {
            DebugLabel.text = "collided"
            if (Meteor.position.y < 600)
            {
                score += 100
                Meteor.run(KillMeteor)
                if (contact.bodyA.categoryBitMask == BulletCategory)
                {
                    contact.bodyA.node?.removeFromParent()
                }
                if (contact.bodyB.categoryBitMask == BulletCategory)
                {
                    contact.bodyB.node?.removeFromParent()
                }
            }
               
         
        }
            
    }
    
    func fallOutOfFrame()
    {
        if(dragon.position.x > frame.width)
        {
            dragon.position.x = 0
        }
        if(dragon.position.x < 0)
        {
            dragon.position.x = frame.width
        }
        if(dragon.position.y < 0)
        {
          lose()
        }
        if(Meteor.position.y < 0 || Meteor.position.y < dragon.position.y)
        {
            Meteor.position.y = 700
            Meteor.position.x = CGFloat.random(in:20...280)
        }
        for platform in Platforms
        {
            if(platform.position.y <= 0)
            {
                platform.position = CGPoint(x: Int.random(in:20...280), y:600)
            }
        }
    }
    
    func setupPlatforms()
    {
        Platforms.append(platform)
        Platforms.append(platform2)
        Platforms.append(platform3)
        Platforms.append(platform4)
        Platforms.append(platform5)
        Platforms.append(platform6)
        Platforms.append(platform7)
        Platforms.append(platform8)
        Platforms.append(platform9)
        for platform in Platforms
        {
           platform.position = CGPoint(x: Int.random(in:20...280), y: Int.random(in: 0...600))
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
    }
    
    func MoveMeteor()
    {
        Meteor.position.y -= 0.5
    }
    
    func lose()
    {
        dragon.removeAllActions()
        Meteor.position.y = 700
        isJumping = false
        dragon.run(die)
        dragon.physicsBody?.isDynamic = false
        score = 0
        
        for platform in Platforms
        {
        platform.position = CGPoint(x: Int.random(in:20...280), y: Int.random(in: 0...600))
        }
    }
        
}



