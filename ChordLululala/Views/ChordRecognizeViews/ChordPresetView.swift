import SwiftUI

struct ChordPresetView: View {
    let chords: [String]
    let onPlus: () -> Void
    let onSelect: (String) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onPlus) {
                Text("코드 생성 +")
                    .textStyle(.headingMdSemiBold)
                    .foregroundStyle(Color.primaryBaseWhite)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.primaryGray700)
                    .cornerRadius(16)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chords, id: \.self) { chord in
                        Button(action: { onSelect(chord) }) {
                            Text(chord)
                                .textStyle(.headingMdMedium)
                                .foregroundStyle(Color.primaryBaseWhite)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.primaryGray800)
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.trailing, 6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.primaryBaseBlack.opacity(0.85))
        .cornerRadius(22)
        .shadow(color: Color.primaryBaseBlack.opacity(0.2), radius: 12, x: 0, y: 4)
    }
} 