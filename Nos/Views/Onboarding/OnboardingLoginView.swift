import SwiftUI
import Dependencies
import Logger

struct OnboardingLoginView: View {
    let completion: @MainActor () -> Void
    
    @Dependency(\.analytics) private var analytics
    @Environment(CurrentUser.self) private var currentUser
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var privateKeyString = ""
    @State private var showError = false
    
    @MainActor private func importKey(_ keyPair: KeyPair) async {
        await currentUser.setKeyPair(keyPair)
        analytics.importedKey()

        for address in Relay.allKnown {
            do {
                let relay = try Relay.findOrCreate(by: address, context: viewContext)
                currentUser.onboardingRelays.append(relay)
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        try? currentUser.viewContext.saveIfNeeded()

        completion()
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    SecureField("privateKeyPlaceholder", text: $privateKeyString)
                        .foregroundColor(.primaryTxt)
                } header: {
                    Text("pasteYourSecretKey")
                        .foregroundColor(.primaryTxt)
                        .fontWeight(.heavy)
                }
                .listRowGradientBackground()
            }
            if !privateKeyString.isEmpty {
                BigActionButton("login") {
                    if let keyPair = KeyPair(nsec: privateKeyString) {
                        await importKey(keyPair)
                    } else if let keyPair = KeyPair(privateKeyHex: privateKeyString) {
                        await importKey(keyPair)
                    } else {
                        self.showError = true
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBg)
        .nosNavigationBar("login")
        .alert(isPresented: $showError) {
            Alert(
                title: Text("invalidKey"),
                message: Text("couldNotReadPrivateKeyMessage")
            )
        }
    }
}
