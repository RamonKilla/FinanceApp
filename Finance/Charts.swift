//
//  Charts.swift
//  Finance
//
//  Created by Ivan on 13.03.2023.
//
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseSwift
import SwiftUICharts
struct Charts: View {
    @StateObject var viewModelIncome = IncomeViewModel()
    @StateObject var viewModelExpense = ExpenseViewModel()
    var body: some View {
        let data: [Double] = [viewModelIncome.totalIncome, viewModelExpense.totalExpense]
        VStack{
            PieChartView(data: data, title: "Totals",style: Styles.barChartStyleOrangeDark, form: ChartForm.large)
            Spacer()
            
        }
    }
}

struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        Charts()
    }
}
