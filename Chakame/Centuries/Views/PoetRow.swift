//
//  PoetRow.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import NukeUI
import SwiftUI

struct PoetRow: View {
    let poet: PoetEntity

    var body: some View {
        HStack {
            LazyImage(url: URL(string: Constants.API.url + poet.imageUrl)) { state in
                if state.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.4))
                } else {
                    state.image?.resizable()
                }
            }
            .scaledToFit()
            .frame(width: 50, height: 50)
            .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text(poet.nickname)
                    .multilineTextAlignment(.center)
            }
            .lineLimit(1)
        }
        .font(.customTitle3)
    }
}

#Preview {
    if let container = PreviewContainer.shared, let poet = PreviewContainer.first(PoetEntity.self) {
        PoetRow(poet: poet)
            .modelContainer(container)
    }
}
