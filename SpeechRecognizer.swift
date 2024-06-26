//
//  SpeechRecognizer.swift
//  Scene
//
//  Created by TamYeeLam on 24/11/2023.
//

import AVFoundation
import Foundation
import Speech
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @Published var transcript: String = ""
    @Published var selectedAnimationIndex = 0
    @Published var ARAnimationIndex = 0
    
    
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        recognizer = SFSpeechRecognizer()
        
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
    
    deinit {
        reset()
    }
    
    /// Reset the speech recognizer.
        func reset() {
            task?.cancel()
            audioEngine?.stop()
            audioEngine = nil
            request = nil
            task = nil
        }
    
    /**
           Begin transcribing audio.
        
           Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
           The resulting transcription is continuously written to the published `transcript` property.
        */
       func transcribe() {
           DispatchQueue(label: "Speech Recognizer Queue", qos: .userInteractive).async { [weak self] in
               guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                   self?.speakError(RecognizerError.recognizerIsUnavailable)
                   return
               }
               
               do {
                   let (audioEngine, request) = try Self.prepareEngine()
                   self.audioEngine = audioEngine
                   self.request = request
                   
                   self.task = recognizer.recognitionTask(with: request) { result, error in
                       let receivedFinalResult = result?.isFinal ?? false
                       let receivedError = error != nil // != nil mean there's error (true)
                       
                       if receivedFinalResult || receivedError {
                           audioEngine.stop()
                           audioEngine.inputNode.removeTap(onBus: 0)
                       }
                       
                       if let result = result {
                           self.speak(result.bestTranscription.formattedString)
                       }
                   }
               } catch {
                   self.reset()
                   self.speakError(error)
               }
           }
       }
       
       private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
           let audioEngine = AVAudioEngine()
           
           let request = SFSpeechAudioBufferRecognitionRequest()
           request.shouldReportPartialResults = true
           
           let audioSession = AVAudioSession.sharedInstance()
           try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
           try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
           let inputNode = audioEngine.inputNode
           
           let recordingFormat = inputNode.outputFormat(forBus: 0)
           inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
               (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
               request.append(buffer)
           }
           audioEngine.prepare()
           try audioEngine.start()
           
           return (audioEngine, request)
       }
    
    /// Stop transcribing audio.
        func stopTranscribing() {
            reset()
        }
    
    private func speak(_ message: String) {
        transcript = message
        recognizeCommand()
    }
    
    private func recognizeCommand(){
        print(transcript)
        if transcript.lowercased().contains("sit") {
            reset()
            selectedAnimationIndex = 2
            transcribe()
        } else if transcript.lowercased().contains("stand") {
            reset()
            selectedAnimationIndex = 1
            transcribe()
        } else if transcript.lowercased().contains("walk") {
            reset()
            selectedAnimationIndex = 4
            transcribe()
        } else if transcript.lowercased().contains("speak") {
            reset()
            selectedAnimationIndex = 5
            transcribe()
        } else if transcript.lowercased().contains("move") {
            reset()
            ARAnimationIndex = 6
            transcribe()
        } else if transcript.lowercased().contains("left") {
            reset()
            ARAnimationIndex = 7
            transcribe()
        } else if transcript.lowercased().contains("right") {
            reset()
            ARAnimationIndex = 8
            transcribe()
        } else {
            return
        }
    }
    
    private func speakError(_ error: Error) {
            var errorMessage = ""
            if let error = error as? RecognizerError {
                errorMessage += error.message
            } else {
                errorMessage += error.localizedDescription
            }
            transcript = "<< \(errorMessage) >>"
    }
    
}


extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}

