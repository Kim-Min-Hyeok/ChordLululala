import SwiftUI

struct ChordPresetView: View {
    let chords: [String]
    let onPlus: () -> Void
    let onSelect: (String) -> Void
    
    var body: some View {
        HStack(spacing: 11) {
            Button(action: onPlus) {
                Text("코드 생성 +")
                    .textStyle(.headingMdMedium)
                    .foregroundStyle(Color.primaryGray800)
                    .frame(width: 92, height: 37)
                    .background(Color.primaryGray100)
                    .clipShape(RoundedRectangle(cornerRadius: 200))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(chords, id: \.self) { chord in
                        Button(action: { onSelect(chord) }) {
                            Text(chord)
                                .textStyle(.headingMdMedium)
                                .foregroundStyle(Color.primaryBaseWhite)
                                .frame(width: 37, height: 37)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.primaryBaseWhite.opacity(0.2), lineWidth: 1)
                                )
                                .clipShape(Circle())
                        }
                    }
                    if chords.count < 6 {
                        Button(action: onPlus) {
                            Circle()
                                .fill(Color.primaryBaseWhite.opacity(0.04))
                                .frame(width: 37, height: 37)
                                .overlay(
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                        .foregroundStyle(Color.primaryBaseWhite.opacity(0.2))
                                )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.primaryGray700)
        .cornerRadius(200)
    }
} 