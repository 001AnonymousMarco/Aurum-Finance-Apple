import SwiftUI

struct AuthView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 32) {
            // Logo and Title
            VStack(spacing: 16) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.aurumGold)
                
                Text("Aurum Finance")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(isSignUp ? "Create your account" : "Welcome back")
                    .font(.headline)
                    .foregroundColor(.aurumGray)
            }
            
            // Form Fields
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(AurumTextFieldStyle())
                    .textContentType(.emailAddress)
                    #if os(iOS)
                    .autocapitalization(.none)
                    #endif
                
                SecureField("Password", text: $password)
                    .textFieldStyle(AurumTextFieldStyle())
                    .textContentType(isSignUp ? .newPassword : .password)
            }
            .padding(.horizontal, 32)
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await authenticate()
                    }
                }) {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.aurumGold)
                        .cornerRadius(12)
                }
                .disabled(email.isEmpty || password.isEmpty)
                
                Button(action: {
                    withAnimation {
                        isSignUp.toggle()
                    }
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(.aurumGold)
                }
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: 400)
        .padding(.vertical, 48)
        .background(Color.aurumDark)
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func authenticate() async {
        do {
            if isSignUp {
                try await firebaseManager.signUp(email: email, password: password)
            } else {
                try await firebaseManager.signIn(email: email, password: password)
            }
        } catch {
            DispatchQueue.main.async {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct AurumTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.aurumGray.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

#Preview {
    AuthView()
} 