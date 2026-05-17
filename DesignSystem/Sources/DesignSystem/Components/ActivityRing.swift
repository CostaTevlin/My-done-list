// ActivityRing.swift
// Apple Activity Ring-style circular progress indicator.
// Three states: empty (0), building (0<p<1), reward (p≥1).
// Phase: 5 · See: design-system/Components.md (ActivityRing) · Phase 5 hero contract §5

import SwiftUI

public struct ActivityRing: View {
    public let progress: Double
    public let diameter: CGFloat
    public var strokeWidth: CGFloat = 14

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var breatheScale: CGFloat = 1.0

    public init(progress: Double, diameter: CGFloat, strokeWidth: CGFloat = 14) {
        self.progress = progress
        self.diameter = diameter
        self.strokeWidth = strokeWidth
    }

    private var isReward: Bool { progress >= 1 }
    private var isEmpty: Bool { progress == 0 }

    public var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(isReward ? Color.borderDefault.opacity(0.5) : Color.borderDefault,
                        lineWidth: strokeWidth)

            // Fill arc
            if !isEmpty {
                Circle()
                    .trim(from: 0, to: CGFloat(min(progress, 1)))
                    .stroke(
                        isReward
                            ? AnyShapeStyle(Color.ringComplete)
                            : AnyShapeStyle(LinearGradient(
                                colors: [.ringMid, .ringComplete],
                                startPoint: .top,
                                endPoint: .bottom
                              )),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.smooth(duration: 0.6), value: progress)
            }

            // Reward halo
            if isReward {
                Circle()
                    .stroke(Color.ringLow, lineWidth: strokeWidth + 4)
                    .blur(radius: 12)
                    .opacity(0.6)
                    .scaleEffect(breatheScale)
            }
        }
        .frame(width: diameter, height: diameter)
        .scaleEffect(isReward && !reduceMotion ? breatheScale : 1.0)
        .accessibilityHidden(true)
        .onAppear { startBreathing() }
        .onChange(of: isReward) { _, newValue in
            if newValue { startBreathing() } else { breatheScale = 1.0 }
        }
    }

    private func startBreathing() {
        guard isReward && !reduceMotion else { return }
        withAnimation(
            .easeInOut(duration: 3.6).repeatForever(autoreverses: true)
        ) {
            breatheScale = 1.02
        }
    }
}
