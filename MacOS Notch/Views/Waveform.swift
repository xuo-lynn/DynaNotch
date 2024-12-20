import SwiftUI

struct WaveformView: View {
    @State private var animationValues: [CGFloat] = Array(repeating: 0.5, count: 5)
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<animationValues.count, id: \.self) { index in
                Capsule()
                    .fill(Color.white)
                    .frame(width: 3, height: animationValues[index] * 20)
            }
        }
        .onAppear {
            animateWaveform()
        }
    }
    
    private func animateWaveform() {
        withAnimation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true)) {
            for index in animationValues.indices {
                animationValues[index] = CGFloat.random(in: 0.2...1.0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateWaveform()
        }
    }
}
