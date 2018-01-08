//
//  GameScene.swift
//  SpaceGame
//
//  Created by Michael Zetune on 2/22/15.
//  Copyright (c) 2015 Michael Zetune. All rights reserved.
//

import SpriteKit
import UIKit



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // bit mask values
    let shipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1
    
    var score = 0
    var scoreLabel: SKLabelNode!
    var lastScore: Int?
    
    // Declare a property to share between methods
    var playerShip: SKSpriteNode!
    
    var playerNode: SKNode!
    
    var gamePlayPaused: Bool = false
    
    var asteroidLayer: SKNode!
    var starLayer: SKNode!  // moving stars and objects in the particle
    
    var background: SKSpriteNode! // (galaxy image) needs to be initialized before using
    
    // UI
    var pauseButton: UIButton!
    var lostAlert: UIAlertController?
    var lost: Bool = false
    

    
    override func didChangeSize(oldSize: CGSize) {
        
        // adjust game logic
        background?.size = frame.size // using optional chaining
        background?.position = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
    }
    
    func reset() {
        
        // start initial state
        
        resumeGamePlay()
        
        score = 0
        scoreLabel.text = "Score: \(score)"
        
        // remove asteroids?
        // reset player location?
        // animation to show re-spawn or a new game
        
    }
    
    // pause and resume method
    
    func pauseButtonPressed(sender: AnyObject) {
        
        if !gamePlayPaused {
            pauseGamePlay() } else {
            resumeGamePlay() }
    }
    
    func  pauseGamePlay() {
        
        physicsWorld.speed = 0 // pause physics
        asteroidLayer.paused = true
        starLayer.paused = true
        
        gamePlayPaused = true
        
        /* ******* Code Challenge 8.4 ******************** FIX FOR ENTIRE BACKGROUND INSTEAD OF JUST SHIP
        
        var fadeInAction = SKAction.fadeInWithDuration(2.0)
        var fadeOutAction = SKAction.fadeOutWithDuration(2.0)
        var fadeSequence = SKAction.sequence([fadeInAction , fadeOutAction])
        var fadeForever = SKAction.repeatActionForever(fadeSequence)
        playerShip.runAction(fadeForever, withKey: "FadeForeverAction")
        
        **************************************************/
        
    }
    
    func resumeGamePlay() {
        
        physicsWorld.speed = 1 // resume physics
        asteroidLayer.paused = false
        starLayer.paused = false
        
        gamePlayPaused = false
        
        
        /* ******** Code Challenge 8.4 cont. ************
        
        playerShip.removeActionForKey("FadeForeverAction")
        var fadeInAction = SKAction.fadeInWithDuration(0.5)
        playerShip.runAction(fadeInAction)
        
        ************************************************* */
        
    }
    
    
    
    override func didMoveToView(view: SKView) {
    
        
        
        physicsWorld.contactDelegate = self // for when come in contact and end contact. Conforms to protocol SKPhysicsContactDelegate above in order to do this
        
        // Random floating point numbers (CGFloat, Double, Float)
        
        srand48(time(nil)) // seed only once in code, uses time to determine value which then changes with each run
        var number = drand48() // [0.0, 1.0]
        println("Random drand48 number with srand48 seed: \(number)")
        
        physicsWorld.gravity = CGVectorMake(0.0, -0.75)
        
        let width = UIScreen.mainScreen().bounds.size.width // same as frame.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        background = SKSpriteNode(imageNamed: "GalaxyBackground")
        background.position = CGPoint(x: width/2.0 , y: height/2.0)
        
        // Makes the background the same size of the screen (stretches it)
        background.size = CGSize(width: width, height: height)
        
        background.zPosition = 0
        addChild(background)
        
        // Star particles
        
        var starsPath = NSBundle.mainBundle().pathForResource("Stars", ofType: "sks")!
        var starEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(starsPath) as! SKEmitterNode
        starEmitter.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetHeight(frame))
        starEmitter.particlePositionRange.dx = CGRectGetWidth(frame)
        
        starEmitter.advanceSimulationTime(10)
        
        
        starLayer = SKNode()
        starLayer.zPosition = 1
        
        addChild(starLayer)
        
        starLayer.addChild(starEmitter) // adding particle effects to the star layer
        
        
        // contains the player image and particles, anything else
        playerNode = SKNode()
        playerNode.position = CGPoint(x: 200, y: 400)
        playerNode.zPosition = 5
        addChild(playerNode)
        
        // Load image of ship and display it
        
        playerShip = SKSpriteNode(imageNamed: "zach-S")
        
        
        //        playerShip.position = CGPoint(x: 200, y: 200)
        
        playerShip.physicsBody = SKPhysicsBody(texture: playerShip.texture, size: playerShip.size)
        playerShip.physicsBody?.dynamic = false
        
        
        // collision rules
        
        playerShip.physicsBody?.categoryBitMask = shipCategory // ship, specifying the type of object for the physics system to know
        playerShip.physicsBody?.collisionBitMask = asteroidCategory // if asteroid intersects ship, they bounce off each other
        playerShip.physicsBody?.contactTestBitMask = asteroidCategory
        playerShip.zPosition = 1
        playerShip.xScale = 0.5
        playerShip.yScale = 0.5
        
        playerNode.addChild(playerShip)
        
        
        // Thruster
        
//        var playerThrusterPath = NSBundle.mainBundle().pathForResource("Thruster", ofType: "sks")!
//        
//        var playerThruster = NSKeyedUnarchiver.unarchiveObjectWithFile(playerThrusterPath) as! SKEmitterNode
//        
//        playerThruster.xScale = 0.8
//        playerThruster.yScale = 0.8
        
        //        playerThruster.position = playerShip.position
        
        //        playerThruster.zPosition = 0 // below ship
        
        //        playerNode.addChild(playerThruster)
        
        // Control the composition of the effect (blending!)
        
//        var playerThrusterEffectNode = SKEffectNode()
//        playerThrusterEffectNode.addChild(playerThruster)
//        playerThrusterEffectNode.zPosition = 0
        
//        playerThrusterEffectNode.position.y = -20
        
//        playerNode.addChild(playerThrusterEffectNode)
        
        
        
        //    asteroid actions (spawning)
        
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 3
        addChild(asteroidLayer)
        
        
        
        // run code, wait, repeat sequence forever
        
        let asteroidCreateAction = SKAction.runBlock { () -> Void in
            let asteroid = self.createAsteroid()
            self.asteroidLayer.addChild(asteroid)
            
        }
        
        
        
        let asteroidsPerSecond: CGFloat = 1.5
        let asteroidInterval = NSTimeInterval(1.0/asteroidsPerSecond)
        let asteroidWaitAction = SKAction.waitForDuration(asteroidInterval, withRange: 0.0)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction, asteroidWaitAction])
        let asteroidRepeatAction = SKAction.repeatActionForever(asteroidSequenceAction)
        
        asteroidLayer.runAction(asteroidRepeatAction)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        
        scoreLabel.position = CGPoint(x: frame.width/2.0, y: frame.height-scoreLabel.calculateAccumulatedFrame().height-70)
        scoreLabel.zPosition = 10 // topmost layer
        
        score = 0 // reset method later??
        
        addChild(scoreLabel)
        
        
        
        
        
    }
    
    func saveScreenshot() {
        
//        //Create the UIImage
//        UIGraphicsBeginImageContextWithOptions(self.view!.frame.size, false, 0.0)
//        self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        //Save it to the camera roll
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    
    //    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) { // fix for Swift 1.2 below:
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        
        if !gamePlayPaused {
            
            
            if let touch = touches.first as? UITouch { // works for one touch. ".first" refers to first touch
                
                
                let location = touch.locationInNode(self)
                
                /* ****************** Code challenge 2.6: *********
                
                var translation = CGVector(dx: 0, dy: 0)
                if location.x < CGRectGetMidX(frame) {
                translation = CGVector(dx: -50, dy: 0)
                } else if location.x >= CGRectGetMidX(frame) {
                translation = CGVector(dx: 50, dy:0)
                }
                let move = SKAction.moveBy(translation, duration: 0.25)
                
                *******************************************
                
                Replaces next line: */
                
                //let move = SKAction.moveTo(location, duration: 0.25)
                
                let distance = distanceBetweenPoints(playerNode.position, b: location)
                println("distance: \(distance)")
                
                var playerSpeed: CGFloat = 1000 // points per second //CGFloat(300)
                
                let time = timeToTravelDistance(distance, speed: playerSpeed)
                
                let move = SKAction.moveTo(location, duration: time)
                move.timingMode = SKActionTimingMode.EaseInEaseOut
                println("time: \(time)")
                
                playerNode.runAction(move)
            }
        }
        
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if !gamePlayPaused {
            
            
            if let touch = touches.first as? UITouch { // works for one touch. ".first" refers to first touch
                
                
                let location = touch.locationInNode(self)
                
                /* ****************** Code challenge 2.6: *********
                
                var translation = CGVector(dx: 0, dy: 0)
                if location.x < CGRectGetMidX(frame) {
                translation = CGVector(dx: -50, dy: 0)
                } else if location.x >= CGRectGetMidX(frame) {
                translation = CGVector(dx: 50, dy:0)
                }
                let move = SKAction.moveBy(translation, duration: 0.25)
                
                *******************************************
                
                Replaces next line: */
                
                //let move = SKAction.moveTo(location, duration: 0.25)
                
                let distance = distanceBetweenPoints(playerNode.position, b: location)
                println("distance: \(distance)")
                
                var playerSpeed: CGFloat = 1000 // points per second //CGFloat(300)
                
                let time = timeToTravelDistance(distance, speed: playerSpeed)
                
                let move = SKAction.moveTo(location, duration: time)
                move.timingMode = SKActionTimingMode.EaseInEaseOut
                println("time: \(time)")
                
                playerNode.runAction(move)
            }
        }

    }
    
    
    
    func distanceBetweenPoints(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt(pow((b.x-a.x),2) + pow((b.y-a.y),2))
    }
    
    
    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> NSTimeInterval {
        let time = distance/speed
        return NSTimeInterval(time)
    }
    
    
    func createAsteroid() -> SKSpriteNode {
        var asteroid: SKSpriteNode
        var imageRan = drand48()
        if imageRan < 0.5 {
            asteroid = SKSpriteNode(imageNamed: "Asteroid1")
            asteroid.xScale = 1.5
            asteroid.yScale = 1.5 }
        else {
            asteroid = SKSpriteNode(imageNamed: "Asteroid2")
            asteroid.xScale = 0.5
            asteroid.yScale = 0.5 }
        
        asteroid.zPosition = 2
        
        // random position
        
        // arc4random_uniform(10) -> [0,9]
        
        var randomX = CGFloat(arc4random_uniform(UInt32(frame.size.width)))
        
        asteroid.position.x = randomX
        asteroid.position.y = frame.size.height + asteroid.size.height // moves offscreen
        
        //        println("random: \(arc4random_uniform(10))")
        //        println("width: \(frame.size)")x
        
        // ***** Code challenge 3.5: **************
        
//        var ranScale = drand48()
//        if ranScale > 0.5 {
//            ranScale = 0.5 }
//        if ranScale < 0.3 {
//            ranScale = 0.3
//        }
//        
//        // reduce the size
//        asteroid.xScale = CGFloat(ranScale)
//        asteroid.yScale = CGFloat(ranScale)
        
        
        // add physics
        
        // add this only after any size of image changes
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture, size: asteroid.size)
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = shipCategory | asteroidCategory // asteroids?
        asteroid.physicsBody?.contactTestBitMask = shipCategory // don't really care for asteroid to asteroid interaction
        
        
        
        // extra SKNode and SKPhysicsBody properties to play with
        asteroid.physicsBody?.restitution = 0.5
        asteroid.physicsBody?.linearDamping = 0.3
        asteroid.alpha = 0.7
        
        
        asteroid.name = "asteroid"
        
        // Rotation randomness
//        var randRotate = drand48()
//        asteroid.physicsBody?.angularVelocity = CGFloat(randRotate * 4.0 * M_PI)
        
        // Velocity randomness
        var maxXSpeed: CGFloat = 10
        var xSpeed: CGFloat = CGFloat(drand48() * 2.0 - 1.0) * maxXSpeed  // [-1, 1] * 10  = [-10, 10] x direction
        var maxYSpeed: CGFloat = -200
        var ySpeed: CGFloat = CGFloat(drand48()) * maxYSpeed  // [0, 1] * -200 = [0, -200]
        
        asteroid.physicsBody?.velocity = CGVectorMake(xSpeed, ySpeed)
        
        return asteroid
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        
        //        println("time: \(currentTime)")
        
        //        var asteroid = createAsteroid()
        //        addChild(asteroid)
        
    }
    
    override func didSimulatePhysics() {
        
        // is an asteroid offscreen?
        
        asteroidLayer.enumerateChildNodesWithName("asteroid", usingBlock: { (asteroid: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            //            println("found asteroid")
            
            
            if asteroid.position.y < -10 {
                // it is offscreen
                asteroid.removeFromParent()
                
                self.score = self.score + 1 // use self to get access to property in code file from outside this block
                self.scoreLabel.text = "Score: \(self.score)" // same story with self here
                
                
                
            }
            
        })
        
        lastScore = self.score
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // a collision happened
        
        println("collision")
        
        if (contact.bodyA.categoryBitMask == shipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == shipCategory) && score > 5 {
            
            
            
            pauseGamePlay()
                
                lostAlert = UIAlertController(title: "You Lose!", message: "Your score was \(self.lastScore)", preferredStyle: UIAlertControllerStyle.Alert)
                
                lostAlert!.addAction(UIAlertAction(title: "Play Again!", style: .Default, handler: { (action: UIAlertAction!) in

                    self.resumeGamePlay()
                    
                }))

            
            
//            // game over
//            score = 0 // reset score and notify player
//            scoreLabel.text = "Score: \(score)"
            
        }
    }
    
    
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
    
}


