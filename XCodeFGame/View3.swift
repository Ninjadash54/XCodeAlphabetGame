import SwiftUI

struct View3: View {
    @State private var gameSequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var currentRound = 1
    @State private var isPlayerTurn = false
    @State private var message = "Watch the sequence"
    @State private var score = 0
    @State private var showingAlert = false
    @State private var buttonFlash: Int? = nil
    @State private var rotationAngle: Double = 0.0
    @State private var isButtonPressed: Bool = false
    @State private var isRedViewPresented = false
    @State private var isBlueViewPresented = false
    @State private var isGreenViewPresented = false
    @State private var isYellowViewPresented = false
    @State private var zoomedButtonIndex: Int? = nil
    @GestureState private var zoomScale: CGFloat = 1.0

    let colors: [Color] = [.SQR, .SQB, .SQG, .SQY]
    let maxRounds = 4

    var body: some View {
        ZStack {
            Color.BG
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Text("\(score)")
                        .font(.custom("LeagueSpartan-Regular", size: 15))
                        .padding(.top, -35)
                        .padding(.trailing, 300)
                        .foregroundColor(.white)
                }
                HStack {
                    Spacer()

                    Image(systemName: "arrow.clockwise")
                        .font(.custom("LeagueSpartan-Regular", size: 16))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                        .padding(.all, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 11)
                                .foregroundColor(.SQD)
                                .shadow(radius: isButtonPressed ? 6 : 15)
                                .frame(width: 100, height: 30)
                        )
                        .padding(.top, -15)
                        .padding(.trailing, 45)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    self.isButtonPressed = true
                                }
                                .onEnded { _ in
                                    self.isButtonPressed = false
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.rotationAngle += 360.0
                                    }
                                    self.restartGame()
                                    self.triggerHapticFeedback() // Call haptic feedback method
                                }
                        )
                }

                Spacer()
            }
            VStack {
                Text("SIMON SAYS")
                    .font(.custom("LeagueSpartan-Regular", size: 50))
                    .foregroundColor(.white)

                Text("Round \(currentRound)")
                    .font(.custom("LeagueSpartan-Regular", size: 35))
                    .foregroundColor(.white)

                Text(message)
                    .font(.custom("LeagueSpartan-Regular", size: 35))
                    .foregroundColor(.white)

                HStack {
                    VStack {
                        gameButton(index: 0)
                        gameButton(index: 1)
                    }
                    VStack {
                        gameButton(index: 2)
                        gameButton(index: 3)
                    }
                }
                .disabled(!self.isPlayerTurn)

                Text("Score: \(score)")
                    .font(.custom("LeagueSpartan-Regular", size: 35))
                    .foregroundColor(.white)
                    .padding()
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Game Over"),
                    message: Text("Your final score is \(score)"),
                    dismissButton: .default(Text("OK")) {
                        self.resetGame()
                    }
                )
            }
            .onAppear(perform: startGame)

            if isRedViewPresented {
                RedView(isPresented: $isRedViewPresented)
                    .transition(.scale)
            } else if isBlueViewPresented {
                BlueView(isPresented: $isBlueViewPresented)
                    .transition(.scale)
            } else if isGreenViewPresented {
                GreenView(isPresented: $isGreenViewPresented)
                    .transition(.scale)
            } else if isYellowViewPresented {
                YellowView(isPresented: $isYellowViewPresented)
                    .transition(.scale)
            }
        }
    }

    func gameButton(index: Int) -> some View {
        let button = Button(action: {
            self.playerTapped(index)
            self.triggerHapticFeedback()
        }) {
            Image(systemName: "square.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(self.colors[index])
                .opacity(self.buttonFlash == index ? 0.5 : 1.0)
                .padding()
                .scaleEffect(zoomedButtonIndex == index ? zoomScale : 1.0)
        }
        
        return button
            .gesture(
                MagnificationGesture()
                    .updating($zoomScale) { value, scale, _ in
                        scale = value.magnitude
                        if value > 1.0 {
                            zoomedButtonIndex = index
                        }
                    }
                    .onEnded { scale in
                        if scale > 1.5 {
                            switch index {
                            case 0: isRedViewPresented = true
                            case 1: isBlueViewPresented = true
                            case 2: isGreenViewPresented = true
                            case 3: isYellowViewPresented = true
                            default: break
                            }
                            zoomedButtonIndex = nil
                        } else {
                            zoomedButtonIndex = nil
                        }
                    }
            )
            .animation(.interactiveSpring(), value: zoomScale)
            .animation(.interactiveSpring(), value: zoomedButtonIndex)
    }

    func startGame() {
        gameSequence = []
        playerSequence = []
        currentRound = 1
        score = 0
        message = "Watch the sequence"
        generateSequence()
    }

    func generateSequence() {
        gameSequence = []
        for _ in 0..<3 + currentRound - 1 {
            gameSequence.append(Int.random(in: 0..<colors.count))
        }
        playSequence()
    }

    func playSequence() {
        isPlayerTurn = false
        var delay = 0.5

        for (index, number) in gameSequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                buttonFlash = number
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
                buttonFlash = nil
                if index == gameSequence.count - 1 {
                    isPlayerTurn = true
                    message = "Your turn"
                }
            }

            delay += 1.0
        }
    }

    func playerTapped(_ index: Int) {
        guard isPlayerTurn else { return }

        playerSequence.append(index)

        if playerSequence.count == gameSequence.count {
            isPlayerTurn = false
            checkPlayerSequence()
        }
    }

    func checkPlayerSequence() {
        if playerSequence == gameSequence {
            score += currentRound
            currentRound += 1

            if currentRound > maxRounds {
                showingAlert = true
            } else {
                message = "Watch the sequence"
                playerSequence = []
                generateSequence()
            }
        } else {
            showingAlert = true
        }
    }

    func resetGame() {
        gameSequence = []
        playerSequence = []
        currentRound = 1
        score = 0
        message = "Watch the sequence"
        isRedViewPresented = false
        isBlueViewPresented = false
        isGreenViewPresented = false
        isYellowViewPresented = false
        zoomedButtonIndex = nil
    }

    func restartGame() {
        resetGame()
        startGame()
    }

    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct RedView: View {
    @Binding var isPresented: Bool
    @GestureState private var zoomScale: CGFloat = 1.0

    var body: some View {
        Color.SQR
            .ignoresSafeArea()
            .overlay(
                Text("Red View")
                    .foregroundColor(.white)
                    .font(.title)
            )
            .scaleEffect(zoomScale)
            .gesture(
                MagnificationGesture()
                    .updating($zoomScale) { value, scale, _ in
                        scale = value.magnitude
                    }
                    .onEnded { scale in
                        if scale < 0.5 {
                            isPresented = false
                        }
                    }
            )
            .animation(.interactiveSpring(), value: zoomScale)
    }
}

struct BlueView: View {
    @Binding var isPresented: Bool
    @GestureState private var zoomScale: CGFloat = 1.0

    var body: some View {
        Color.SQB
            .ignoresSafeArea()
            .overlay(
                Text("Blue View")
                    .foregroundColor(.white)
                    .font(.title)
            )
            .scaleEffect(zoomScale)
            .gesture(
                MagnificationGesture()
                    .updating($zoomScale) { value, scale, _ in
                        scale = value.magnitude
                    }
                    .onEnded { scale in
                        if scale < 0.5 {
                            isPresented = false
                        }
                    }
            )
            .animation(.interactiveSpring(), value: zoomScale)
    }
}

struct GreenView: View {
    @Binding var isPresented: Bool
    @GestureState private var zoomScale: CGFloat = 1.0

    var body: some View {
        Color.SQG
            .ignoresSafeArea()
            .overlay(
                Text("Green View")
                    .foregroundColor(.white)
                    .font(.title)
            )
            .scaleEffect(zoomScale)
            .gesture(
                MagnificationGesture()
                    .updating($zoomScale) { value, scale, _ in
                        scale = value.magnitude
                    }
                    .onEnded { scale in
                        if scale < 0.5 {
                            isPresented = false
                        }
                    }
            )
            .animation(.interactiveSpring(), value: zoomScale)
    }
}

struct YellowView: View {
    @Binding var isPresented: Bool
    @GestureState private var zoomScale: CGFloat = 1.0

    var body: some View {
        Color.SQY
            .ignoresSafeArea()
            .overlay(
                Text("Yellow View")
                    .foregroundColor(.white)
                    .font(.title)
            )
            .scaleEffect(zoomScale)
            .gesture(
                MagnificationGesture()
                    .updating($zoomScale) { value, scale, _ in
                        scale = value.magnitude
                    }
                    .onEnded { scale in
                        if scale < 0.5 {
                            isPresented = false
                        }
                    }
            )
            .animation(.interactiveSpring(), value: zoomScale)
    }
}

struct View3_Previews: PreviewProvider {
    static var previews: some View {
        View3()
    }
}
