//
//  ContentView.swift
//  Vision Classifier Live
//
//  Created by Daniel Zimmerman on 9/29/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
    @StateObject  var vm = CameraViewModel()
        
        GeometryReader { geo in
            
            ZStack {
                Color.green.ignoresSafeArea()
                ForEach (vm.detections) { det in
                    let box = pixelRect(from: det.normalizedBounds, in: geo.size)
                    Rectangle()
                        .stroke(.red, lineWidth: 2)
                        .frame(width: box.width, height: box.height)
                        .position(x: box.midX, y: box.midY)
                    Text("\(det.label) \(Int(det.score * 100))%")
                        .font(.caption).bold().foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .position(x: box.midX, y: box.midY - 90)
                }
            }
            
        }
        
    }
        
    private func pixelRect(from norm: CGRect, in size: CGSize) -> CGRect {
        CGRect(
            x: norm.origin.x * size.width,
            y: norm.origin.y * size.height, // flip Y
            //y: (1 - norm.origin.y - norm.height) * size.height, // flip Y
            width: norm.width * size.width,
            height: norm.height * size.height
        )
    }
}

#Preview {
    ContentView()
}
