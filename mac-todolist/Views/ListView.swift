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
            Picker(selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category)
                        .tag(category)
                }
            } label: { }

            textField
            
            VStack {
                List(selection: $viewModel.suggestion_todos_selection) {
                    switch viewModel.suggestionMode {
                    case .todo:
                        ForEach(viewModel.filteredTodos, id: \.id) { suggestion in
                            Text(suggestion.title)
                                .frame(height: 36)
                                .listRowSeparator(.hidden, edges: .all)
                                .tag(suggestion.title)
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
                                .foregroundStyle(TintShapeStyle())
                                .tint(.secondary)
                                .tag(viewModel.categoryInput)
                        }
                    }
                }
                .scrollIndicators(.automatic)
                .cornerRadius(8)
                .focused($focusView, equals: .suggestion)
                .onKeyPress(action: suggestionHandler(keyPress:))
            }
            .padding(.top, 16)
            
        }
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
}

extension ListView {
    private func fieldHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard keyPress.phase == .down else { return .ignored }
        switch keyPress.key {
        case .upArrow:
            return .handled
        case .downArrow:
            focusView = .suggestion
            return .handled
        default:
            return .ignored
        }
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
        case field
        case suggestion
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
        .frame(width: 400, height: 600)
}

