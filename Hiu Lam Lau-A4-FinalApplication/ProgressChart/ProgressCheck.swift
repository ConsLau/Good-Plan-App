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
import CoreData

extension Notification.Name {
    static let taskCategoriesDidChange = Notification.Name("TaskCategoriesDidChangeNotification")
}

struct TaskCategoryProgresses {
    let category: TaskCategory
    var progress: Float
}

struct ProgressCheck: View {
    
    // task category
    @State var taskCategoryProgress: [TaskCategoryProgresses] = []
    @ObservedObject var controller = TaskCategoriesController()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(taskCategoryProgress.indices, id: \.self) { index in
                    Text("Category: " + (self.taskCategoryProgress[index].category.cateName ?? "No Category"))
                    ProgressBar(progress: self.$taskCategoryProgress[index].progress)
                        .frame(width: 150, height: 150)
                        .padding(30)
                }
            }
        }
        .navigationBarTitle("Progress Checking")
        .navigationBarHidden(false)
        .onAppear(perform: loadCategoryProgress)
        .onChange(of: controller.taskCategories, perform: { _ in
                    loadCategoryProgress()
                })
    }
    
    func loadCategoryProgress() {
            let categories = self.controller.taskCategories
            self.taskCategoryProgress = categories.map { category in
                let tasks = category.tasks?.allObjects as? [Task] ?? []
                let completedTasks = tasks.filter { $0.isComplete != 1 }
                let percentage = tasks.isEmpty ? 0 : Float(completedTasks.count) / Float(tasks.count)
                return TaskCategoryProgresses(category: category, progress: percentage)
            }
        }
}

struct ProgressBar: View {
    @Binding var progress: Float

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(Color("BackgroundColour"))
            

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

class TaskCategoriesController: ObservableObject {
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
        
        NotificationCenter.default.post(name: .taskCategoriesDidChange, object: nil)
    }

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

class ProgressCheckViewController: UIHostingController<ProgressCheck> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ProgressCheck())
    }
}
