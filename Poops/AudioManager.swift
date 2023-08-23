//
//  AudioManager.swift
//  Poops
//
//  Created by Park Jisoo on 2023/08/23.
//

import SwiftUI
import AVFoundation

class AudioManager {
    
    static var inst = AudioManager()
    private init() {}
    
    private var bGMPlayer: AVAudioPlayer?
    
    func playBGM(fileName: String, fileType: String, numberOfLoops: Int) {
        playSound(fileName: fileName, fileType: fileType, numberOfLoops: numberOfLoops)
    }
    
    func stopBGM() {
        bGMPlayer?.stop()
    }
    
    private func playSound(fileName: String, fileType: String, numberOfLoops: Int) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else { return }
        do{
            bGMPlayer = try AVAudioPlayer(contentsOf: url)
            bGMPlayer?.numberOfLoops = numberOfLoops
            bGMPlayer?.prepareToPlay()
            bGMPlayer?.play()
        } catch let error {
            print("오류멍. \(error.localizedDescription)")
        }
    }
}
