//
//  CVWrapper.h
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVWrapper : NSObject

+ (UIImage *)preprocessScore:(UIImage *)image; // 그레이스케일 변환, 이진화(otsu)
+ (UIImage *)processScore:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
