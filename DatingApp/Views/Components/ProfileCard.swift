//
//  ProfileCard.swift
//  DatingApp
//
//  Created by GHØβT on 20/06/2025.

import SwiftUI

struct ProfileCard: View {
    @Environment(\.scaler) private var scaler

    let profileData: ProfileData
    let cardTransition: Namespace.ID
    let onTap: (ProfileData) -> Void

    var body: some View {
        ZStack {
            if profileData.isStackedCard {
                Rectangle()
                    .fill(Color(red: 34/255, green: 34/255, blue: 34/255))
                    .cornerRadius(scaler.w(20))

                StackedProfileImages()
            } else {
                ProfileCardBackground(image: profileData.image, blur: profileData.name != "Bingham, 28")
                    .matchedGeometryEffect(id: "background-\(profileData.name)", in: cardTransition)

                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color.clear, location: 0.0),
                        Gradient.Stop(color: Color(red: 11 / 255, green: 13 / 255, blue: 14 / 255), location: 0.8),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(scaler.w(20))
                .matchedGeometryEffect(id: "gradient-\(profileData.name)", in: cardTransition)

                VStack {
                    HStack {
                        if profileData.name == "Bingham, 28" {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: scaler.w(24), height: scaler.w(24))

                                ScaledText("📣", size: 9, font: .regular)
                            }
                        } else if profileData.hasNotification {
                            HStack(spacing: scaler.w(6)) {
                                ScaledText("📣 They made a move!", size: 9, font: .semibold, color: .white)
                                    .padding(.horizontal, scaler.w(10))
                            }
                            .frame(height: scaler.h(19))
                            .background(Color.black)
                            .cornerRadius(scaler.w(16))
                            .shadow(color: Color(red: 128/255, green: 128/255, blue: 128/255).opacity(0.6), radius: scaler.w(15))
                        } else {
                            Spacer()
                                .frame(width: scaler.w(32), height: scaler.w(32))
                        }

                        if profileData.name == "Bingham, 28" {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color(red: 73/255, green: 71/255, blue: 70/255))
                                    .shadow(color: Color.black, radius: scaler.w(15))
                                    .frame(width: scaler.w(20), height: scaler.w(20))

                                Circle()
                                    .trim(from: 0, to: 0.75)
                                    .stroke(Color.white, lineWidth: scaler.w(2))
                                    .frame(width: scaler.w(20), height: scaler.w(20))
                                    .rotationEffect(.degrees(-90))

                                ScaledText("16h", size: 6.2, font: .bold, color: .white)
                            }
                        }
                    }
                    .padding(.horizontal, scaler.w(14))
                    .padding(.top, scaler.h(14))

                    Spacer()
                }
                
                VStack {
                    if profileData.isUnlocked {
                        Spacer()
                        Spacer()
                        Image("check")
                            .shadow(color: Color(red: 144 / 255, green: 140 / 255, blue: 227 / 255), radius: 3)
                            .matchedGeometryEffect(id: "check-\(profileData.name)", in: cardTransition)
                        
                        Spacer()
                        Spacer()
                    }
                    
                }

                VStack {
                    Spacer()

                    VStack(spacing: 0) {
                        ScaledText(profileData.name, size: 15, font: .bold, color: .white)
                            .padding(.bottom, scaler.h(8))
                            .matchedGeometryEffect(id: "name-\(profileData.name)", in: cardTransition)

                        ScaledText(profileData.question, size: 10, font: .regular, color: Color(red: 207 / 255, green: 207 / 255, blue: 254 / 255).opacity(0.7), alignment: .center)
                            .lineLimit(3)
                            .lineSpacing(2)
                            .matchedGeometryEffect(id: "question-\(profileData.name)", in: cardTransition)
                    }
                    .padding(.horizontal, scaler.w(12))
                    .padding(.bottom, scaler.h(10))
                }
            }
        }
        .frame(width: !profileData.isStackedCard ? scaler.w(145) : scaler.w(90), height: scaler.h(205))
        .cornerRadius(scaler.w(20))
        .clipped()
        .shadow(color: Color.black.opacity(0.25), radius: scaler.w(5))
        .matchedGeometryEffect(id: "card-\(profileData.name)", in: cardTransition)
        .onTapGesture {
            if !profileData.isStackedCard {
                onTap(profileData)
            }
        }
    }
}

struct StackedProfileImages: View {
    var body: some View {
        VStack {
            Spacer()
            Image("stack")
                .scaledToFill()
            Spacer()
        }
    }
}

struct ProfileCardBackground: View {
    let image: String
    let blur: Bool

    var body: some View {
        GeometryReader { geo in
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .cornerRadius(24)
        }
    }
}
