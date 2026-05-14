// SpeechRecognizerStateTests.swift
// State machine tests for SpeechRecognizer — no mic hardware required.
// Uses the test initializer that injects authorization status directly.
//
// Phase: 4.5 (ADR-0010)

import Testing
import Speech
@testable import DoneList

@Suite("SpeechRecognizer state machine")
struct SpeechRecognizerStateTests {

    @Test("Initial state is idle — no recording, no transcript, no noSpeechDetected")
    func testInitialStateIsIdle() {
        let sr = SpeechRecognizer(testingStatus: .notDetermined)
        #expect(sr.isRecording == false)
        #expect(sr.transcript == "")
        #expect(sr.noSpeechDetected == false)
        #expect(sr.authorizationResolved == true)
    }

    @Test("Denied status reports isAvailable false and correct authorizationStatus")
    func testAuthorizationDeniedReportsCorrectStatus() {
        let sr = SpeechRecognizer(testingStatus: .denied)
        #expect(sr.authorizationStatus == .denied)
        #expect(sr.isAvailable == false)
        #expect(sr.authorizationResolved == true)
    }

    @Test("Authorized status reports isAvailable true")
    func testAuthorizedStatusReportsAvailable() {
        let sr = SpeechRecognizer(testingStatus: .authorized, available: true)
        #expect(sr.authorizationStatus == .authorized)
        #expect(sr.isAvailable == true)
    }

    @Test("startRecording without permission does not set isRecording and clears isAvailable")
    func testStartWithoutPermissionTransitionsToDenied() {
        let sr = SpeechRecognizer(testingStatus: .denied)
        sr.startRecording()
        // startRecording guards on .authorized — should be a no-op for recording
        #expect(sr.isRecording == false)
        #expect(sr.isAvailable == false)
    }

    @Test("reset clears transcript and stops recording state")
    func testResetClearsTranscript() {
        let sr = SpeechRecognizer(testingStatus: .notDetermined)
        // Simulate a transcript being present (via test-only access pattern)
        // We can't call startRecording without a real recognizer, so verify
        // that reset leaves everything in a clean known state.
        sr.reset()
        #expect(sr.transcript == "")
        #expect(sr.isRecording == false)
        #expect(sr.noSpeechDetected == false)
    }

    @Test("stopRecording on already-stopped recognizer is safe (no crash)")
    func testStopRecordingIdempotent() {
        let sr = SpeechRecognizer(testingStatus: .authorized, available: true)
        // Not recording — stop should be a no-op, not a crash
        sr.stopRecording()
        #expect(sr.isRecording == false)
    }

    @Test("reset followed by reset is safe")
    func testDoubleReset() {
        let sr = SpeechRecognizer(testingStatus: .authorized, available: true)
        sr.reset()
        sr.reset()
        #expect(sr.transcript == "")
        #expect(sr.isRecording == false)
    }
}
