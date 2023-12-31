//
//  StartScene.swift
//  Poops
//
//  Created by Park Jisoo on 2023/08/22.
//

import SpriteKit
import SwiftUI


class StartScene: SKScene {
    
    private var player : SKSpriteNode?
    private var characterIdleTextures: [SKTexture] = []
    
    override func sceneDidLoad() {
        // play music
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            AudioManager.inst.playBGM(fileName: "startMusic", fileType: "mp3", numberOfLoops: -1)
        })
    }
    
    override func didMove(to view: SKView) {
    
        player = self.childNode(withName: "//player") as? SKSpriteNode
        
        // player idle animation
        characterIdleTextures.append(SKTexture(imageNamed: "playerIdle1"))
        characterIdleTextures.append(SKTexture(imageNamed: "playerIdle2"))
    
        let animationIdle = SKAction.animate(with: characterIdleTextures, timePerFrame: 0.5)
        let animationIdleRepeat = SKAction.repeatForever(animationIdle)
        player!.run(animationIdleRepeat)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touch sound
        AudioManager.inst.playBGM(fileName: "button", fileType: "mp3", numberOfLoops: 0)
        
        // change scene 
        let scene = GameScene(fileNamed: "GameScene")
        scene?.scaleMode = .aspectFit
        let transition = SKTransition.flipVertical(withDuration: 2)
        self.view?.presentScene(scene!, transition: transition)
    }
}


