//
//  ScoreListViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/3/25.
//

import Foundation
import CoreData
import Combine

// CoreData 사용 예시 ViewModel
class ScoreListViewModel: ObservableObject {
    @Published var scores: [Item] = []
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchScores()
    }
    
    /// CoreData 에서 Item들을 Fetch
    func fetchScores() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            let fetchedScores = try viewContext.fetch(request)
            self.scores = fetchedScores
        } catch {
            print("🚨Error: Failed to fetch scores: \(error)")
        }
    }
    
    /// 새로운 항목 추가 후 저장하고, 목록 갱신
    func addScore() {
        let newScore = Item(context: viewContext)
        newScore.timestamp = Date()
        saveContext()
        fetchScores()
    }
    
    /// 특정 항목 삭제하고, 목록 갱신
    func deleteItems(offsets: IndexSet) {
        offsets.map { scores[$0] }
            .forEach(viewContext.delete)
        saveContext()
        fetchScores()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("🚨Error: Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
