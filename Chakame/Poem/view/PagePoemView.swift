//
//  PoemTabView.swift
//  Chakame
//
//  Created by Milad on 2024-04-11.
//

import SwiftUI

struct PagePoemView: View {
    @State var currentIndex: Int
    var poems: [PoemEntity]
    
    var body: some View {
        ZStack {
            TabView(
                selection: $currentIndex) {
                    ForEach(poems.indices, id: \.self) { index in
                        PoemView(
                            viewModel: PoemViewModel(
                                poem: poems[index],
                                poemFetcher: FetchPoemService(requestManager: RequestManager.shared),
                                poemStore: PoemStoreService(context: PersistenceController.shared.container.newBackgroundContext()))
                        )
                        .tag(index)
                        .gesture(DragGesture()) // prevent changing tab by tabview gesture
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .navigationTitle(poems[currentIndex].title ?? "")
        }
        .overlay(alignment: .bottom) {
            HStack {
                // Previous Button
                Button(action: {
                    if currentIndex > 0 {
                        currentIndex -= 1
                    }
                }, label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.largeTitle)
                        .opacity(0.4)
                })
                .disabled(currentIndex == 0)
                .padding()
                
                Spacer() // Add spacing between buttons
                
                // Next Button
                Button(action: {
                    if currentIndex < poems.count - 1 {
                        currentIndex += 1
                    }
                }, label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.largeTitle)
                        .opacity(0.4)
                })
                .disabled(currentIndex == poems.count - 1)
                .padding()
            }
            
        }
    }
}

#Preview {
    if let poems = CoreDataHelper.getTestPoems() {
        PagePoemView(currentIndex: 1, poems: poems)
    } else {
        EmptyView()
    }
}
