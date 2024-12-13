//
//  SoundManager.swift
//  ShootingApp
//
//  Created by Jose on 13/12/2024.
//

import AVFoundation

enum SoundType: String {
    case drone = "drone_sound"
    case shoot = "shoot_sound"
    case explosion = "explosion_sound"
}

class SoundManager {
    static let shared = SoundManager()
    
    private let audioEngine = AVAudioEngine()
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    private var audioPlayerNodes: [String: AVAudioPlayerNode] = [:]
    
    // Dictionary to track whether a sound is already playing
    private var isSoundPlaying: [String: Bool] = [:]
    
    private init() {
        // Attach the main mixer node to the output node
        let mainMixerNode = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        
        // Ensure that the main mixer node is connected to the output node
        audioEngine.connect(mainMixerNode, to: outputNode, format: nil)
        
        try? audioEngine.start()
    }
    
    // Resume the audio engine when the app comes to the foreground
    func resumeAudioEngine() {
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                print("Audio engine resumed")
            } catch {
                print("Failed to restart audio engine: \(error.localizedDescription)")
            }
        }
    }
    
    // Pause the audio engine when the app goes to the background
    func pauseAudioEngine() {
        if audioEngine.isRunning {
            audioEngine.pause()
            print("Audio engine paused")
        }
    }
    
    // Preload multiple sounds into memory
    func preloadSounds(sounds: [SoundType], withExtension fileExtension: String = "m4a") {
        for type in sounds {
            guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: fileExtension) else {
                print("Sound file \(type.rawValue) not found")
                continue
            }
            
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let audioFormat = audioFile.processingFormat
                let audioFrameCount = UInt32(audioFile.length)
                if let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) {
                    try audioFile.read(into: audioBuffer)
                    audioBuffers[type.rawValue] = audioBuffer
                    
                    // Create a player node for each sound
                    let playerNode = AVAudioPlayerNode()
                    audioPlayerNodes[type.rawValue] = playerNode
                    audioEngine.attach(playerNode)
                    audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)
                }
            } catch {
                print("Error preloading sound \(type.rawValue): \(error.localizedDescription)")
            }
        }
    }
    
    func playSound(type: SoundType, loop: Bool = false) {
        // Check if the sound is already playing
        if let isPlaying = isSoundPlaying[type.rawValue], isPlaying {
            print("\(type.rawValue) is already playing, skipping playback.")
            return
        }
        
        guard let buffer = audioBuffers[type.rawValue], let playerNode = audioPlayerNodes[type.rawValue] else {
            print("Sound \(type.rawValue) not preloaded")
            return
        }
        
        // Set the sound as playing
        isSoundPlaying[type.rawValue] = true
        
        DispatchQueue.global(qos: .background).async {
            if loop {
                // For looping sound (drone sound), use `.loops`
                playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            } else {
                // For one-time sounds (like shoot sound), use `.interruptsAtLoop`
                playerNode.scheduleBuffer(buffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
            }
            playerNode.play()
            
            // When the sound finishes playing, reset its state
            if !loop {
                // Reset the playing state after sound finishes playing
                playerNode.scheduleBuffer(buffer, at: nil, options: .interruptsAtLoop) { [weak self] in
                    self?.isSoundPlaying[type.rawValue] = false
                }
            }
        }
    }
    
    func stopSound(type: SoundType) {
        guard let playerNode = audioPlayerNodes[type.rawValue] else {
            print("Sound \(type.rawValue) not found")
            return
        }
        
        playerNode.stop()
        isSoundPlaying[type.rawValue] = false
    }
}
