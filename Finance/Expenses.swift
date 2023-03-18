import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseSwift
struct ExpenseItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let selectedGroup: String

}
class ExpenseViewModel: ObservableObject {
    @Published var expense = [ExpenseItem]()
    @Published var totalExpense: Double = 0.0
    private let databaseRef = Database.database(url: "https://financeproject-32388-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    init() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let expenseRef = databaseRef.child("expense").child(userID)
        expenseRef.observe(.value) { snapshot in
            var fetchedExpense = [ExpenseItem]()
            var total = 0.0
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let name = dict["name"] as? String,
                   let groups = dict["group"] as? String,
                   let amount = dict["amount"] as? Double {
                    let item = ExpenseItem(name: name, amount: amount, selectedGroup: groups)
                    fetchedExpense.append(item)
                    total += amount
                }
            }
            
            self.expense = fetchedExpense
            self.totalExpense = total
        }
        let totalExpenseRef = databaseRef.child("totalExpense").child(userID)
        totalExpenseRef.observe(.value) { snapshot in
            if let value = snapshot.value as? Double {
                self.totalExpense = value
            }
        }
    }
    
    func addExpense(name: String, amount: Double, groups: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let expenseRef = databaseRef.child("expense").child(userID).childByAutoId()
        expenseRef.setValue(["name": name, "amount": amount, "group": groups])
        
        let totalExpenseRef = databaseRef.child("totalExpense").child(userID)
                totalExpenseRef.setValue(self.totalExpense + amount)
        
    }
    func deleteExpense(at index: Int) {
        let expenseItem = expense[index]
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let expenseRef = databaseRef.child("expense").child(userID)
        let itemRef = expenseRef.queryOrdered(byChild: "name").queryEqual(toValue: expenseItem.name).ref
        
        itemRef.observeSingleEvent(of: .value) { snapshot in
            guard let item = snapshot.value as? [String: Any],
                  let itemId = item.keys.first else {
                return
            }
            
            expenseRef.child(itemId).removeValue()
        }
        
        expense.remove(at: index)
        totalExpense -= expenseItem.amount
    }
}
struct Expenses: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var expenseName = ""
    @State private var expenseAmount = ""
    let groupOfItem: [String] = ["🍔 Food", "🧾 Purchases", "🏠 Home", "🚎 Transport", "🚗 Cars", "🎉 Party", "💻 Network", "💵 Finances", "📈 Invest", "？ Other"]
    @State private var expenseGroup = "🍔 Food"
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add a new expense")) {
                    TextField("Expense Name", text: $expenseName)
                        .submitLabel(.done)
                    TextField("Amount", text: $expenseAmount)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                    Picker("Category", selection: $expenseGroup) {
                        ForEach(groupOfItem, id: \.self) {
                            Text($0)
                        }
                    }
                }
                Section {
                    Button(action: {
                        guard let actualAmount = Double(self.expenseAmount) else {
                            return
                        }
                        viewModel.addExpense(name: self.expenseName, amount: actualAmount, groups: self.expenseGroup)
                        self.expenseName = ""
                        self.expenseAmount = ""
                        self.expenseGroup = ""

                    }) {
                        Text("Add Expense")
                    }
                    
                }
                Section(header: Text("Expenses")) {
                    ForEach(viewModel.expense) { item in
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
                                viewModel.deleteExpense(at: viewModel.expense.firstIndex(where: { $0.id == item.id })!)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
                Section {
                    Text("Total Expense: MDL \(viewModel.totalExpense, specifier: "%.2f")")
                        .font(.headline)
                }
            }
            .navigationBarTitle("Your Expenses")
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
struct Expenses_Previews: PreviewProvider {
    static var previews: some View {
        Expenses()
    }
}
