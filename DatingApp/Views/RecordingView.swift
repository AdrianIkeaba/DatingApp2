//
//  RecordingView.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//

import SwiftUI

struct RecordingView: View {
    @Environment(\.scaler) private var scaler
    @StateObject private var viewModel = RecordingViewModel()

    let profileData: ProfileData
    let cardTransition: Namespace.ID
    let onDismiss: () -> Void

    @State private var unlockedUsers: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "UnlockedUsers") ?? [])
    @State private var animationPhase: AnimationPhase = .initial
    @State private var contentOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var overlayOpacity: Double = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var cardPosition: CGPoint = .zero
    @State private var isExpanded: Bool = false

    enum AnimationPhase {
        case initial
        case expanding
        case expanded
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                
                if !isExpanded {
                    cardView(geometry: geometry)
                        .matchedGeometryEffect(id: "card-\(profileData.name)", in: cardTransition)
                        .scaleEffect(cardScale)
                        .position(cardPosition == .zero ? CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2) : cardPosition)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardPosition)
                        
                } else {
                    // Expanded full-screen state
                    expandedView(geometry: geometry)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startExpandAnimation()
        }
    }
    
    private func cardView(geometry: GeometryProxy) -> some View {
        ZStack {
            Image(profileData.image)
                .resizable()
                .scaledToFill()
                .frame(
                    width: animationPhase == .initial ? scaler.w(145) : geometry.size.width,
                    height: animationPhase == .initial ? scaler.h(205) : geometry.size.height
                )
                .clipped()
                .cornerRadius(animationPhase == .initial ? 20 : 0)
            
            if animationPhase == .initial {
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color.clear, location: 0.0),
                        Gradient.Stop(color: Color(red: 11 / 255, green: 13 / 255, blue: 14 / 255), location: 0.8),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(scaler.w(20))
                
                // Card content
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        ScaledText(profileData.name, size: 15, font: .bold, color: .white)
                            .padding(.bottom, scaler.h(8))

                        ScaledText(profileData.question, size: 10, font: .regular, color: Color(red: 207 / 255, green: 207 / 255, blue: 254 / 255).opacity(0.7), alignment: .center)
                            .lineLimit(3)
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, scaler.w(12))
                }
            } else {
                Image("fade")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .opacity(overlayOpacity)
            }
        }
        .frame(
            width: animationPhase == .initial ? scaler.w(145) : geometry.size.width,
            height: animationPhase == .initial ? scaler.h(205) : geometry.size.height
        )
        .cornerRadius(animationPhase == .initial ? scaler.w(20) : 0)
    }
    
    private func expandedView(geometry: GeometryProxy) -> some View {
        ZStack {
            VStack(spacing: 0) {
                Image(profileData.image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * 0.65,
                        alignment: .top
                    )
                    .scaleEffect(1.12)
                    .offset(x: scaler.w(20))
                    .clipped()
                
                Spacer(minLength: 0)
            }
            
            Image("fade")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
            
            VStack(alignment: .center) {
                // Header
                headerView
                    .opacity(contentOpacity)
                    .offset(y: contentOpacity == 0 ? -30 : 0)

                Spacer()
                
                // Profile bubble + question
                questionView
                    .opacity(contentOpacity)
                    .offset(y: contentOpacity == 0 ? 50 : 0)

                Spacer().frame(height: scaler.h(30))

                // Timer + Waveform
                waveformView
                    .opacity(contentOpacity)
                    .offset(y: contentOpacity == 0 ? 50 : 0)

                Spacer().frame(height: scaler.h(30))

                // Buttons
                buttonsView
                    .opacity(contentOpacity)
                    .offset(y: contentOpacity == 0 ? 50 : 0)

                Spacer().frame(height: scaler.h(34))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Self.safeAreaTopInset)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: scaler.h(5)) {
            HStack(spacing: scaler.w(20)) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color(red: 176/255, green: 176/255, blue: 176/255))
                    .frame(height: scaler.h(4))

                RoundedRectangle(cornerRadius: 100)
                    .fill(Color(red: 80/255, green: 80/255, blue: 80/255))
                    .frame(height: scaler.h(4))
            }
            .padding(.horizontal, scaler.w(35))
            .padding(.top, scaler.h(9))

            HStack {
                Image("back")
                    .resizable()
                    .frame(width: scaler.w(44), height: scaler.h(44))
                    .onTapGesture {
                        startCollapseAnimation()
                    }

                Spacer()

                ScaledText(profileData.name, size: 18, font: .bold, color: .white)

                Spacer()

                Image("menu")
                    .resizable()
                    .frame(width: scaler.w(22), height: scaler.h(4.4))
                    .padding(.leading, scaler.w(-13))
            }
            .frame(height: scaler.h(44))
            .padding(.horizontal, scaler.w(35))
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 0) {
            VStack(spacing: scaler.h(4)) {
                ZStack {
                    Circle().fill(Color.black).frame(width: scaler.w(60), height: scaler.h(60))
                    Image(profileData.image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: scaler.w(50), height: scaler.h(50))
                        .clipped()
                }

                ScaledText("Stroll question", size: 11, font: .semibold, color: .white)
                    .frame(width: scaler.w(95), height: scaler.h(20))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 18/255, green: 21/255, blue: 24/255).opacity(0.9))
                    )
                    .offset(y: scaler.h(-10))
            }

            VStack(spacing: scaler.h(7)) {
                ScaledText(profileData.question, size: 24, font: .bold, color: .white, alignment: .center)
                    .multilineTextAlignment(.center)

                ScaledText("\"\(profileData.answer)\"", size: 13, font: .italic, color: Color(red: 203 / 255, green: 201 / 255, blue: 255 / 255).opacity(0.7), alignment: .center)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, scaler.w(35))
        }
    }
    
    private var waveformView: some View {
        VStack(spacing: scaler.h(20)) {
            Group {
                if viewModel.recordingState == .stopped || viewModel.recordingState == .paused || viewModel.recordingState == .playing {
                    HStack(spacing: scaler.w(5)) {
                        ScaledText(formatTime(viewModel.currentTime), size: 14, font: .regular, color: Color(red: 181/255, green: 178/255, blue: 255/255), alignment: .center)

                        ScaledText("/", size: 14, font: .regular, color: Color(red: 174/255, green: 173/255, blue: 175/255), alignment: .center)

                        ScaledText(formatTime(viewModel.totalTime), size: 14, font: .regular, color: Color(red: 174/255, green: 173/255, blue: 175/255), alignment: .center)
                    }
                } else {
                    ScaledText(formatTime(viewModel.currentTime), size: 14, font: .regular, color: Color(red: 174/255, green: 173/255, blue: 175/255), alignment: .center)
                }
            }

            WaveformView(
                amplitudes: viewModel.waveformAmplitudes,
                isRecording: viewModel.recordingState == .recording,
                isPlaying: viewModel.recordingState == .playing,
                progress: viewModel.recordingState == .playing ? viewModel.playbackProgress : viewModel.lastProgress,
                totalTime: viewModel.totalTime
            )
            .frame(width: scaler.w(305), height: scaler.h(45))
        }
    }
    
    private var buttonsView: some View {
        VStack(spacing: scaler.h(10)) {
            HStack(spacing: scaler.w(30)) {
                ScaledText("Delete", size: 17, font: .regular, color: viewModel.recordingState != .idle ? .white : Color.gray, alignment: .center)
                    .onTapGesture {
                        if viewModel.recordingState != .idle {
                            viewModel.deleteRecording()
                        }
                    }
                    .frame(width: scaler.w(70), height: scaler.h(40))

                RecordButton(viewModel: viewModel)

                ScaledText("Submit", size: 17, font: .regular, color: (viewModel.recordingState == .stopped || viewModel.recordingState == .paused) ? .white : .gray, alignment: .center)
                    .onTapGesture {
                        guard (viewModel.recordingState == .stopped || viewModel.recordingState == .paused) else { return }
                        unlockedUsers.insert(profileData.name)
                        UserDefaults.standard.set(Array(unlockedUsers), forKey: "UnlockedUsers")
                        startCollapseAnimation()
                    }
                    .frame(width: scaler.w(70), height: scaler.h(40))
            }

            ScaledText("Unmatch", size: 13, font: .regular, color: Color(red: 190/255, green: 32/255, blue: 32/255), alignment: .center)
                .frame(width: scaler.w(70), height: scaler.h(40))
        }
    }
    
    private func startExpandAnimation() {
        // Start background fade
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 0.8
        }
        
        // Begin smooth expansion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                animationPhase = .expanding
                overlayOpacity = 1.0
            }
        }
        
        // Switch to expanded state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.2)) {
                isExpanded = true
                backgroundOpacity = 1.0
            }
        }
        
        // Fade in content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.4)) {
                contentOpacity = 1.0
            }
        }
    }
    
    private func startCollapseAnimation() {
        // Start fading out content
        withAnimation(.easeIn(duration: 0.3)) {
            contentOpacity = 0
        }
        
        // Begin gradual background fade
        withAnimation(.easeIn(duration: 0.4)) {
            backgroundOpacity = 0.4
        }
        
        // Start shrinking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isExpanded = false
                overlayOpacity = 0
            }
        }
        
        // Start moving back to position while shrinking is almost done
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                animationPhase = .initial
            }
        }
        
        // Final background fade
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeIn(duration: 0.1)) {
                backgroundOpacity = 0
            }
        }
        
        // Dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            onDismiss()
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private static var safeAreaTopInset: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return 44
        }
        return window.safeAreaInsets.top
    }
}
