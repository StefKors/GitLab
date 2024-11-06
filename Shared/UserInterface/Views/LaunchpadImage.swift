//
//  LaunchpadImage.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import Foundation
import SwiftUI

struct LaunchpadImage: View {
    let repo: LaunchpadRepo

    private var url: URL? {
        if let image = repo.image {
            return URL(string: "data:image/png;base64," + image.base64EncodedString())
        } else if let imageURL = repo.imageURL {
            return imageURL
        } else {
            return nil
        }
    }

    private let providerCircleSize: CGFloat = 14

    var placeholder: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.generateHSLColor(for: repo.name))
            .overlay(content: {
                if let char = repo.name.first {
                    Text(String(char).capitalized)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)
                        .colorInvert()
                }
            })
            .padding(2)
    }

    var body: some View {
        HStack {
            if let url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .transition(.opacity.combined(with: .scale).combined(with: .blurReplace))
                        .mask {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .padding(2)
                        }
                } placeholder: {
                    placeholder
                }
            } else {
                placeholder
            }
        }
        .frame(width: 32.0, height: 32.0)
        .if(
            repo.provider != nil,
            transform: { content in
                content
                    .mask({
                        Rectangle()
                            .fill(.white)
                            .overlay(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(.black)
                                    .frame(width: providerCircleSize, height: providerCircleSize, alignment: .center)
                            }
                            .compositingGroup()
                            .luminanceToAlpha()
                    })
                    .overlay(alignment: .bottomTrailing) {
                        if let provider = repo.provider {
                        Circle()
                            .fill(.clear)
                            .frame(width: providerCircleSize, height: providerCircleSize, alignment: .center)
                            .overlay {
                                GitProviderView(provider: provider)
                            }
                    }
                }
        })
        .shadow(radius: 3)

    }
}

extension Color {
    static func generateColor(for text: String) -> Color {
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars{
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256*256*256);
        //let color = UIColor(hue:CGFloat(finalHash)/255.0 , saturation: 0.40, brightness: 0.75, alpha: 1.0)
        return Color(
            red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0,
            blue: CGFloat((finalHash & 0xFF)) / 255.0
        )
    }

    static func generateHSLColor(for text: String) -> Color {
        var hash = 0;
        let colorConstant = 50
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars {
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }

        let hue = hash % 360;

        let finalHue = CGFloat(hue.clamped(to: 0...360))/360
        return Color(
            hue: finalHue,
            saturation: 72/100,
            lightness: 50/100,
            opacity: 1.0
        )
    }

    init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, opacity: CGFloat) {
        precondition(0...1 ~= hue &&
                     0...1 ~= saturation &&
                     0...1 ~= lightness &&
                     0...1 ~= opacity, "input range is out of range 0...1")

        //From HSL TO HSB ---------
        var newSaturation: Double = 0.0

        let brightness = lightness + saturation * min(lightness, 1-lightness)

        if brightness == 0 { newSaturation = 0.0 }
        else {
            newSaturation = 2 * (1 - lightness / brightness)
        }
        //---------

        self.init(hue: hue, saturation: newSaturation, brightness: brightness, opacity: opacity)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    LazyVGrid(columns: [
        GridItem(.adaptive(minimum: 42), alignment: .leading)
    ], alignment: .leading, spacing: 10) {
        ForEach(0...26, id: \.self) { letter in
            LaunchpadImage(repo: LaunchpadRepo(
                id: "uuid",
                name: UUID().uuidString,
                image: .previewRepoImage,
                group: "StefKors",
                url: URL(string: "https://gitlab.com/stefkors/swiftui-launchpad")!,
                provider: .GitHub,
                hasUpdatedSinceLaunch: false
            ))
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scenePadding()
}
