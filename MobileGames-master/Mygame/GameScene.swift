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
    
    //creating SKSpriteNode's
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
    let background = SKSpriteNode(imageNamed: "Background")
    
    
    //setup SKLabelNodes
    let scoreLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
    let LocalscoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    let PlayLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
    let LoseLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
    
    //using bitShifting to create collision bitmasks
    let PlayerCategory:UInt32 = 0x3 << 0;
    let PlatformCategory:UInt32 = 0x3 << 1;
    let MeteorCategory:UInt32 = 0x3 << 2;
    let BulletCategory:UInt32 = 0x3 << 3;
    
    //setup booleans
    var isFalling = false
    var isJumping = false
    var isAlive = true
    
    //setup bounds variables
    var DragonHalfHeight = CGFloat(0.0)
    var PlatformHalfHeight = CGFloat(0.0)
    var DragonHalfWidth = CGFloat(0.0)
    var PlatformHalfWidth = CGFloat(0.0)
    var minYDistance = CGFloat(0.0)
    var minXDistance = CGFloat(0.0)
    
    //setup motion manager
    var motionManager: CMMotionManager?
    
    //setup SKActions
    let Jump = SKAction.moveBy(x: 0, y: 150, duration: 0.7)
    let die = SKAction.move(to: CGPoint(x: 150, y: 100), duration: 0)
    let InitJump = SKAction.moveBy(x: 0, y: 400, duration: 0.5)
    let fall = SKAction.moveBy(x:0, y: -300, duration: 0.5)
    let shoot = SKAction.moveBy(x:0, y: 800, duration: 1)
    let KillMeteor = SKAction.move(to: CGPoint(x: Int.random(in: 20...280), y: 700), duration: 0)
   
    //SetupScore
    var score = 0{
        didSet{
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "score: \(formattedScore)"
        }
    }
    
    var Highscore = 0{
        didSet{
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: Highscore as NSNumber) ?? "0"
            LocalscoreLabel.text = "HighScore: \(formattedScore)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
      
        
        setupPlatforms()
        
        setupBackGround()
        
        SetupScoreLabel()
        
        SetupPlayLabel()
        
        SetupLoseLabel()
        
        SetupLocalSessionHighScore()
        
        setupDragon()
        
        setupMeteor()
        
        setupMotionManager()
    
    }
    
    
    //callled every frame
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity.dx = CGFloat(accelerometerData.acceleration.x * 16)
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
    
    
    //after a tap is detected this runs
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
            spawnFireball(SpawnPoint: particles.position, FireShot: FireShot)
            FireShot.run(shoot)
            FireShot.run(removeAfterDead)
            particles.run(removeAfterDead)
            PauseAfterOrBeforeDeath()
                   
        }
    }
    
    
    //whenever a collision is detected this runs
    func didBegin(_ contact: SKPhysicsContact)
    {
        if (contact.bodyA.categoryBitMask == PlatformCategory && contact.bodyB.categoryBitMask == PlayerCategory || contact.bodyB.categoryBitMask == PlatformCategory && contact.bodyA.categoryBitMask == PlayerCategory)
        {
            score += 10
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
            if (Meteor.position.y < 600)
            {
                Meteor.run(KillMeteor, completion: {self.score += 10})
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
    //gets when a chosen spritenode falls off screen and resolves outcomes dependent on which side of frame
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
    
    
    //if dragon hits meteor or falls out of bottom off the frame this function is called and platforms are randomised
    func lose()
    {
        PlayLabel.alpha = 1
        LoseLabel.alpha = 1
        dragon.removeAllActions()
        Meteor.position.y = 700
        isJumping = false
        dragon.run(die)
        dragon.physicsBody?.isDynamic = false
        
        if (score > Highscore)
        {
            Highscore = score
        }
        score = 0
        
        for platform in Platforms
        {
        platform.position = CGPoint(x: Int.random(in:20...280), y: Int.random(in: 0...600))
        }
    }
    
    
    func setupDragon()
    {
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
    }
    
    
    func setupMeteor()
    {
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
    }
    
    
    func spawnFireball(SpawnPoint: CGPoint, FireShot: SKSpriteNode)
    {
        let ShotRadius = FireShot.frame.width/2
        FireShot.position = SpawnPoint
        FireShot.physicsBody = SKPhysicsBody(circleOfRadius: ShotRadius)
        FireShot.physicsBody?.affectedByGravity = false
        FireShot.physicsBody?.categoryBitMask = BulletCategory
        FireShot.physicsBody?.contactTestBitMask = MeteorCategory
        FireShot.physicsBody?.collisionBitMask = MeteorCategory
        addChild(FireShot)
    }
    
    //if player dies or has not played yet, pauses the gamestate until screen is tapped
    func PauseAfterOrBeforeDeath()
    {
        
        if dragon.physicsBody!.isDynamic
        {
          return
        }
        dragon.physicsBody?.isDynamic=true
        isJumping = true
        dragon.run(InitJump, completion: {self.isJumping = false})
        PlayLabel.alpha = 0
        LoseLabel.alpha = 0
    }
    
    
    func SetupScoreLabel()
    {
       scoreLabel.fontSize = 22
       scoreLabel.position = CGPoint(x: 150, y: 500)
       scoreLabel.text = "score 0"
       scoreLabel.zPosition = 100
       scoreLabel.horizontalAlignmentMode = .center
       addChild(scoreLabel)
    }
    
    func SetupPlayLabel()
       {
          PlayLabel.fontSize = 22
          PlayLabel.position = CGPoint(x: 150, y: 300)
          PlayLabel.text = "TAP TO PLAY! :)"
          PlayLabel.zPosition = 100
          PlayLabel.horizontalAlignmentMode = .center
          addChild(PlayLabel)
       }
    
    func SetupLocalSessionHighScore()
    {
        LocalscoreLabel.fontSize = 20
        LocalscoreLabel.position = CGPoint(x: 150, y: 550)
        LocalscoreLabel.text = "Highscore 0"
        LocalscoreLabel.zPosition = 100
        LocalscoreLabel.horizontalAlignmentMode = .center
        addChild(LocalscoreLabel)
    }
    
    func SetupLoseLabel()
    {
        LoseLabel.fontSize = 22
        LoseLabel.position = CGPoint(x: 150, y: 350)
        LoseLabel.text = "You Lost :'("
        LoseLabel.zPosition = 100
        LoseLabel.horizontalAlignmentMode = .center
        LoseLabel.alpha = 0
        addChild(LoseLabel)
    }
    
    func setupBackGround()
    {
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.8
        background.zPosition = -2
        addChild(background)
    }
    
    func setupMotionManager()
    {
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
}



