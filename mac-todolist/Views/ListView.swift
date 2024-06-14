//
//  ListView.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 12/06/24.
//

import SwiftUI
import Combine

struct ListView<ViewModel>: View where ViewModel: ListViewModelProtocol {
    
    @FocusState private var focusView: FocusView?
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            categoryDropdownButton
            ZStack(alignment: .top) {
                categoryDropdownList
                VStack {
                    textField
                    ZStack(alignment: .top) {
                        suggestionBox
                            .frame(maxHeight: 200)
                            .zIndex(2)
                        todoList
                    }
                }.zIndex(1)
            }
        }
        .onChange(of: focusView) { oldValue, newValue in
            print("⚪️\(newValue)")
        }
    }
    
    
    @ViewBuilder
    var todoList: some View {
        List(selection: $viewModel.todoSelection) {
            ForEach($viewModel.todos, id: \.id) { todo in
                TodoItemRowView(title: todo.title,
                                category: todo.category,
                                checked: todo.finished,
                                color: todo.categoryColor)
                .tag(todo.id.wrappedValue)
            }
        }
        .onKeyPress(action: todoHandler(keyPress:))
        .focused($focusView, equals: .todo)
        .scrollIndicators(.automatic)
        .cornerRadius(8)
        .zIndex(1)
    }
    
    @ViewBuilder
    var textField: some View {
        VStack {
            TextField("Writing Articles", text: $viewModel.todoInput)
                .onKeyPress(action: fieldHandler(keyPress:))
                .focused($focusView, equals: .field)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
        }
        .modifier(textViewModifier())
    }
    
    @ViewBuilder
    var suggestionBox: some View {
        if viewModel.todoInput != "" {
            if (viewModel.suggestionMode == .todo && viewModel.suggestions.count > 0) || (viewModel.suggestionMode == .category) {
                
                List(selection: $viewModel.suggestion_todos_selection) {
                    switch viewModel.suggestionMode {
                    case .todo:
                        ForEach(viewModel.filteredTodos, id: \.id) { suggestion in
                            Text(suggestion.title)
                                .frame(height: 36)
                                .listRowSeparator(.hidden, edges: .all)
                                .tag(suggestion.title)
                                .padding(.horizontal, 8)
                        }
                        
                    case .category:
                        ForEach(viewModel.filteredCategoriesSuggestions, id: \.self) { suggestion in
                            CategoryLabelView(category: .constant(suggestion), color: .constant(.green))
                                .frame(height: 36)
                                .listRowSeparator(.hidden, edges: .all)
                                .tag(suggestion)
                        }
                        
                        if viewModel.categoryInput != "" {
                            Text("Create \"\(viewModel.categoryInput)\"")
                                .frame(height: 36)
                                .foregroundStyle(TintShapeStyle())
                                .tint(.secondary)
                                .tag(viewModel.categoryInput)
                        }
                    }
                }
                .listStyle(.plain)
                .cornerRadius(8)
                .focused($focusView, equals: .suggestion)
                .onKeyPress(action: suggestionHandler(keyPress:))
                .shadow(radius: 16, y: 16)
            }
        }
    }
    
    @ViewBuilder
    var categoryDropdownButton: some View {
        Button(action: {
            focusView = .categoryDropdownList
            viewModel.showTodoDropdown.toggle()
        }, label: {
            HStack(alignment: .center) {
                CategoryLabelView(category: $viewModel.selectedCategory, color: .constant(.green))
                Spacer()
                Image(systemName: viewModel.showTodoDropdown ? "chevron.up" : "chevron.down")
            }
            .padding(.horizontal, 8)
            .frame(height: 36)
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
            )
        })
        .focused($focusView, equals: .categoryDropdownButton)
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var categoryDropdownList: some View {
        if viewModel.showTodoDropdown {
            List(selection: $viewModel.dropdownSelection) {
                ForEach($viewModel.categories, id: \.self) { category in
                    CategoryLabelView(category: category, color: .constant(.green))
                        .tag(category.wrappedValue)
                        .frame(height: 36)
                }
            }
            .focused($focusView, equals: .categoryDropdownList)
            .onKeyPress(action: categoryDropdownHandler(keyPress:))
            .listStyle(.plain)
            .cornerRadius(8)
            .frame(maxHeight: 200)
            .shadow(radius: 16, y: 16)
            .zIndex(2)
        }
    }
    
    
}

extension ListView {
    private func fieldHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard keyPress.phase == .down else { return .ignored }
        switch keyPress.key {
        case .upArrow:
            return .handled
        case .downArrow:
            focusView = (viewModel.todoInput == "" || (viewModel.suggestions.count == 0 && viewModel.suggestionMode == .todo)) ? .todo : .suggestion
            return .handled
        default:
            return .ignored
        }
    }
    
    private func categoryDropdownHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard keyPress.phase == .down else { return .ignored }
        switch keyPress.key {
        case .return:
            viewModel.handleCategoryDropdownSelection()
            focusView = nil
            return .handled
        default:
            return .ignored
        }
    }
    
    private func todoHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard focusView == .todo,
              keyPress.key == .upArrow && viewModel.todoSelection == viewModel.todos.first?.id
        else { return .ignored }
        
        focusView = .field
        return .handled
    }
    
    private func suggestionHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard focusView == .suggestion else { return .ignored }
        
        if keyPress.key == .return {
            viewModel.handleSuggestion()
            focusView = .field
            return .handled
        }  else if keyPress.key == .upArrow && viewModel.suggestion_todos_selection == viewModel.suggestions.first {
            focusView = .field
            return .ignored
        } else {
            return .ignored
        }
    }
}

extension ListView {
    enum FocusView: Hashable, Equatable {
        case noFocus
        case categoryDropdownButton
        case categoryDropdownList
        case field
        case suggestion
        case todo
    }
    
    struct textViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(.horizontal, 18)
                .padding(.vertical, 11.5)
                .background(LinearGradient(colors: [ Color(nsColor: .controlBackgroundColor)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(8)
                .foregroundColor(.primary)
        }
    }
}



#Preview {
    ListView(viewModel: MockListViewModel())
        .padding(.all, 32)
        .frame(width: 400, height: 800)
}

