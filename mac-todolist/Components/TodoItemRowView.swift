//
//  TodoItemRowView.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 12/06/24.
//

import SwiftUI

struct TodoItemRowView: View {
    @Binding var title: String
    @Binding var category: String
    @Binding var checked: Bool
    @Binding var color: Color?
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: {}) {
                Image(systemName: checked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(checked ? .blue : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Design Interface")
                    .font(.system(size: 14))
                
                HStack(alignment: .center, spacing: 3) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(color ?? .green)
                    Text("Categories")
                        .foregroundStyle(TintShapeStyle())
                        .tint(.gray)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(TintShapeStyle())
        .tint(.white)
        .cornerRadius(4)
        
    }
}

#Preview {
    VStack(spacing: 12) {
        TodoItemRowView(title: .constant("Design Interface"),
                        category: .constant("Work"),
                        checked: .constant(false),
                        color: .constant(nil))
        .frame(width: 280, height: 48)
        
        TodoItemRowView(title: .constant("Design Interface"),
                        category: .constant("Work"),
                        checked: .constant(true),
                        color: .constant(.red))
        .frame(width: 280, height: 48)
    }
    .padding(.all, 32)
}
