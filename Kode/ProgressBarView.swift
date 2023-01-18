//
//  ProgressBarView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI

// https://stackoverflow.com/questions/67132202/animating-processbar-in-progressview-swiftui
struct ProgressBarView: View {
    @State private var value: CGFloat = 0.5
    @State private var valueAnimation: CGFloat = CGFloat()
    @State private var qualityOfAnimation: Quality = .excellent
    @State private var duration: Double = 5.0

    var body: some View {
        
        VStack(spacing: 30.0) {
            
            Text(String(describing: qualityOfAnimation) + " Quality").bold()

            ProgressView(value: valueAnimation)
                .customAnimation(value: value, valueAnimation: $valueAnimation, duration: duration, qualityOfAnimation: qualityOfAnimation)

            Button("update to 1.0") { value = 1.0 }
            
            Button("update to 0.0") { value = 0.0 }
            
            Button("update to slow Quality") { qualityOfAnimation = .slow }
            
            Button("update to excellent Quality") { qualityOfAnimation = .excellent }
            
            HStack { Text("Duration:").bold().fixedSize(); Slider(value: $duration,in: 0.0...10.0); Text(duration.rounded + " sec").bold().frame(width: 80).fixedSize() }
  
        }
        .padding()

    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView()
    }
}

struct CustomAnimationViewModifier: ViewModifier {
    var value: CGFloat
    @Binding var valueAnimation: CGFloat
    var duration: Double
    var qualityOfAnimation: Quality
    
    init(value: CGFloat, valueAnimation: Binding<CGFloat>, duration: Double, qualityOfAnimation: Quality) {
        self.value = value
        self._valueAnimation = valueAnimation
        self.duration = duration
        self.qualityOfAnimation = qualityOfAnimation
        
    }

    func body(content: Content) -> some View {
        return content
            .onAppear() { valueAnimation = value }
            .onChange(of: value) { [value] newValue in
                let millisecondsDuration: Int = Int(duration * 1000)
                let tik: Int = qualityOfAnimation.rawValue
                let step: CGFloat = (newValue - value) / CGFloat(millisecondsDuration/tik)
                valueAnimationFunction(tik: tik, step: step, value: newValue, increasing: step > 0.0 ? true : false)
            }
    }
    
    func valueAnimationFunction(tik: Int, step: CGFloat, value: CGFloat, increasing: Bool) {
        if increasing {
            if valueAnimation + step < value {
                valueAnimation += step
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(tik)) {
                    valueAnimationFunction(tik: tik, step: step, value: value, increasing: increasing)
                }
            } else {
                valueAnimation = value
            }
        } else {
            if valueAnimation + step > value {
                valueAnimation += step
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(tik)) {
                    valueAnimationFunction(tik: tik, step: step, value: value, increasing: increasing)
                }
            } else {
                valueAnimation = value
            }
        }
    }
}


extension View {
    func customAnimation(value: CGFloat, valueAnimation: Binding<CGFloat>, duration: Double, qualityOfAnimation: Quality = Quality.excellent) -> some View {
        return self.modifier(CustomAnimationViewModifier(value: value, valueAnimation: valueAnimation, duration: duration, qualityOfAnimation: qualityOfAnimation))
    }
}

enum Quality: Int, CustomStringConvertible {
    case excellent = 1, high = 10, basic = 100, slow = 1000
    var description: String {
        switch self {
        case .excellent: return "excellent"
        case .high: return "high"
        case .basic: return "basic"
        case .slow: return "slow"
        }
    }

}

extension Double {
    var rounded: String {
        get {
            return String(Double(self * 100.0).rounded() / 100.0)
        }
    }
}
