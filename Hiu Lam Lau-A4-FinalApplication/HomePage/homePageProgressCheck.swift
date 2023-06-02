//
//  homePageProgressCheck.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 31/5/2023.
//

import SwiftUI
import CoreData


struct homePageProgressCheck: View {
    @State var dailyProgressValue: Float = 0.0
    @State var weeklyProgressValue: Float = 0.0
    @State var monthlyProgressValue: Float = 0.0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // bar
    @State var monthlyTasks: [Int] = []
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                Color.gray
                    .opacity(0.0)
                    .edgesIgnoringSafeArea(.all)

                HStack(spacing: 80) {

                    VStack {
                        Text("Daily task ")
                        ZStack {
                            ProgressBar(progress: self.$dailyProgressValue)
                        }
                        .frame(width: 130, height: 130)
                    }.padding(.leading, 30)

                    VStack {
                        Text("Weekly task ")
                        ZStack {
                            ProgressBar(progress: self.$weeklyProgressValue)
                        }
                        .frame(width: 130, height: 130)
                    }

                    VStack {
                        Text("Monthly task ")
                        ZStack {
                            ProgressBar(progress: self.$monthlyProgressValue)
                        }
                        .frame(width: 130, height: 130)
                    }.padding(.trailing, 30)
                    
                }

            }
            .onAppear {
                let percentages = CoreDataController().calculateCompletionPercentageForTasks()
                self.dailyProgressValue = percentages.daily
                self.weeklyProgressValue = percentages.weekly
                self.monthlyProgressValue = percentages.monthly
                
                //bar
                self.monthlyTasks = CoreDataController().fetchCompletedTasksPerMonth()
            }
        }
    }
}



struct ProgressBars: View {

    @Binding var progress: Float

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.6)
                .foregroundColor(Color("BackgroundColour"))

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color("ButtonBackgroundColour"))
                .rotationEffect(Angle(degrees: 270.0))
//                .animation(.linear)

            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.subheadline)
                .bold()
        }
    }
}

struct homePageProgressCheck_Previews: PreviewProvider {
    static var previews: some View {
        homePageProgressCheck()
    }
}

class homePageProgressCheckViewController: UIHostingController<homePageProgressCheck> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: homePageProgressCheck())
    }
}


