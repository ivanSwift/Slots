//
//  ContentView.swift
//  Slots
//
//  Created by Иван Терехов on 17.03.2025.
//

import SwiftUI
import AVFAudio
import AVFoundation

enum Emojies: String, CaseIterable{
    case clever = "☘️"
    case coconut = "🥥"
    case grape = "🍇"
    case cherry = "🍒"
    case lemon = "🍋"
    
   
}


struct ContentView: View {
    var body: some View {
        SlotsView().ignoresSafeArea()
    }
}


final class SlotsGame: ObservableObject{
    
    @Published var emojies = Emojies.allCases
    @Published var reelFinalSymbols: [Emojies] = [.clever, .coconut, .grape]
    @Published var isSpinningReels = [false, false, false]
    @Published var score = 0
    @Published var isSpinning = false
    @Published var showWinAnimation = false
    
    init(emojies: [Emojies] = Emojies.allCases, isSpinningReels: [Bool] = [false, false, false], score: Int = 0, isSpinning: Bool = false, showWinAnimation: Bool = false, soundManager: SoundManager = SoundManager()) {
        
        self.emojies = emojies
        self.reelFinalSymbols = reelFinalSymbols
        self.isSpinningReels = isSpinningReels
        self.score = score
        self.isSpinning = isSpinning
        self.showWinAnimation = showWinAnimation
        self.soundManager = soundManager
        soundManager.playBackgroundMusic()
    }
    
    var soundManager = SoundManager()
    
    func spin() {
        guard !isSpinning else { return }
        isSpinning = true
        
        soundManager.playSpinSound()
        showWinAnimation = false
        isSpinningReels = [true, true, true]
        for i in isSpinningReels.indices {
            let delay = Double (i) * 0.6 + 1.0
            DispatchQueue.main.asyncAfter(deadline:
                    .now() + delay) {
                        self.isSpinningReels[i] = false
                        self.reelFinalSymbols[i] = Emojies.allCases.randomElement()!
                        print(self.reelFinalSymbols[i])
                        if i == self.isSpinningReels.count - 1 {
                            self.isSpinning = false
                            self.checkWin()
                        }
                    }
        }
    }
    
    func checkWin(){
        if reelFinalSymbols[0] == reelFinalSymbols[1] && reelFinalSymbols[1] == reelFinalSymbols[2]{
            soundManager.playWinSound()
            score += 1000
            withAnimation(.spring()) {
                showWinAnimation = true}
            showWinAnimation = true
            print("win")
        }
    }
 
}


import AVFoundation

class SoundManager: NSObject, AVAudioPlayerDelegate {
    var backgroundMusicPlayer: AVAudioPlayer? // Фоновая музыка
    var soundEffectPlayer: AVAudioPlayer?     // Эффекты (например, звук рулетки)
    
    // Настройка аудио-сессии (чтобы звуки могли играть одновременно)
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    // Запуск фоновой музыки
    func playBackgroundMusic() {
        if let soundURL = Bundle.main.url(forResource: "funk", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: soundURL)
                
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.8// Повторять бесконечно
                backgroundMusicPlayer?.play()
                
            } catch {
                print("Error playing background music: \(error.localizedDescription)")
            }
        }
    }

    // Остановка фоновой музыки
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    // Возобновление фоновой музыки
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
    }
    // Воспроизведение звука рулетки с паузой фоновой музыки
    func playSpinSound() {
        
            if let soundURL = Bundle.main.url(forResource: "spin", withExtension: "mp3") {
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: soundURL)
                
                soundEffectPlayer?.volume = 1.5
                soundEffectPlayer?.play()
                soundEffectPlayer?.delegate = self
                
                
            } catch {
                print("Error playing spin sound: \(error.localizedDescription)")
            }
        }
    }
    func playWinSound() {
        pauseBackgroundMusic() // Сначала остановим фоновую музыку
        
        if let soundURL = Bundle.main.url(forResource: "win", withExtension: "mp3") {
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: soundURL)
                soundEffectPlayer?.play()
                
                // Автоматически возобновляем музыку после окончания звука рулетки
                DispatchQueue.main.asyncAfter(deadline: .now() + (soundEffectPlayer?.duration ?? 1.0)) {
                    self.resumeBackgroundMusic()
                }
            } catch {
                print("Error playing spin sound: \(error.localizedDescription)")
            }
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let soundURL = Bundle.main.url(forResource: "afterSpin", withExtension: "mp3") {
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: soundURL)
                soundEffectPlayer?.delegate = self
                soundEffectPlayer?.volume = 0.8
                soundEffectPlayer?.numberOfLoops = 1
                soundEffectPlayer?.play()
                
                
            } catch {
                print("Error playing spin sound: \(error.localizedDescription)")
            }
        }
        
        
    }
    
}

struct SlotsView: View {
    @StateObject var game = SlotsGame()
    var body: some View {
        ZStack{
            LinearGradient(colors: game.showWinAnimation ? [.yellow, .orange] : [.purple,.black], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 40){
                SlotMachineTitle()
               
                createReelsView()                    .scaleEffect(game.showWinAnimation ? 1.5 : 1) // Эффект увеличения при выигрыше
                    .rotationEffect(game.showWinAnimation ? .degrees(35) : .degrees(0)) // Вращение при выигрыше
                    .animation(.easeInOut(duration: 0.5), value: game.showWinAnimation)
                
                StartButton(game: game)
                ScoreView(score: game.score)
                
                
            }
        }
    }
        @ViewBuilder
         func createReelsView() -> some View {
                HStack(spacing: 16) {
                    ForEach(0..<game.reelFinalSymbols.count, id: \.self) { index in
                        
                        ReelView(finalEmoji: $game.reelFinalSymbols[index], isSpinning: $game.isSpinningReels[index])
                            .frame(width: 100, height: 200)
                    }
                }
                .padding()
                .background { Color.white.opacity(0.2) }
                .clipShape(RoundedRectangle(cornerRadius: 36))
    
        }
    
}




struct StartButton: View {
    @ObservedObject var game: SlotsGame
    @State private var isPressed = false
    @State private var gradientShift = false
    var body: some View {
        Button {game.spin()} label:{
            Text("Крутить")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(width: 250, height: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: gradientShift ? [Color.red, Color.orange, Color.yellow] : [Color.yellow, Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: gradientShift)
                )
                .cornerRadius(15)
                .shadow(color: .yellow.opacity(0.8), radius: isPressed ? 5 : 15, x: 0, y: 5)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
        }
        .disabled (game.isSpinning)
        .opacity(game.isSpinning ? 0.5 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onAppear {
            gradientShift.toggle()
        }

    }
}





//struct SlotMachineView: View {
//    @ObservedObject var game: SlotsGame
//
//    var body: some View {
//        VStack {
//            HStack(spacing: 10) {
//                ForEach(0..<3, id: \ .self) { index in
//                    ReelView(finalSymbol: game.reelFinalSymbols[index], isSpinning: game.isSpinningReels[index])
//                }
//            }
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 20).fill(Color.purple.opacity(0.3)))
//            .padding()
//
//            if game.showWinAnimation {
//                Text("🎉 WIN! 🎉")
//                    .font(.largeTitle)
//                    .transition(.scale)
//            }
//
//            Text("Score: \(game.score)")
//                .font(.title)
//                .padding()
//
//            Button(action: {
//                game.spin()
//            }) {
//                Text("Spin")
//                    .font(.title2)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .disabled(game.isSpinning)
//        }
//    }
//}
//
//struct ReelView: View {
//    let finalSymbol: Emojies
//    let isSpinning: Bool
//    @State private var offset: CGFloat = -200
//    @State var FinalSymbolPosition:CGPoint = .zero
//
//    private let symbols: [Emojies] = Emojies.allCases.shuffled()
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.purple.opacity(0.2))
//                .frame(width: 100, height: 200)
//
//            VStack(spacing: 5) {
//                ForEach(symbols, id: \ .self) { emoji in
//                    GeometryReader { GeometryProxy in
//                        Text(emoji.rawValue)
//                            .font(.largeTitle)
//                            .onChange(of: GeometryProxy) { oldValue, newValue in
//                                if finalSymbol == emoji{
//                                    let frame = GeometryProxy.frame(in: .global)
//                                    FinalSymbolPosition = CGPoint(x: frame.minX, y: frame.minY)
//
//                                }
//
//                            }
//                    }
//
//
//                }
//            }
//            .offset(y: offset)
//            .animation(isSpinning ?
//                Animation.linear(duration: 0.1).repeatForever(autoreverses: false) :
//                Animation.easeOut(duration: 1),
//                value: offset)
//        }
//        .clipped()
//        .onChange(of: isSpinning) { spinning in
//            if spinning {
//                startSpinning()
//            } else {
//                stopSpinning()
//            }
//        }
//    }
//
//    private func startSpinning() {
//        offset = -200
//        withAnimation(Animation.linear(duration: 0.1).repeatForever(autoreverses: false)) {
//            offset = 200
//        }
//    }
//
//    private func stopSpinning() {
//        withAnimation(.easeOut(duration: 1)) {
//            offset = 0 + FinalSymbolPosition.y
//        }
//    }
//}



struct ReelView: View {
    @Binding var finalEmoji: Emojies
    @Binding var isSpinning: Bool
    @State private var symbolsOffset: CGFloat = 0
    @State private var timer: Timer?
    private let emojis = Emojies.allCases
    private let emojiHeight: CGFloat = 65  // Высота одного эмодзи
    private let visibleEmojis = 3          // Сколько эмодзи видно в окне
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ForEach(0..<1000, id: \.self) { index in
                    Text(emojis[index % emojis.count].rawValue)
                        .font(.system(size: 65))
                }
                Spacer()
            }
            .offset(y: symbolsOffset)
            .padding(.horizontal, 15)
            .padding(.vertical, -60)
            .background(Color.white.opacity(0.2))
            .frame(height: 210)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onChange(of: isSpinning) { _, newValue in
                if newValue {
                    startSpinning()
                } else {
                    stopSpinning()
                }
            }
        }
    }
    
    private func startSpinning() {
        timer?.invalidate()
        symbolsOffset = 0
        
        // Запускаем прокрутку
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.02)) {
                symbolsOffset -= 20
            }
        }
    }
    
    private func stopSpinning() {
        timer?.invalidate()
        timer = nil
        
        // Находим индекс finalEmoji в массиве
        if let index = emojis.firstIndex(of: finalEmoji) {
            // Рассчитываем нужное смещение для центрирования finalEmoji
            let targetOffset = -CGFloat(index) * emojiHeight + CGFloat(visibleEmojis / 2) * emojiHeight
            
            withAnimation(.easeOut(duration: 0.5)) {
                // Устанавливаем finalEmoji в центр
                symbolsOffset = targetOffset - 150
            }
        }
    }
}
struct CasinoSlotButton: View {
    var closure: (() ->())!
    @State private var isPressed = false
    @State private var gradientShift = false
    
    var body: some View {
        Button {closure()} label:{
            Text("Крутить")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(width: 250, height: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: gradientShift ? [Color.red, Color.orange, Color.yellow] : [Color.yellow, Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: gradientShift)
                )
                .cornerRadius(15)
                .shadow(color: .yellow.opacity(0.8), radius: isPressed ? 5 : 15, x: 0, y: 5)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onAppear {
            gradientShift.toggle()
        }
    }
    
    func spinSlots() {
        // Запуск анимации слотов
        print("Slots are spinning!")
    }
}


struct SlotMachineTitle: View {
    var body: some View {
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





struct ScoreView: View {
    var score: Int

    var body: some View {
        VStack{
            Text("YOUR BALANCE")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 30)
                
            Text(String(format: "%06d", score)) // 6-значный счёт с ведущими нулями
                .font(.custom("DBLCDTempBlack", size: 50)) // Шрифт в стиле цифрового дисплея
                .foregroundColor(.orange)
                .shadow(color: .red.opacity(0.8), radius: 8, x: 0, y: 0) // Эффект свечения
                .shadow(color: .black.opacity(0.9), radius: 5, x: 2, y: 2) // Глубина
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.8))
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                        )
                )
        }
            .padding()
    }
}




          
 
#Preview {
    ContentView()
}
