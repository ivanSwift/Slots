//
//  SwiftUIView2.swift
//  Slots
//
//  Created by Иван Терехов on 19.03.2025.
//

import SwiftUI



struct VerticalLoopingCanvasView: View {
    @State private var currentOffset: CGFloat = 0
    @State private var animationSpeed: CGFloat = 150
    @State private var isStopping = false
    
    @State private var targetEmoji: String? = nil
    
    private let emojis = ["😀", "🎉", "🚀", "🌟", "🍎"]
    private let itemHeight: CGFloat = 50
    private let spacing: CGFloat = 20
    private let centerY: CGFloat = 150 // Центр экрана

    var body: some View {
        VStack {
            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let fullHeight = CGFloat(emojis.count) * (itemHeight + spacing)
                
                Canvas { ctx, size in
                    for i in 0..<emojis.count {
                        if let symbol = ctx.resolveSymbol(id: i) {
                            let baseYOffset = (elapsed * animationSpeed + currentOffset).truncatingRemainder(dividingBy: fullHeight)
                            let yPosition = (CGFloat(i) * (itemHeight + spacing) + baseYOffset)
                                .truncatingRemainder(dividingBy: fullHeight)
                            let finalY = yPosition < 0 ? yPosition + fullHeight : yPosition
                            
                            ctx.draw(symbol, at: CGPoint(x: size.width / 2, y: finalY))
                        }
                    }
                } symbols: {
                    ForEach(0..<emojis.count, id: \.self) { i in
                        Text(emojis[i])
                            .font(.system(size: 40))
                            .tag(i)
                    }
                }
            }
            .frame(width: 200, height: 300)
            .border(Color.gray)
            
            // Добавляем меню с кнопками
            Button{stopAtTargetEmoji("🚀")} label:{
                Text("stop")
            }
        }
    }

    /// Докручивание до нужного эмодзи и остановка
    private func stopAtTargetEmoji(_ emoji: String) {
        guard let targetIndex = emojis.firstIndex(of: emoji) else { return }
        targetEmoji = emoji
        isStopping = true

        let targetY = CGFloat(targetIndex) * (itemHeight + spacing)

        withAnimation(.easeOut(duration: 2)) {
            animationSpeed = 20 // Замедляем перед точной остановкой
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 1)) {
                currentOffset += centerY - targetY
                animationSpeed = 0
                isStopping = false
                targetEmoji = nil
            }
        }
    }
}

#Preview {
    VerticalLoopingCanvasView()
}
