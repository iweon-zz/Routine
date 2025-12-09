import SwiftUI

struct TodoView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @State private var selectedDate = Date()
    @State private var newTaskTitle = ""
    var filteredTasks: [TaskItem] {
        viewModel.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical).environment(\.locale, Locale(identifier: "ko_KR")).accentColor(.mint)
                            .padding().background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1))).padding(.horizontal)
                        HStack { Text("할 일 (\(filteredTasks.count))").font(.headline).foregroundColor(.gray); Spacer() }.padding(.horizontal)
                        
                        if filteredTasks.isEmpty {
                            Text("등록된 할 일이 없습니다.").foregroundColor(.gray).padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(filteredTasks) { task in
                                    HStack {
                                        Button(action: { viewModel.toggleTask(task: task) }) {
                                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(task.isCompleted ? .mint : .gray).font(.title2)
                                        }
                                        Text(task.title).strikethrough(task.isCompleted).foregroundColor(task.isCompleted ? .gray : .primary)
                                        Spacer()
                                        Button(action: { viewModel.deleteTask(task: task) }) {
                                            Image(systemName: "trash").foregroundColor(.red)
                                        }
                                    }
                                    .padding().background(Color.gray.opacity(0.05)).cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                Divider()
                HStack {
                    TextField("새로운 할 일...", text: $newTaskTitle).padding().background(Color.gray.opacity(0.2)).cornerRadius(10)
                    Button(action: {
                        guard !newTaskTitle.isEmpty else { return }
                        viewModel.addTask(title: newTaskTitle, date: selectedDate)
                        newTaskTitle = ""
                    }) {
                        Image(systemName: "plus").foregroundColor(.white).padding().background(Color.mint).cornerRadius(10)
                    }
                }.padding()
            }
            .navigationTitle("할 일 캘린더").navigationBarTitleDisplayMode(.inline)
        }
    }
}
