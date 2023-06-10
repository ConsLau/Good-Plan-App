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
    
    //anaimation
    @State var animateProgress: Bool = false
    
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
                                .animation(.easeInOut(duration: 1), value: dailyProgressValue)
                        }
                        .frame(width: 130, height: 130)
                    }.padding(.leading, 30)

                    VStack {
                        Text("Weekly task ")
                        ZStack {
                            ProgressBar(progress: self.$weeklyProgressValue)
                                .animation(.easeInOut(duration: 1), value: weeklyProgressValue)
                        }
                        .frame(width: 130, height: 130)
                    }

                    VStack {
                        Text("Monthly task ")
                        ZStack {
                            ProgressBar(progress: self.$monthlyProgressValue)
                                .animation(.easeInOut(duration: 1), value: monthlyProgressValue)
                        }
                        .frame(width: 130, height: 130)
                    }.padding(.trailing, 30)
                    
                }

            }
            .onAppear {
                // Start the animation after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let percentages = CoreDataController().calculateCompletionPercentageForTasks()
                    self.dailyProgressValue = percentages.daily
                    self.weeklyProgressValue = percentages.weekly
                    self.monthlyProgressValue = percentages.monthly
                }
            }
            .onDisappear {
                // Reset the progress values when view is disappearing
                self.dailyProgressValue = 0
                self.weeklyProgressValue = 0
                self.monthlyProgressValue = 0
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


