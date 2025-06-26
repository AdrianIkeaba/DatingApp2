//
//  RecordButton.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//
import SwiftUI

struct RecordButton: View {
    @Environment(\.scaler) private var scaler
    @ObservedObject var viewModel: RecordingViewModel
    @State private var ringProgress: CGFloat = 0
    @State private var isUnlocking = false
    @State private var isButtonEnabled = false
    @State private var progress: Double = 0
    @State private var progressTimer: Timer?

    var body: some View {
        Button(action: {
            if viewModel.recordingState == .recording && isButtonEnabled {
                viewModel.stopRecording()
            } else {
                handleButtonTap()
            }
        }) {
            ZStack {
                Circle()
                    .stroke(Color(red: 180/255, green: 180/255, blue: 180/255), lineWidth: 1)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(red: 33/255, green: 32/255, blue: 75/255),
                                Color(red: 79/255, green: 76/255, blue: 177/255),
                                Color(red: 207/255, green: 207/255, blue: 254/255)
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: scaler.w(2), lineCap: .round)
                    )
                    .shadow(color: .white.opacity(0.5), radius: 2)
                    .frame(width: scaler.w(50), height: scaler.w(50))
                    .rotationEffect(.degrees(-90))

                buttonIcon
            }
        }
        .disabled(viewModel.recordingState == .recording && !isButtonEnabled)
        .onChange(of: viewModel.recordingState) { newState in
            if newState == .recording {
                ringProgress = 0
                isButtonEnabled = false
                isUnlocking = true
                withAnimation(.linear(duration: 15)) {
                    ringProgress = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    isButtonEnabled = true
                    isUnlocking = false
                }
            } else {
                ringProgress = 0
                isButtonEnabled = false
                isUnlocking = false
            }
        }
    }
    
    private var borderColor: Color {
        switch viewModel.recordingState {
        case .recording:
            return Color.white.opacity(0.3)
        case .stopped:
            return Color.purple.opacity(0.8)
        default:
            return Color.purple.opacity(0.8)
        }
    }
    
    private var buttonColor: Color {
        switch viewModel.recordingState {
        case .recording:
            return Color.white.opacity(0.2)
        case .stopped:
            return Color.purple
        case .playing:
            return Color.purple
        default:
            return Color.purple
        }
    }
    
    private var idleIcon: some View {
        Circle()
            .fill(Color(red: 79 / 255, green: 76 / 255, blue: 177 / 255))
            .frame(width: scaler.w(41.67), height: scaler.w(41.67))
    }
    
    private var recordingIcon: some View {
        RoundedRectangle(cornerRadius: scaler.w(2))
            .fill(isButtonEnabled ? Color(red: 79 / 255, green: 76 / 255, blue: 177 / 255) : Color.gray)
            .frame(width: scaler.w(18), height: scaler.w(18))
    }
    
    private var stoppedOrPausedIcon: some View {
        Image(systemName: "play.fill")
            .font(.system(size: scaler.f(20)))
            .foregroundColor(Color(red: 79 / 255, green: 76 / 255, blue: 177 / 255))
    }
    
    private var playingIcon: some View {
        Image(systemName: "pause.fill")
            .font(.system(size: scaler.f(20)))
            .foregroundColor(Color(red: 79 / 255, green: 76 / 255, blue: 177 / 255))
    }
    
    private var readyIcon: some View {
        RoundedRectangle(cornerRadius: scaler.w(2))
            .fill(Color(red: 79 / 255, green: 76 / 255, blue: 177 / 255))
            .frame(width: scaler.w(18), height: scaler.w(18))
    }
    
    @ViewBuilder
    private var buttonIcon: some View {
        switch viewModel.recordingState {
        case .idle:
            idleIcon
        case .recording:
            recordingIcon
        case .stopped, .paused:
            stoppedOrPausedIcon
        case .playing:
            playingIcon
        case .ready:
            readyIcon
        }
    }
    
    private func handleButtonTap() {
        switch viewModel.recordingState {
        case .idle:
            viewModel.startRecording()
        case .stopped, .paused:
            viewModel.playRecording()
        case .playing:
            viewModel.pauseRecording()
        default:
            break
        }
    }
    
    
    private func startProgressTimer() {
        progress = 0
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let increment = 0.05 / 15.0
            if progress < 1.0 {
                withAnimation(.linear(duration: 0.05)) {
                    progress += increment
                }
            } else {
                progress = 1.0
                viewModel.stopRecording()
                stopProgressTimer()
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

