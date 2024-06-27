import SwiftUI

struct ContentView: View {
    @State private var isShowingView3 = false

    var body: some View {
        NavigationView {
            Button(action: {
                self.isShowingView3 = true
            }) {
                ZStack {
                    Color.BG
                        .ignoresSafeArea()
                    
                    VStack {
                        Image(systemName: "1.square.fill")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80.0, height: 80.0)
                            .imageScale(.large)
                            .foregroundColor(.SQB)
                            .padding()

                        Text("Hello, world!")
                            .bold()
                            .foregroundColor(.SQW) // Added white color for text
                    }
                }
            }
            .foregroundColor(.blue) // Button text color
            .fullScreenCover(isPresented: $isShowingView3) {
                View3()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
