//
//  Date.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 3/26/25.
//

import Foundation

extension Date {
    func dateFormatForGrid() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func dateFormatForList() -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "a h:mm" // 오전/오후 h:mm
            
            let calendar = Calendar.current
            if calendar.isDateInToday(self) {
                return "오늘 " + formatter.string(from: self)
            } else {
                // 오늘이 아니라면 날짜 + 시간
                formatter.dateFormat = "yyyy. M. d. a h:mm"
                return formatter.string(from: self)
            }
        }
}
