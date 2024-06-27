import SwiftUI

struct GridView: View {
    let gridSize = 5 // Number of rows and columns in the grid
    let plusSize: CGFloat = 40 // Size of each plus sign
    let spacing: CGFloat = 15 // Spacing between plus signs

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: spacing) {
                ForEach(0..<gridSize) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<gridSize) { column in
                            if row * gridSize + column < 26 {
                                Image(systemName: "plus")
                                    .font(.system(size: plusSize, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(width: plusSize, height: plusSize)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Plus Grid View")
    }
}

struct PlusGridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}
