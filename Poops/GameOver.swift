//
//  GameOver.swift
//  NC2_Practice
//
//  Created by Park Jisoo on 2023/08/19.
//

import SpriteKit
import GameplayKit

class GameOver: SKScene {
    
    
    public var newRecord = false
    public var survivalTime = 0
    public var bestRecord = 0
    
    private var gameOverLabel : SKLabelNode?
    private var bestRecordLabel : SKLabelNode?
    private var survivalTimeLabel : SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        self.gameOverLabel = self.childNode(withName: "//gameOver") as? SKLabelNode
        self.survivalTimeLabel = self.childNode(withName: "//survivalTime") as? SKLabelNode
        self.bestRecordLabel = self.childNode(withName: "//bestRecord") as? SKLabelNode
        
        if newRecord == true {
            gameOverLabel?.fontColor = .green
            gameOverLabel?.text = "New Record!"
            bestRecordLabel?.isHidden = true
            survivalTimeLabel?.text = #"You're the best : \#(survivalTime / 60)' \#(survivalTime % 60)""#
        }
        else {
            bestRecordLabel?.text = #"Best Record : \#(bestRecord / 60)' \#(bestRecord % 60)""#
            survivalTimeLabel?.text = #"Your Survival Time : \#(survivalTime / 60)' \#(survivalTime % 60)""#
        }
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "restart" {
                newRecord = false
                let scene = GameScene(fileNamed: "GameScene")
                 scene?.scaleMode = .aspectFit
                 self.view?.presentScene(scene)
            }
        }
    }
}
