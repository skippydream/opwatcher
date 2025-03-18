import SwiftUI

struct ModeSelectionView: View {
    @State private var selectedMode: String = "Solo" // Impostazione predefinita a "Solo"

    var body: some View {
        VStack {
            Text("Scegli la modalità")
                .font(.title)
                .padding(.bottom, 40)
            
            HStack {
                // Modalità Solo
                Button(action: {
                    selectedMode = "Solo" // Imposta la modalità a "Solo"
                }) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray).opacity(0.6)
                }
                .clipShape(Circle()) // Rende il bottone circolare
                .buttonStyle(.borderless)
                
                // Modalità Coppia
                Button(action: {
                    selectedMode = "Coppia" // Imposta la modalità a "Coppia"
                }) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 80))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray).opacity(0.6)

                }
                .disabled(true)
                .clipShape(Circle()) // Rende il bottone circolare
                .buttonStyle(.borderless)

            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .edgesIgnoringSafeArea(.all)
    }
}

struct ModeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectionView()
    }
}
//
//  ModeSelectionView.swift
//  One Piece Watcher
//
//  Created by Michele Lana on 13/03/25.
//

