//
//  SettingsSheetView.swift
//  One Piece Watcher
//
//  Created by Michele Lana on 10/08/25.
//


struct SettingsSheetView: View {
    @Binding var isPresented: Bool
    
    @Binding var skipFiller: Bool
    @Binding var skipMixed: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                Toggle(isOn: $skipFiller) {
                    VStack(alignment: .leading) {
                        Text("Salta Episodi")
                            .font(.title3).bold()
                        Text("Salta tutti gli episodi di tipo ")
                            .font(.subheadline)
                            .foregroundColor(.secondary) +
                        Text("Filler")
                            .bold()
                            .foregroundColor(.red)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .red))
                .onChange(of: skipFiller) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "skipFiller")
                    if newValue {
                        skipMixed = true
                    }
                }
                
                Toggle(isOn: $skipMixed) {
                    VStack(alignment: .leading) {
                        Text("Salta Episodi Mixed")
                            .font(.title3).bold()
                        Text("Salta episodi ")
                            .font(.subheadline)
                            .foregroundColor(.secondary) +
                        Text("Canon/Filler")
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .orange))
                .disabled(skipFiller)
                .onChange(of: skipMixed) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "skipMixed")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Impostazioni Episodi")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
