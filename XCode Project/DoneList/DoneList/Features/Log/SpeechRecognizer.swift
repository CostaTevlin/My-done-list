// SpeechRecognizer.swift
// Observable wrapper around SFSpeechRecognizer + AVAudioEngine for live transcription.
// On-device recognition only — per ADR-0011 (privacy-first).
//
// Phase: 4.5 (ADR-0010, ADR-0011)

import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechRecognizer {

    // MARK: - Observable state

    var transcript: String = ""
    var isRecording: Bool = false
    var isAvailable: Bool = false
    var authorizationResolved: Bool = false
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    /// Set true after 3s of no recognised speech while recording.
    /// Cleared the moment any transcript token arrives or recording stops.
    var noSpeechDetected: Bool = false

    // MARK: - Private

    private var recognizer: SFSpeechRecognizer?
    private var audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var noSpeechTask: Task<Void, Never>?

    // MARK: - Init (production)

    init() {
        recognizer = SFSpeechRecognizer()
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor [weak self] in
                self?.authorizationStatus = status
                self?.isAvailable = (status == .authorized)
                self?.authorizationResolved = true
            }
        }
    }

    // MARK: - Init (testing only — does not call SFSpeechRecognizer.requestAuthorization)

    init(testingStatus: SFSpeechRecognizerAuthorizationStatus, available: Bool = false) {
        self.authorizationStatus = testingStatus
        self.isAvailable = available
        self.authorizationResolved = true
        self.recognizer = nil
    }

    deinit {
        noSpeechTask?.cancel()
        if isRecording {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            request?.endAudio()
            task?.finish()
        }
    }

    // MARK: - Recording

    func startRecording() {
        guard authorizationStatus == .authorized else {
            isAvailable = false
            return
        }
        guard let recognizer, recognizer.isAvailable, !isRecording else { return }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        request?.requiresOnDeviceRecognition = true   // ADR-0011: privacy — no network STT

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
                guard let self else { return }
                self.transcript = result.bestTranscription.formattedString
                self.noSpeechDetected = false
                self.noSpeechTask?.cancel()
            }
        }

        isRecording = true
        noSpeechDetected = false
        scheduleNoSpeechTimer()
    }

    func stopRecording() {
        guard isRecording else { return }
        noSpeechTask?.cancel()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.finish()
        request = nil
        task = nil
        isRecording = false
        noSpeechDetected = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func reset() {
        stopRecording()
        transcript = ""
    }

    // MARK: - Private

    private func scheduleNoSpeechTimer() {
        noSpeechTask?.cancel()
        noSpeechTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard let self, !Task.isCancelled, self.transcript.isEmpty else { return }
            self.noSpeechDetected = true
        }
    }
}
