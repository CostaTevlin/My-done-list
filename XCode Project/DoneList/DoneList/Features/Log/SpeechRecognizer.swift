// SpeechRecognizer.swift
// Observable wrapper around SFSpeechRecognizer + AVAudioEngine for live transcription.

import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechRecognizer {

    var transcript: String = ""
    var isRecording: Bool = false
    var isAvailable: Bool = false
    var authorizationResolved: Bool = false

    private var recognizer: SFSpeechRecognizer?
    private var audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    init() {
        recognizer = SFSpeechRecognizer()
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor [weak self] in
                self?.isAvailable = (status == .authorized)
                self?.authorizationResolved = true
            }
        }
    }

    func startRecording() {
        guard let recognizer, recognizer.isAvailable, !isRecording else { return }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let input = audioEngine.inputNode
        input.installTap(onBus: 0, bufferSize: 1024, format: input.outputFormat(forBus: 0)) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            audioEngine.inputNode.removeTap(onBus: 0)
            request = nil
            return
        }

        task = recognizer.recognitionTask(with: request!) { [weak self] result, _ in
            guard let result else { return }
            Task { @MainActor [weak self] in
                self?.transcript = result.bestTranscription.formattedString
            }
        }

        isRecording = true
    }

    func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.finish()
        request = nil
        task = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func reset() {
        stopRecording()
        transcript = ""
    }
}
