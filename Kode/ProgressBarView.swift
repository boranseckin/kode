//
//  ProgressBarView.swift
//  Kode
//
//  Created by Boran Seckin on 2024-06-20.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 25)
                    .frame(height: 10)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                RoundedRectangle(cornerRadius: 25)
                    .frame(width: progress * geo.size.width, height: 10)
                    .foregroundColor(.blue)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 10)
    }
}

#Preview {
    ProgressBarView(progress: .constant(15))
}
