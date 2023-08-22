//
//  GameScene.swift
//  NC2_Practice -> Poops
//
//  Created by Park Jisoo on 2023/08/17.
//

import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playerCategory: UInt32 = 1 << 0 // 0000 0001 == 1
    let poopCategory:UInt32 = 1 << 1    // 0000 0010 == 2
    let itemCategory:UInt32 = 1 << 2    // 0000 0100 == 4
    let groundCategory:UInt32 = 1 << 3  // 0000 1000 == 8
    
    private var currentSurvivalTimeLabel : SKLabelNode?
    private var player : SKSpriteNode?
    private var characterIdleTextures: [SKTexture] = []
    private var characterWalkTextures: [SKTexture] = []
    
    // number of objects fall
    private var numObj = 0
    private var maxObj = 6
    
    var countTimer = Timer()
    private var survivalTime = 0
    private var bestRecord = UserDefaults.standard.integer(forKey: "bestRecord")
    
    // player movement
    private var touchedLocation = CGPoint()
    private var touchedDatumPoint = CGPoint()
    private var playerDatumPoint: CGFloat = 0
    
    private var reverseDirection = false
    private var datumPoint: CGFloat = 0
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        // survival timer
        startTimer()
        
        // Get label node from scene and store it for use later
        self.currentSurvivalTimeLabel = self.childNode(withName: "//survivalTime") as? SKLabelNode
        self.player = self.childNode(withName: "//player") as? SKSpriteNode
        
        // player idle animation
        characterIdleTextures.append(SKTexture(imageNamed: "playerIdle1"))
        characterIdleTextures.append(SKTexture(imageNamed: "playerIdle2"))
        
        // player walk animation
        characterWalkTextures.append(SKTexture(imageNamed: "playerWalk1"))
        characterWalkTextures.append(SKTexture(imageNamed: "playerWalk2"))
        
        playerAnimationIdle()
        
        // contactTestBitMask => Trigger, no interation
        // collisionBitMask => Collider, yes interaction
        // check player collision
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.contactTestBitMask = poopCategory | itemCategory
        player?.physicsBody?.collisionBitMask = poopCategory | itemCategory | groundCategory
        
        // check ground collision
        let ground = self.childNode(withName: "//ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = groundCategory
        ground?.physicsBody?.contactTestBitMask = poopCategory | itemCategory
        ground?.physicsBody?.collisionBitMask = poopCategory | itemCategory | playerCategory
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.8)
    }
    
    
    func playerAnimationIdle() {
        let animationIdle = SKAction.animate(with: characterIdleTextures, timePerFrame: 0.5)
        let animationIdleRepeat = SKAction.repeatForever(animationIdle)
        player!.run(animationIdleRepeat)
    }
    
    func playerAnimationWalk() {
        let animationWalk = SKAction.animate(with: characterWalkTextures, timePerFrame: 0.5)
        let animationIdleRepeat = SKAction.repeatForever(animationWalk)
        player!.run(animationIdleRepeat)
    }
    
    
    
    // drop random objects
    func dropObj() {
        // random items & random position
        let randomItem = Int.random(in: 1...6)
        let randomX = Int.random(in: -355...355)
        let randomY = Int.random(in: 680...1000)
        
        var obj = SKSpriteNode(imageNamed: "poop")
        obj.position = CGPoint(x: randomX, y: randomY)
        obj.name = "poop"
        
        obj.physicsBody = SKPhysicsBody.init(texture: obj.texture!, size: obj.size)
        obj.physicsBody?.categoryBitMask = poopCategory
        obj.physicsBody?.contactTestBitMask = groundCategory | playerCategory
        addChild(obj)
        
        if (randomItem % 3 == 0) {
            obj.name = "reverseItem"
            obj.physicsBody = SKPhysicsBody.init(texture: obj.texture!, size: obj.size)
            obj.texture = SKTexture(imageNamed: "reverseItem")
            obj.physicsBody?.categoryBitMask = itemCategory
        }
        numObj += 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            playerDatumPoint = player!.position.x
            touchedDatumPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchedLocation = touch.location(in: self)
            if reverseDirection {
                reverseMovePlayer()
            } else {
                movePlayer()
            }
        }
    }
    
    func flipPlayer (dir: CGFloat) {
        player?.xScale = dir
    }
    
    func reverseMovePlayer() {
        let moveDirection = touchedDatumPoint.x - touchedLocation.x
        let playermove = playerDatumPoint + moveDirection
        let lastMove = player!.position.x
        
        // player moves to left
        if lastMove > playermove {
            flipPlayer(dir: 1)
        } else {
            flipPlayer(dir: -1)
        }

        if playermove < -375 + (player!.size.width / 2) {
            player?.position.x = -375 + (player!.size.width / 2)
        }
        else if playermove > 375 - (player!.size.width / 2) {
            player?.position.x = 375 - (player!.size.width / 2)
        }
        else {
            player?.position.x = playermove
        }
        
    }
    
    func movePlayer() {
        datumPoint = playerDatumPoint - touchedDatumPoint.x
        let playermove = datumPoint + touchedLocation.x
        let lastMove = player!.position.x
        
        // player moves to left
        if lastMove > playermove {
            flipPlayer(dir: 1)
        } else {
            flipPlayer(dir: -1)
        }

        if playermove < -375 + (player!.size.width / 2) {
            player?.position.x = -375 + (player!.size.width / 2)
        }
        else if playermove > 375 - (player!.size.width / 2) {
            player?.position.x = 375 - (player!.size.width / 2)
        }
        else {
            player?.position.x = playermove
        }
        
    }
    

    // called when two differents categorybitmasks collide
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
        case groundCategory | poopCategory :
            let poop = contact.bodyA.categoryBitMask == poopCategory ? contact.bodyA : contact.bodyB
            poop.categoryBitMask = 0
            self.numObj -= 1
            let delayAction = SKAction.wait(forDuration: 0.2)
            let removeAction = SKAction.run {
                poop.node?.removeFromParent()
                
            }
            let sequence = SKAction.sequence([delayAction, removeAction])
            run(sequence)
            
        case groundCategory | itemCategory :
            let item = contact.bodyA.categoryBitMask == itemCategory ? contact.bodyA : contact.bodyB
            item.categoryBitMask = 0
            self.numObj -= 1
            let delayAction = SKAction.wait(forDuration: 0.5)
            let removeAction = SKAction.run {
                item.node?.removeFromParent()
            }
            let sequence = SKAction.sequence([delayAction, removeAction])
            run(sequence)
            
        case playerCategory | itemCategory :
            let item = contact.bodyA.categoryBitMask == itemCategory ? contact.bodyA : contact.bodyB
            item.categoryBitMask = 0
            item.node?.removeFromParent()
            
            // reset current datum position_touch position & player position
            touchedDatumPoint = touchedLocation
            playerDatumPoint = player!.position.x
            
            reverseDirection.toggle()
            self.numObj -= 1
            
            
        case playerCategory | poopCategory :
            stopTimer()
            player?.texture = SKTexture(imageNamed: "playerDead")
            
            let scene = GameOver(fileNamed: "GameOver")
            
            // new record
            if bestRecord < survivalTime {
                UserDefaults.standard.set(survivalTime, forKey: "bestRecord")
                scene!.newRecord = true
            }
            
            scene!.bestRecord = bestRecord
            scene!.survivalTime = survivalTime
            scene!.scaleMode = .aspectFit
            let transition = SKTransition.crossFade(withDuration: 4)
            self.view?.presentScene(scene!, transition: transition)
            
        default :
            break
        }
    }
    
    func startTimer() {
        countTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSurvivalTime), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        countTimer.invalidate()
    }
    
    @objc func updateSurvivalTime() {
        survivalTime += 1
        currentSurvivalTimeLabel?.text = #"Survival Time : \#(survivalTime / 60)' \#(survivalTime % 60)""#
        
        if survivalTime % 5 == 0 {
            maxObj += 1
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        if (numObj < maxObj) {
            dropObj()
        }
    }
}
