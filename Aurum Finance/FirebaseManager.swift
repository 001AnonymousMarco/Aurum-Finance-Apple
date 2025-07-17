import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        // Listen for authentication state changes
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    deinit {
        // Remove the auth state listener when the object is deallocated
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.currentUser = result.user
            self.isAuthenticated = true
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.currentUser = result.user
            self.isAuthenticated = true
        }
    }
    
    func signOut() throws {
        try auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }
} 