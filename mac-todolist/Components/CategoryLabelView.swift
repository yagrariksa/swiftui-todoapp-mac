//
//  CategoryLabelView.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 12/06/24.
//

import SwiftUI

struct CategoryLabelView: View {
    var circleSize: CGFloat = 8
    
    @Binding var category: String
    @Binding var color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: circleSize, height: circleSize)
                .foregroundColor(color)
            Text(category)
                .foregroundStyle(TintShapeStyle())
                .tint(.secondary)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    VStack(spacing: 12) {
        CategoryLabelView(category: .constant("Design"), color: .constant(.red))
        CategoryLabelView(circleSize: 6, category: .constant("Programming"), color: .constant(.purple))
        CategoryLabelView(circleSize: 12, category: .constant("Support"), color: .constant(.blue))
    }
    .padding(.all, 32)
    .frame(width: 400, height: 200 )
}
