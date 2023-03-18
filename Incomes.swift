import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseSwift
struct IncomeItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let selectedGroup: String

}
class IncomeViewModel: ObservableObject {
    @Published var income = [IncomeItem]()
    @Published var totalIncome: Double = 0.0
    private let databaseRef = Database.database(url: "https://financeproject-32388-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    init() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let incomeRef = databaseRef.child("income").child(userID)
        incomeRef.observe(.value) { snapshot in
            var fetchedIncome = [IncomeItem]()
            var total = 0.0
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let name = dict["name"] as? String,
                   let groups = dict["group"] as? String,
                   let amount = dict["amount"] as? Double {
                    let item = IncomeItem(name: name, amount: amount, selectedGroup: groups)
                    fetchedIncome.append(item)
                    total += amount
                }
            }
            
            self.income = fetchedIncome
            self.totalIncome = total
        }
        let totalIncomeRef = databaseRef.child("totalIncome").child(userID)
        totalIncomeRef.observe(.value) { snapshot in
            if let value = snapshot.value as? Double {
                self.totalIncome = value
            }
        }
        
        
        
    }
    
    func addIncome(name: String, amount: Double, groups: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let incomeRef = databaseRef.child("income").child(userID).childByAutoId()
        incomeRef.setValue(["name": name, "amount": amount, "group": groups])
        let totalIncomeRef = databaseRef.child("totalIncome").child(userID)
                totalIncomeRef.setValue(self.totalIncome + amount)
    }
    func deleteIncome(at index: Int) {
        let incomeItem = income[index]
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let databaseRef = Database.database(url: "https://financeproject-32388-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        let incomeRef = databaseRef.child("income").child(userID)
        let itemRef = incomeRef.queryOrdered(byChild: "name").queryEqual(toValue: incomeItem.name).ref
        
        itemRef.observeSingleEvent(of: .value) { snapshot in
            guard let item = snapshot.value as? [String: Any],
                  let itemId = item.keys.first else {
                return
            }
            
            incomeRef.child(itemId).removeValue()
        }
        
        income.remove(at: index)
        totalIncome -= incomeItem.amount
    }

}
    
struct Incomes: View {
    @StateObject private var viewModel = IncomeViewModel()
    @State private var incomeName = ""
    @State private var incomeAmount = ""
    let groupOfItem: [String] = ["🍔 Food", "🧾 Purchases", "🏠 Home", "🚎 Transport", "🚗 Cars", "🎉 Party", "💻 Network", "💵 Finances", "📈 Invest", " ？Other"]
    @State private var incomeGroup = "🍔 Food"
    var body: some View {
        
        
        NavigationView {
            
            List {
                Section(header: Text("Add a new income")) {
                    TextField("Income Name", text: $incomeName)
                        .submitLabel(.done)
                    TextField("Amount", text: $incomeAmount)
                        .keyboardType(.numberPad)
                        
                    Picker("Category", selection: $incomeGroup) {
                        ForEach(groupOfItem, id: \.self) {
                            Text($0)
                        }
                    }
                    
                }
                Section {
                    Button(action: {
                        guard let actualAmount = Double(self.incomeAmount) else {
                            return
                        }
                        viewModel.addIncome(name: self.incomeName, amount: actualAmount, groups: self.incomeGroup)
                        self.incomeName = ""
                        self.incomeAmount = ""
                        self.incomeGroup = ""

                        
                    }) {
                        Text("Add Income")
                    }
                    
                }
                Section(header: Text("Incomes")) {
                    ForEach(viewModel.income) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.selectedGroup)
                                .foregroundColor(Color.gray)
                            Spacer()
                            Text("MDL \(item.amount, specifier: "%.2f")")
                            
                        }
                        .swipeActions {
                            Button(action: {
                                viewModel.deleteIncome(at: viewModel.income.firstIndex(where: { $0.id == item.id })!)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        
                    }
                    
                    
                }
                Section {
                    Text("Total Income: MDL \(viewModel.totalIncome, specifier: "%.2f")")
                        .font(.headline)
                }
            }
            .navigationBarTitle("Your Incomes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                                
                            } catch let signOutError as NSError {
                              print("Error signing out: %@", signOutError)
                            }
                        }) {
                            Label("LogOut", systemImage: "doc")

                        }
                        
                    }
                    label: {
                        Label("Add", systemImage: "gear")
                        
                    }
                   
                }
            }
        }
    }
}
struct Income_Previews: PreviewProvider {
    static var previews: some View {
        Incomes()
    }
}
