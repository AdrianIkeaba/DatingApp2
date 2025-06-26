//
//  ContentView.swift
//  DatingApp
//
//  Created by GHØβT on 24/06/2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    @Environment(\.scaler) private var scaler
    @State private var selectedTab = 2
    @State private var selectedProfile: ProfileData?
    @State private var showRecordingView = false
    @Namespace private var cardTransition
    
    var unlocked: [String] {
        UserDefaults.standard.stringArray(forKey: "UnlockedUsers") ?? []
    }
    var isAmandaUnlocked: Bool {
        unlocked.contains("Amanda, 22")
    }
    var isMalteUnlocked: Bool {
        unlocked.contains("Malte, 31")
    }
    var isBinghamUnlocked: Bool {
        unlocked.contains("Bingham, 28")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                StarryBackground()
                
                VStack(spacing: 0) {
                    VStack(spacing: scaler.h(16)) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: scaler.h(4)) {
                                HStack(alignment: .center, spacing: scaler.w(10)) {
                                    ScaledText("Your Turn", size: 22, font: .bold, color: .white)
                                    
                                    ScaledText("7", size: 10, font: .bold, color: .black)
                                        .padding(scaler.w(6))
                                        .background(
                                            Circle()
                                                .fill(Color(red: 0.71, green: 0.60, blue: 0.82))
                                        )
                                }
                                
                                ScaledText("Make your move, they are waiting 🎵", size: 12, font: .italic, color: .white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            // Top right profile with score
                            VStack(spacing: scaler.h(4)) {
                                ExactCircularProgress()
                                    .shadow(color: Color(red: 181 / 255, green: 178 / 255, blue: 255 / 255).opacity(0.5), radius: scaler.w(8))
                                
                                HStack {
                                    ScaledText("90", size: 16, font: .bold, color: .white)
                                        .padding(.horizontal, scaler.w(12))
                                        .padding(.vertical, scaler.h(1))
                                }
                                .background(Color(red: 18/255, green: 22/255, blue: 31/255))
                                .cornerRadius(scaler.w(10))
                                .offset(y: -scaler.h(10))
                            }
                        }
                        .padding(.horizontal, scaler.w(20))
                        
                        // Game cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: scaler.w(15)) {
                                ProfileCard(
                                    profileData: ProfileData(
                                        name: "Amanda, 22",
                                        question: "What is your most favorite childhood memory?",
                                        answer: "Mine is definitely sneaking the late night snacks",
                                        image: "amanda",
                                        hasNotification: false,
                                        isUnlocked: isAmandaUnlocked
                                    ),
                                    cardTransition: cardTransition,
                                    onTap: { profile in
                                        selectedProfile = profile
                                        showRecordingView = true
                                    }
                                )
                                .opacity(showRecordingView && selectedProfile?.name == "Amanda, 22" ? 0 : 1)

                                ProfileCard(
                                    profileData: ProfileData(
                                        name: "Malte, 31",
                                        question: "What is the most\nimportant quality in friendships to you?",
                                        answer: "Nothing better in my opinon than honesty and trust",
                                        image: "malte",
                                        hasNotification: true,
                                        isUnlocked: isMalteUnlocked
                                    ),
                                    cardTransition: cardTransition,
                                    onTap: { profile in
                                        selectedProfile = profile
                                        showRecordingView = true
                                    }
                                )
                                .opacity(showRecordingView && selectedProfile?.name == "Malte, 31" ? 0 : 1)

                                ProfileCard(
                                    profileData: ProfileData(
                                        name: "Bingham, 28",
                                        question: "If you could choose to\nhave one superpower,\nwhat would it be?",
                                        answer: "Definitely would be time manipulation for me",
                                        image: "bingham",
                                        hasNotification: false,
                                        isUnlocked: isBinghamUnlocked
                                    ),
                                    cardTransition: cardTransition,
                                    onTap: { profile in
                                        selectedProfile = profile
                                        showRecordingView = true
                                    }
                                )
                                .opacity(showRecordingView && selectedProfile?.name == "Bingham, 28" ? 0 : 1)

                                ProfileCard(
                                    profileData: ProfileData(
                                        name: "",
                                        question: "",
                                        answer: "",
                                        image: "",
                                        hasNotification: false,
                                        isUnlocked: false,
                                        isStackedCard: true
                                    ),
                                    cardTransition: cardTransition,
                                    onTap: { _ in }
                                )
                                .frame(width: scaler.w(90))
                            }
                            .padding(.horizontal, scaler.w(20))
                        }
                    }
                    .padding(.bottom, scaler.h(30))
                    
                    // Chat section
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .bottom) {
                            ScaledText("Chats", size: 22, font: .bold, color: .white)
                            
                            ScaledText("Pending", size: 22, font: .bold, color: Color(red: 95/255, green: 95/255, blue: 96/255))
                                .padding(.leading, scaler.w(8))
                            
                            Spacer()
                        }
                        .padding(.horizontal, scaler.w(20))
                        .padding(.bottom, scaler.h(4))
                        
                        HStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: scaler.w(60), height: scaler.h(1))
                            
                            Spacer()
                        }
                        .padding(.horizontal, scaler.w(20))
                        .padding(.bottom, scaler.h(14))
                        
                        ScaledText("The ice is broken. Time to hit it off", size: 12, font: .italic, color: Color(red: 168/255, green: 175/255, blue: 183/255))
                            .padding(.horizontal, scaler.w(20))
                            .padding(.bottom, scaler.h(10))
                    }
                    
                    Spacer()
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
                
                // Overlay recording view with matched geometry
                if showRecordingView, let profile = selectedProfile {
                    RecordingView(
                        profileData: profile,
                        cardTransition: cardTransition,
                        onDismiss: {
                            showRecordingView = false
                            // Delay clearing selectedProfile to allow animation to complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedProfile = nil
                            }
                        }
                    )
                    .zIndex(999)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// Profile data model
struct ProfileData: Identifiable {
    let id = UUID()
    let name: String
    let question: String
    let answer: String
    let image: String
    let hasNotification: Bool
    let isUnlocked: Bool
    let isStackedCard: Bool
    
    init(name: String, question: String, answer: String, image: String, hasNotification: Bool, isUnlocked: Bool, isStackedCard: Bool = false) {
        self.name = name
        self.question = question
        self.answer = answer
        self.image = image
        self.hasNotification = hasNotification
        self.isUnlocked = isUnlocked
        self.isStackedCard = isStackedCard
    }
}

struct StarryBackground: View {
    @State private var stars: [Star] = []
    @State private var timer: AnyCancellable?
    
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 6 / 255, green: 6 / 255, blue: 8 / 255), location: 0.0),
                    Gradient.Stop(color: Color(red: 11 / 255, green: 13 / 255, blue: 14 / 255), location: 0.65),
                    Gradient.Stop(color: Color(red: 12 / 255, green: 15 / 255, blue: 15 / 255), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            // Stars pattern
            Canvas { context, size in
                for star in stars {
                    let path = Path(ellipseIn: CGRect(x: star.x, y: star.y, width: star.size, height: star.size))
                    context.fill(
                        path,
                        with: .color(.white.opacity(star.opacity))
                    )
                }
            }
            .ignoresSafeArea(.all)
        }
        .onAppear {
            setupStarsAndTimer()
        }
        .onDisappear {
            cleanupTimer()
        }
    }
    
    private func setupStarsAndTimer() {
        let screenBounds = UIScreen.main.bounds
        stars = generateStars(for: screenBounds.size)
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                for i in 0..<stars.count {
                    stars[i].opacity = Double.random(in: 0.2...0.8)
                }
            }
    }
    
    private func generateStars(for size: CGSize) -> [Star] {
        var newStars: [Star] = []
        let totalHeight = Double(size.height)
        let fadeStartPoint = totalHeight * 0.35
        let fadeEndPoint = totalHeight * 0.45
        
        let topStars = 100
        for _ in 0..<topStars {
            let x = Double.random(in: 0...Double(size.width))
            let y = Double.random(in: 0...fadeStartPoint)
            let starSize = Double.random(in: 0.5...2.0)
            let opacity = Double.random(in: 0.3...0.9)
            
            newStars.append(Star(x: x, y: y, size: starSize, opacity: opacity))
        }
        
        let fadeZoneStars = 20
        for _ in 0..<fadeZoneStars {
            let x = Double.random(in: 0...Double(size.width))
            let y = Double.random(in: fadeStartPoint...fadeEndPoint)
            let starSize = Double.random(in: 0.5...1.5)
            
            // Calculates fade based on position in fade zone
            let fadeProgress = (y - fadeStartPoint) / (fadeEndPoint - fadeStartPoint)
            let baseOpacity = 0.3 + (0.6 * (1.0 - fadeProgress))
            let opacity = Double.random(in: max(0.1, baseOpacity - 0.2)...baseOpacity)
            
            newStars.append(Star(x: x, y: y, size: starSize, opacity: opacity))
        }
        
        return newStars
    }
    
    private func cleanupTimer() {
        timer?.cancel()
    }
}

struct Star: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var size: Double
    var opacity: Double
}

struct ExactCircularProgress: View {
    let progress: Double = 0.8
    
    private let radius: CGFloat = 20
    private let strokeWidth: CGFloat = 3
    
    private let startAngle: Double = 90
    private let totalSweep: Double = -90
    
    var body: some View {
        ZStack {
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 54/255, green: 54/255, blue: 54/255)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: radius * 2.1, height: radius * 2.1)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 0.30, green: 0.55, blue: 0.15),
                            Color(red: 0.21, green: 0.39, blue: 0.10)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: radius * 2.1, height: radius * 2.1)
                .rotationEffect(.degrees(startAngle))
            
            // Handle
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color.clear, location: 0.0),
                            Gradient.Stop(color: Color(red: 181/255, green: 178/255, blue: 255/255), location: 0.20),
                            Gradient.Stop(color: Color(red: 181/255, green: 178/255, blue: 255/255), location: 0.80),
                            Gradient.Stop(color: Color.clear, location: 1.0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 15, height: 3)
                .position(handlePosition)
                .rotationEffect(.degrees(0))
            
            Image("photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35.63, height: 35.63)
                .clipShape(Circle())
        }
        .frame(width: radius * 2, height: radius * 2)
    }
    
    private var handlePosition: CGPoint {
        let angle = (startAngle + progress * totalSweep).truncatingRemainder(dividingBy: 360)
        let radians = angle * .pi / 180

        let x = radius + CGFloat(cos(radians)) * radius
        let y = radius + CGFloat(sin(radians)) * radius
        return CGPoint(x: x, y: y)
    }
    
}

#Preview {
    ContentView()
}
