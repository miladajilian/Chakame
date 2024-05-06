//
//  CenturyRow.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftUI

struct PoetRow: View {
  let poet: PoetEntity?

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: APIConstants.url + (poet?.imageUrl ?? ""))) { image in
                image
                    .resizable()
            } placeholder: {
                if poet?.imageUrl != nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.4))
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(poet?.nickname ?? "")
                    .multilineTextAlignment(.center)
            }
            .lineLimit(1)
        }
        .font(.customTitle3)
    }
}

#Preview {
    PoetRow(poet: CoreDataHelper.getTestPoetEntity())
}
