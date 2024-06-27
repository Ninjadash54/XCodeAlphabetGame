/*//View2.swift
import SwiftUI

struct View2: View {
    @StateObject private var connectivityManager = ConnectivityManager()
    
    var body: some View {
        ZStack {
            Color.BG
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: connectivityManager.receivedMessage != nil ? "hand.raised.fill" : "1.square.fill")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(connectivityManager.receivedMessage != nil ? .blue : .SQB)
                    .onTapGesture {
                        // You can add any additional action here if needed
                    }
                
                if let message = connectivityManager.receivedMessage {
                    Text(message)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                } else {
                    Text("Hello, world!")
                        .bold()
                        .foregroundColor(.SQW) // Added white color for text
                }
            }
            .padding()
        }
    }
}



#if DEBUG
struct View2_Previews: PreviewProvider {
    static var previews: some View {
        View2()
    }
}
#endif
*/
