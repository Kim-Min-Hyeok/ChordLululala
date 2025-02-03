//
//  ScoreListView.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/3/25.
//

import SwiftUI
import CoreData

// CoreData 및 router 사용 예시 View
struct ScoreListView: View {
    @StateObject private var viewModel: ScoreListViewModel
    @EnvironmentObject var router: NavigationRouter
    
    // Core Data context를 받아서 ScoreListViewModel의 인스턴스를 생성
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ScoreListViewModel(context: context))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.scores, id: \.objectID) { score in
                Button {
                    if let date = score.timestamp {
                        let timestampString = scoreFormatter.string(from: date)
                        // "detail" 라우트로 push 하며 timestamp 전달
                        router.toNamed("detail", arguments: ["timestamp": timestampString])
                    }
                } label: {
                    if let date = score.timestamp {
                        Text(date, formatter: scoreFormatter)
                    } else {
                        Text("No Date")
                    }
                }
            }
            .onDelete(perform: viewModel.deleteItems)
        }
        .navigationTitle("Score List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: viewModel.addScore) {
                    Label("Add Score", systemImage: "plus")
                }
            }
        }
    }
}

private let scoreFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
