//
//  ProgressCheck.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 20/5/2023.
//
// Reference 1 SwiftUI Circular Progress Bar using Stacks and Circle Shapes: https://www.youtube.com/watch?v=H15p2gW5-G0&t=1s and https://tutorial101.blogspot.com/2021/06/swiftui-circular-progress-bar-using.html
// Reference 2 swiftUI embed into StoryBoard(UIKit) using View Hosting Controller: https://www.youtube.com/watch?v=Zrp7RzAwm8Q
// Reference 3 Horizontal Bar Chart Beginner SwiftUI Xcode Tutorial: https://www.youtube.com/watch?v=j8lRkpvVaB0&t=34s

import SwiftUI
import FirebaseAuth
import CoreData

extension Notification.Name {
    static let taskCategoriesDidChange = Notification.Name("TaskCategoriesDidChangeNotification")
}

struct TaskCategoryProgresses {
    let category: TaskCategory
    @State var progress: Float
}

struct ProgressCheck: View {


    @State var dailyProgressValue: Float = 0.0
    @State var weeklyProgressValue: Float = 0.0
    @State var monthlyProgressValue: Float = 0.0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // bar
    @State var monthlyTasks: [Int] = []
    
    
    // task category
    @State var taskCategoryProgress: [TaskCategoryProgresses] = []
    @ObservedObject var controller = CoreDataControllers()
    
    

    var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {


                    VStack {

                        Text("Daily task completion").padding(20)
                        ZStack {
                            ProgressBar(progress: self.$dailyProgressValue)
                        }
                        .frame(width: 150, height: 150)
                        .padding(30)


                        Text("Weekly task completion").padding(20)
                        ZStack {
                            ProgressBar(progress: self.$weeklyProgressValue)
                        }
                        .frame(width: 150, height: 150)
                        .padding(30)

                        Text("Monthly task completion").padding(20)
                        ZStack {
                            ProgressBar(progress: self.$monthlyProgressValue)
                        }
                        .frame(width: 150, height: 150)
                        .padding(30)

                        // task category
                        VStack(alignment: .center) {
                                                    ForEach(taskCategoryProgress.indices, id: \.self) { index in
                                                        Text(self.taskCategoryProgress[index].category.cateName ?? "")
                                                        ProgressBar(progress: self.$taskCategoryProgress[index].progress)
                                                            .frame(width: 150, height: 150)
                                                            .padding(30)
                                                    }
                                                }

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
                let percentages = CoreDataController().calculateCompletionPercentageForTasks()
                self.dailyProgressValue = percentages.daily
                self.weeklyProgressValue = percentages.weekly
                self.monthlyProgressValue = percentages.monthly
                
                //bar
                self.monthlyTasks = CoreDataController().fetchCompletedTasksPerMonth()
                
                // Fetch all unique categories
                let controller = CoreDataController()
                let categories = controller.fetchAllTaskCategories()
                self.taskCategoryProgress = categories.map { category in
                    let tasks = category.tasks?.allObjects as? [Task] ?? []
                    let completedTasks = tasks.filter { $0.isComplete == 0 }
                    let percentage = tasks.count == 0 ? 0 : Float(completedTasks.count) / Float(tasks.count)
                    return TaskCategoryProgresses(category: category, progress: percentage)
                }
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


            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.largeTitle)
                .bold()
        }
    }
}

// task category
class CoreDataControllers: ObservableObject {
    @Published var taskCategories: [TaskCategory] = []

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoListModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()

    init() {
        fetchAllTaskCategories()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taskCategoriesDidChange(_:)),
                                               name: .taskCategoriesDidChange,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func taskCategoriesDidChange(_ notification: Notification) {
        fetchAllTaskCategories()
    }

    func fetchAllTaskCategories() {
        let fetchRequest: NSFetchRequest<TaskCategory> = TaskCategory.fetchRequest()
        do {
            self.taskCategories = try self.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Fetching TaskCategories failed: \(error)")
        }
    }

    func addTaskCategory(cateName: String) {
        let taskCategory = TaskCategory(context: persistentContainer.viewContext)
        taskCategory.cateName = cateName
        saveContext()
    }

    // Rest of your CoreDataController code...

    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

struct ProgressCheck_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCheck()
    }
}

class ProgressCheckViewController: UIHostingController<ProgressCheck>{
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder, rootView: ProgressCheck())
    }
}

