//
//  CenturyRow.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftUI
import NukeUI

struct PoetRow: View {
  let poet: PoetEntity?

    var body: some View {
        HStack {
            LazyImage(url: URL(string: APIConstants.url + (poet?.imageUrl ?? ""))) { state in
                if state.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.4))
                } else {
                    state.image?.resizable()
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
