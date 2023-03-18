import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
struct SingUp: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedUp: Bool = false
    @State private var showToast = false
    
    var body: some View {
        NavigationView {
           
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.horizontal)
                    .submitLabel(.done)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.horizontal)
                    .submitLabel(.done)
                Button(action: {
                    register()
                    showToast.toggle()
                }, label: {
                    Text("Sign up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(15.0)
                })
                .padding(.top)
                Spacer()
            }
            .navigationBarTitle("Sing up Page")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    func register(){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}

class UserSettings: ObservableObject {
    @Published var isLoggedin: Bool = false
}
struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        NavigationView {
            
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.horizontal)
                    .submitLabel (.done)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.horizontal)
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(15.0)
                    
                }
                .padding(.top)
                NavigationLink {
                    SingUp()
                } label: {
                    Text("Sign up")
                }

                Spacer()

            }
            .navigationBarTitle("Login Page")
            
        }

        .navigationViewStyle(StackNavigationViewStyle())
    }
    func login(){
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
struct ContentView: View {
    @StateObject var userSettings = UserSettings()
    
    var body: some View{
        Group{
            if userSettings.isLoggedin {
                TabView{
                    
                    Expenses()
                        .tabItem {
                            Label("Expenses", systemImage: "arrow.down.forward")
                        }
                
                    Charts()
                        .tabItem {
                            Label("Charts", systemImage: "chart.pie")
                            
                        }
                    Incomes()
                        .tabItem {
                            Label("Incomes", systemImage: "arrow.up.forward")
                            
                        }
                    
                }
            } else {
                Login()
                    .environmentObject(userSettings)
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { auth, user in
                if user != nil {
                    self.userSettings.isLoggedin = true
                } else {
                    self.userSettings.isLoggedin = false
                }
            }
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
