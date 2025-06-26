//
//  WaveformView.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//
import SwiftUI

struct WaveformView: View {
    @Environment(\.scaler) private var scaler
    let amplitudes: [Float]
    let isRecording: Bool
    let isPlaying: Bool
    let progress: Double
    let totalTime: TimeInterval
    private let barSpacing: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let spacing = scaler.w(barSpacing)
            let approxBarWidth: CGFloat = 3
            let barCount = max(10, Int((availableWidth + spacing) / (approxBarWidth + spacing))) - 15
            let totalSpacing = CGFloat(barCount - 1) * spacing
            let barWidth = (availableWidth - totalSpacing) / CGFloat(barCount)
            let activeBars = getActiveBarCount(barCount: barCount)

            ZStack(alignment: .leading) {
                // Continuous line when idle
                if !isRecording && amplitudes.isEmpty && !isPlaying && progress <= 0.01 {
                    Rectangle()
                        .fill(Color(red: 54 / 255, green: 57 / 255, blue: 62 / 255).opacity(0.95))
                        .frame(width: availableWidth, height: scaler.h(2))
                        .frame(height: scaler.h(45))
                }
                
                // Continuous line during recording (shrinking from right)
                if isRecording {
                    let remainingLineWidth = availableWidth * CGFloat(max(0, barCount - activeBars)) / CGFloat(barCount)
                    Rectangle()
                        .fill(Color(red: 54 / 255, green: 57 / 255, blue: 62 / 255).opacity(0.95))
                        .frame(width: remainingLineWidth, height: scaler.h(2))
                        .frame(height: scaler.h(45))
                        .animation(.linear(duration: 0.1), value: remainingLineWidth)
                }
                
                // Waveform bars
                HStack(alignment: .center, spacing: spacing) {
                    let count = barCount
                    ForEach(0..<count, id: \.self) { index in
                        let amplitude = getAmplitude(for: index, barCount: barCount)
                        let state = getBarState(for: index, activeBars: activeBars, barCount: barCount)
                        let fillProgress = getBarFillProgress(for: index, barCount: barCount)
                        let showBar = shouldShowBar(for: index, activeBars: activeBars, barCount: barCount)

                        if showBar {
                            WaveformBar(
                                amplitude: amplitude,
                                maxHeight: scaler.h(15),
                                barWidth: barWidth,
                                state: state,
                                fillProgress: fillProgress,
                                isPlaying: isPlaying
                            )
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: barWidth, height: barHeight(amplitude))
                        }
                    }
                }
            }
        }
        .frame(height: scaler.h(45))
    }

    private func getActiveBarCount(barCount: Int) -> Int {
        if isRecording {
            return min(amplitudes.count, barCount)
        }
        return Int(progress * Double(barCount))
    }

    private func getAmplitude(for index: Int, barCount: Int) -> Float {
        if isRecording {
            let padding = max(0, barCount - amplitudes.count)
            let padded = Array(repeating: 0.0, count: padding) + amplitudes.suffix(barCount)
            return padded[index]
        } else if !amplitudes.isEmpty {
            let mapped = Int(Double(index) / Double(barCount) * Double(amplitudes.count))
            return amplitudes[mapped]
        }
        return 0.0
    }

    private func getBarState(for index: Int, activeBars: Int, barCount: Int) -> WaveformBar.State {
        if isRecording {
            return index >= (barCount - activeBars) ? .recording : .future
        } else if isPlaying || progress > 0.01 {
            let progressPosition = progress * Double(barCount)
            let indexDouble = Double(index)
            
            if indexDouble < progressPosition - 1 {
                return .played
            } else if indexDouble <= progressPosition {
                return .playing
            } else {
                return .idle
            }
        }
        return .idle
    }
    
    private func getBarFillProgress(for index: Int, barCount: Int) -> Double {
        guard isPlaying || progress > 0.01 else { return 0 }
        
        let progressPosition = progress * Double(barCount)
        let indexDouble = Double(index)
        
        if indexDouble < progressPosition - 1 {
            return 1.0
        } else if indexDouble <= progressPosition {
            return progressPosition - indexDouble
        } else {
            return 0.0
        }
    }
    
    private func shouldShowBar(for index: Int, activeBars: Int, barCount: Int) -> Bool {
        if isRecording {
            // During recording, only show bars that have been "activated"
            return index >= (barCount - activeBars)
        }
        return !amplitudes.isEmpty || isPlaying || progress > 0.01
    }
    
    private func barHeight(_ amplitude: Float) -> CGFloat {
        let scaled = max(0.02, CGFloat(amplitude))
        return scaler.h(scaled * 15)
    }
}

struct WaveformBar: View {
    @Environment(\.scaler) private var scaler

    enum State {
        case idle, recording, playing, played, future
    }

    let amplitude: Float
    let maxHeight: CGFloat
    let barWidth: CGFloat
    let state: State
    let fillProgress: Double
    let isPlaying: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            // Background bar
            Rectangle()
                .fill(backgroundColor)
                .frame(width: safeBarWidth, height: barHeight)
            
            Rectangle()
                .fill(playingColor)
                .frame(width: safeBarWidth * fillProgress, height: barHeight)
                .opacity(shouldShowFill ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.1), value: fillProgress)
        }
        .frame(height: scaler.h(45))
    }

    private var barHeight: CGFloat {
        let scaled = max(0.02, CGFloat(amplitude))
        return scaler.h(scaled * 15)
    }

    private var backgroundColor: Color {
        switch state {
        case .recording, .idle, .future, .playing, .played:
            return Color(red: 54 / 255, green: 57 / 255, blue: 62 / 255).opacity(0.95)
        }
    }
    
    private var playingColor: Color {
        Color(red: 181 / 255, green: 178 / 255, blue: 255 / 255)
    }
    
    private var shouldShowFill: Bool {
        return (isPlaying || fillProgress > 0) && (state == .playing || state == .played)
    }

    private var safeBarWidth: CGFloat {
        barWidth.isFinite && barWidth > 0 ? barWidth : 1
    }
}
