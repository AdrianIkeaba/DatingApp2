//
//  RecordingViewModel.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//

import SwiftUI
import Combine
import AVFoundation

@MainActor
class RecordingViewModel: ObservableObject {
    @Published var recordingState: RecordingState = .idle
    @Published var currentTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var waveformAmplitudes: [Float] = []
    @Published var playbackProgress: Double = 0
    @Published var lastProgress: Double = 0
    
    private var timer: Timer?
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    
    enum RecordingState {
        case idle
        case recording
        case stopped
        case playing
        case paused
        case ready
    }
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startRecording() {
        guard recordingState == .idle else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsPath.appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            recordingState = .recording
            currentTime = 0
            waveformAmplitudes = []
            
            startTimer()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard recordingState == .recording else { return }

        audioRecorder?.stop()
        recordingState = .stopped
        totalTime = currentTime
        stopTimer()

        if let url = recordingURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                Task { await self.computeWaveformFromFile() }
            } catch {
                print("Failed to prepare audio player: \(error)")
            }
        }
    }
    
    func playRecording() {
        guard recordingState == .stopped || recordingState == .paused else { return }
        
        if let player = audioPlayer {
            currentTime = player.currentTime
            playbackProgress = currentTime / totalTime
            lastProgress = playbackProgress
        }
        
        audioPlayer?.play()
        recordingState = .playing
        startTimer()
    }
    
    func pauseRecording() {
        guard recordingState == .playing else { return }
        
        audioPlayer?.pause()
        recordingState = .paused
        
        if let player = audioPlayer {
            currentTime = player.currentTime
            let finalProgress = currentTime / totalTime
            playbackProgress = finalProgress
            lastProgress = finalProgress
        }
        
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                switch self.recordingState {
                case .recording:
                    self.currentTime += 0.05
                    self.updateWaveform()
                case .playing:
                    if let player = self.audioPlayer {
                        self.currentTime = player.currentTime
                        let newProgress = self.currentTime / self.totalTime
                        
                        withAnimation(.linear(duration: 0.05)) {
                            self.playbackProgress = newProgress
                        }
                        
                        self.lastProgress = newProgress

                        if !player.isPlaying {
                            self.recordingState = .paused
                            self.stopTimer()
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func computeWaveformFromFile() async {
        guard let url = recordingURL else { return }
        let asset = AVURLAsset(url: url)
        guard let reader = try? AVAssetReader(asset: asset) else { return }

        let tracks = try? await asset.loadTracks(withMediaType: .audio)
        guard let track = tracks?.first else { return }

        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMBitDepthKey: 32
        ]

        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()

        var samples: [Float] = []

        while let buffer = output.copyNextSampleBuffer(),
              let block = CMSampleBufferGetDataBuffer(buffer) {
            let length = CMBlockBufferGetDataLength(block)
            var data = [Float](repeating: 0, count: length / MemoryLayout<Float>.size)
            CMBlockBufferCopyDataBytes(block, atOffset: 0, dataLength: length, destination: &data)
            samples.append(contentsOf: data)
        }

        let chunkSize = max(samples.count / 50, 1)
        var downsampled: [Float] = []

        for i in stride(from: 0, to: samples.count, by: chunkSize) {
            let chunk = samples[i..<min(i + chunkSize, samples.count)]

            let rms = sqrt(chunk.map { $0 * $0 }.reduce(0, +) / Float(chunk.count))

            let boosted = tanh(rms * 10) + Float.random(in: 0.02...0.05)
            let normalized = min(1.0, max(0.02, boosted))

            downsampled.append(normalized)
        }

        DispatchQueue.main.async {
            self.waveformAmplitudes = downsampled
        }
    }
    
    private func updateWaveform() {
        audioRecorder?.updateMeters()
        let power = audioRecorder?.averagePower(forChannel: 0) ?? -160

        let clampedPower = max(power, -60)
        let linear = pow(10, clampedPower / 20)
        let boosted = tanh(linear * 8) + Float.random(in: 0.02...0.05)
        let amplitude = min(1.0, max(0.02, boosted))

        waveformAmplitudes.append(amplitude)

        if waveformAmplitudes.count > 60 {
            waveformAmplitudes.removeFirst()
        }
    }
    
    func deleteRecording() {
        stopTimer()
        audioRecorder?.stop()
        audioPlayer?.stop()
        
        recordingState = .idle
        currentTime = 0
        totalTime = 0
        playbackProgress = 0
        lastProgress = 0
        waveformAmplitudes = []
        
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }

        recordingURL = nil
        audioRecorder = nil
        audioPlayer = nil
    }
}
