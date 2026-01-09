//
//  ContentView.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Text("FuriLens")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Phase 1: Foundation Complete")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)

                Text("Camera & OCR coming in Phase 2")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    ContentView()
}
