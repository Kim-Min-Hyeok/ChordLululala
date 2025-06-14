//
//  UIImage.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/11/25.
//

extension UIImage {
    /// degrees 단위로 회전된 새로운 UIImage 반환
    func rotated(byDegrees degrees: CGFloat) -> UIImage {
        let radians = degrees * .pi / 180
        // 회전된 그림이 들어갈 크기 계산
        let newRect = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        // 좌표계 이동 및 회전
        ctx.translateBy(x: newRect.width/2, y: newRect.height/2)
        ctx.rotate(by: radians)
        draw(in: CGRect(
            x: -size.width/2,
            y: -size.height/2,
            width: size.width,
            height: size.height
        ))
        let rotated = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return rotated
    }
}
