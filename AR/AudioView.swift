//
//  AudioView.swift
//  AR
//
//  Created by Chi Chi Chan on 25/11/2023.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @State public var audioPlayer: AVAudioPlayer?
    @Binding var selectedAnimationIndex: Int

    var body: some View {
        VStack {

        }.onAppear{
            playSound()
        }
        .onChange(of: selectedAnimationIndex) { newValue in
            // Call playSound() whenever selectedAnimationIndex changes
            print("value change")
            playSound()
        }
    }
    
    
    private func playButtonTapped() {
        guard let audioFileURL = Bundle.main.url(forResource: "meow", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    private func playSound() {
//       print("triger")
        print($selectedAnimationIndex.wrappedValue)
        if($selectedAnimationIndex.wrappedValue != 5){return}
        print("in audio: triger",selectedAnimationIndex)
        
        guard let audioFileURL = Bundle.main.url(forResource: "meow", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.play()
            print("play")

        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    private func stopButtonTapped() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

//struct AudioPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioPlayerView(selectedAnimationIndex: 0)
//    }
//}
