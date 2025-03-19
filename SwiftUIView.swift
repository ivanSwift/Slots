//
//  SwiftUIView.swift
//  Slots
//
//  Created by Иван Терехов on 18.03.2025.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        ZStack{
            Color.black
            Text("Slot Machine")
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundStyle(LinearGradient(
                    colors: [.yellow, .orange, .red],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .shadow(color: .white, radius: 4, x: 0, y: 0) // Светящаяся тень
                .shadow(color: .black.opacity(0.8), radius: 10, x: 4, y: 4) // Тень для 3D-эффекта
                .overlay(
                    Text("Slot Machine")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask(
                                Text("Slot Machine")
                                    .font(.system(size: 50, weight: .black, design: .rounded))
                            )
                        )
                )
        }
    }
}

#Preview {
    SwiftUIView()
}
