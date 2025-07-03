//
//  ChordAddingModalViewModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/28/25.
//

import SwiftUI

final class ChordAddingModalViewModel: ObservableObject {
    @Published var chord: String = ""
    
    private var undoStack: [String] = []
    private var redoStack: [String] = []
    
    func setInitialChord(_ value: String) {
        chord = value
        undoStack = [""]
        redoStack = []
    }
    
    func append(_ value: String) {
        undoStack.append(chord)
        redoStack.removeAll()
        chord += value
    }
    
    func undo() {
        guard let last = undoStack.popLast() else { return }
        redoStack.append(chord)
        chord = last
    }
    
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(chord)
        chord = next
    }
    
    func isValidChord(_ text: String) -> Bool {
        if text.isEmpty { return true }
        
        let baseChordParsingRegex = #"^([A-G](?:#|b)?)(maj|m|sus2|sus4|5|aug|dim|7)?"#
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: baseChordParsingRegex, options: [])
        } catch {
            print("Regex compilation failed: \(error)")
            return false
        }
        
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange) else {
            return false
        }
        
        var baseQuality: String = ""
        if match.numberOfRanges > 2 && match.range(at: 2).location != NSNotFound {
            baseQuality = (text as NSString).substring(with: match.range(at: 2))
        }
        
        var determinedChordType: String
        
        // 특수 코드 타입 (maj7, m7b5, dim7)을 유추하거나 명확히 지정
        if text.contains("maj7") {
            determinedChordType = "maj7"
        } else if text.contains("m7b5") {
            determinedChordType = "m7b5"
        } else if text.contains("dim7") {
            determinedChordType = "dim7"
        } else if baseQuality == "7" {
            determinedChordType = "seven" // Dom7
        } else if baseQuality.isEmpty {
            determinedChordType = "maj" // "C"와 같이 루트만 있는 경우 기본 major로 간주
        } else {
            determinedChordType = baseQuality // 'm', 'sus2', 'aug' 등 기본 퀄리티
        }
        
        // 전체 정규식 패턴 정의
        let patterns: [String:String] = [
                   // Major 계열 (maj, maj7)
                   // 'maj'는 'C'와 같이 기본적으로 major를 의미하거나 'Cmaj'일 경우
                   // 'maj7'은 'Cmaj7'처럼 명시된 경우. 여기서 11 텐션 제외.
                   "maj":    #"^[A-G](?:#|b)?(?:maj)?(?:(?:(?:add)?(?:2|4|6|9|#11|13|b5|#5|b9|#9)))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   "maj7":   #"^[A-G](?:#|b)?maj7(?:(?:add)?(?:9|#11|13))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   
                   // Dominant 7 (7/Dom7): 모든 텐션 허용
                   "seven":  #"^[A-G](?:#|b)?7(?:(?:(?:add)?(?:2|4|5|6|9|11|13|b5|#5|b9|#9|b11|#11|b13)))*(?:/(?:[A-G](?:#|♭)?))?$"#,
                   
                   // Minor 계열 (m, m7, m7b5)
                   "m":      #"^[A-G](?:#|b)?m(?:(?:(?:add)?(?:2|4|5|6|7|9|11|13|b5|#5|b9|#9|b11|#11|b13)))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   "m7":     #"^[A-G](?:#|b)?m7(?:(?:add)?(?:9|11|13))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   "m7b5":   #"^[A-G](?:#|b)?m7b5(?:(?:add)?(?:9|11|b13))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   
                   // Diminished 계열 (dim, dim7)
                   "dim":    #"^[A-G](?:#|b)?dim(?:(?:(?:add)?(?:2|4|5|6|7|9|11|13|b5|#5|b9|#9|b11|#11|b13)))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   "dim7":   #"^[A-G](?:#|b)?dim7(?:(?:add)?(?:9|11))*(?:/(?:[A-G](?:#|b)?))?$"#,

                   // Sus2, Sus4, Power (5), Augmented
                   // 이들은 표에 명시된 금지 텐션이 없으므로 비교적 넓게 허용.
                   "sus2":   #"^[A-G](?:#|b)?sus2(?:(?:(?:add)?(?:4|5|6|7|9|11|13|b5|#5|b9|#9|b11|#11|b13)))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   "sus4":   #"^[A-G](?:#|b)?sus4(?:(?:(?:add)?(?:2|5|6|7|9|11|13|b5|#5|b9|#9|b11|#11|b13)))*(?:/(?:[A-G](?:#|b)?))?$"#,
                   "5":      #"^[A-G](?:#|b)?5(?:/(?:[A-G](?:#|b)?))?$"#,
                   "aug":    #"^[A-G](?:#|b)?aug(?:(?:(?:add)?(?:2|4|5|6|7|9|11|13|b5|#5|b9|#9|b11|#11|b13)))*(?:/(?:[A-G](?:#|b)?))?$"#
               ]
        
        // 결정된 코드 타입에 해당하는 패턴을 가져와서 전체 텍스트와 매칭
        guard let pattern = patterns[determinedChordType] else {
            //이상한 코드 타입이 결정되면 false
            return false
        }
        
        return text.range(of: pattern, options: .regularExpression) != nil
    }
}


