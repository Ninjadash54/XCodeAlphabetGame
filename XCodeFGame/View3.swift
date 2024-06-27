

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
    @State private var rotationAngle: Double = 0.0 // State variable for rotation angle
    @State private var isButtonPressed: Bool = false // State variable to track button press

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
                        .padding(.top, -35) // Adjust the padding to fit next to the camera cutout
                        .padding(.trailing, 300)
                        .foregroundColor(.white)
                }
                HStack {
                    Spacer()
                    
                    Image(systemName: "arrow.clockwise")
                        .font(.custom("LeagueSpartan-Regular", size: 16))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle)) // Apply rotation effect based on rotationAngle state
                        .padding(.all, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 11)
                                .foregroundColor(.SQD)
                                .shadow(radius: isButtonPressed ? 6 : 15) // Adjust shadow based on button press state
                                .frame(width: 100, height: 30) // Adjust width and height as needed
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
                                        self.rotationAngle += 360.0 // Rotate by 360 degrees (one full rotation)
                                    }
                                    self.restartGame()
                                    self.vibrate() // Trigger haptic feedback
                                }
                        )
                }

                Spacer()
            }
            VStack {
                Text("SIMON SAYS")
                    .font(.custom("LeagueSpartan-Regular", size: 50))
                    .foregroundColor(.white) // White text color
                
                Text("Round \(currentRound)")
                    .font(.custom("LeagueSpartan-Regular", size: 35))
                    .foregroundColor(.white) // White text color
                
                Text(message)
                    .font(.custom("LeagueSpartan-Regular", size: 35))
                    .foregroundColor(.white) // White text color
                
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
                    .foregroundColor(.white) // White text color
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
        }
    }

    func gameButton(index: Int) -> some View {
        Button(action: {
            self.playerTapped(index)
            self.vibrate() // Trigger haptic feedback
        }) {
            Image(systemName: "square.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150) // Adjust size as needed
                .foregroundColor(self.colors[index])
                .opacity(self.buttonFlash == index ? 0.5 : 1.0)
                .padding()
        }
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
            gameSequence.append(Int.random(in: 0..<4))
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
    }

    func restartGame() {
        resetGame()
        startGame()
    }

    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct View3_Previews: PreviewProvider {
    static var previews: some View {
        View3()
    }
}
