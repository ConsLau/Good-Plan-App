//
//  ProgressCheck.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 20/5/2023.
//

import SwiftUI
import FirebaseAuth
import CoreData

// Grid
//struct GridBackground: View {
//    let rows = 10
//    let columns = 10
//
//    var body: some View {
//        VStack(spacing: 0) {
//            ForEach(0..<rows, id: \.self) { _ in
//                HStack(spacing: 0) {
//                    ForEach(0..<columns, id: \.self) { _ in
//                        Rectangle()
//                            .fill(Color("ButtonBackgroundColour").opacity(0.2))
//                        //Change color as per your needs
//                            .frame(width: 30, height: 15)
//                    }
//                }
//            }
//        }
//        .cornerRadius(15)
//    }
//}

struct ProgressCheck: View {


    @State var dailyProgressValue: Float = 0.0
    @State var weeklyProgressValue: Float = 0.0
    @State var monthlyProgressValue: Float = 0.0
    let userID: String
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // bar
    @State var monthlyTasks: [Int] = []

    var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
//                    Color.gray
//                        .opacity(0.1)
//                        .edgesIgnoringSafeArea(.all)

                    VStack {

                        Text("Daily task completion").padding(20)
                        ZStack {
                            ProgressBar(progress: self.$dailyProgressValue)
                            //GridBackground()
                        }
                        .frame(width: 150, height: 150)
                        .padding(10)


                        Text("Weekly task completion").padding(20)
                        ZStack {
                            ProgressBar(progress: self.$weeklyProgressValue)
                            //GridBackground()
                        }
                        .frame(width: 150, height: 150)
                        .padding(10)

                        Text("Monthly task completion").padding(20)
                        ZStack {
                            ProgressBar(progress: self.$monthlyProgressValue)
                            //GridBackground()
                        }
                        .frame(width: 150, height: 150)
                        .padding(30)


                        // bar
                        Text("Monthly amount of tasks completion").padding(20)
                        VStack(alignment: .leading) {
                            ForEach(0..<12, id: \.self) { month in
                                if month < self.monthlyTasks.count {
                                    HStack {
                                        Text(getMonthName(from: month))

                                        Rectangle()
                                            .fill(Color("ButtonBackgroundColour"))
                                            .frame(width: CGFloat(self.monthlyTasks[month]) * 10, height: 20)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        .background(Color("ButtonBackgroundColour").opacity(0.2))
                        Spacer()
                    }
                    
                }
                
                
            }.onAppear {
                let percentages = CoreDataController().calculateCompletionPercentageForTasks(userID: self.userID)
                self.dailyProgressValue = percentages.daily
                self.weeklyProgressValue = percentages.weekly
                self.monthlyProgressValue = percentages.monthly
                
                //bar
                self.monthlyTasks = CoreDataController().fetchCompletedTasksPerMonth()
            }
        
        
        
    }
    
    func getMonthName(from index: Int) -> String {
        let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return monthNames[index]
    }

    
}

struct ProgressBar: View {

    @Binding var progress: Float

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(1.0)
                .foregroundColor(Color("ButtonTextColour"))

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color("ButtonBackgroundColour"))
                .rotationEffect(Angle(degrees: 270.0))
//                .animation(.linear)

            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.largeTitle)
                .bold()
        }
    }
}

struct ProgressCheck_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCheck(userID: "testUserID")
    }
}

class ProgressCheckViewController: UIHostingController<ProgressCheck>{
    required init?(coder aDecoder: NSCoder) {
        // Fetch the current user's ID
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("No user is currently logged in.")
        }

        super.init(coder: aDecoder, rootView: ProgressCheck(userID: userID))
    }
}


