//
//  CVWrapper.m
//  ChordLululala
//
//  Created by Minhyeok Kim on 5/11/25.
//

#import "CVWrapper.h"

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

@implementation CVWrapper

+ (UIImage *)preprocessScore:(UIImage *)image {
#ifdef __cplusplus
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    cv::Mat gray;
    cv::cvtColor(cvImage, gray, cv::COLOR_BGR2GRAY);
    
    cv::Mat binary;
    cv::threshold(gray, binary, 0, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    return MatToUIImage(binary);
#else
    return image;
#endif
}

+ (NSArray<NSValue *> *)detectStaffRegionsInImage:(UIImage *)image {
#ifdef __cplusplus
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    cv::Mat labels, stats, centroids;
    int cnt = cv::connectedComponentsWithStats(cvImage, labels, stats, centroids);
    
    NSMutableArray *regions = [NSMutableArray array];
    // 배경(0번)은 제외
    for (int i = 1; i < cnt; i++) {
        int x = stats.at<int>(i, cv::CC_STAT_LEFT);
        int y = stats.at<int>(i, cv::CC_STAT_TOP);
        int w = stats.at<int>(i, cv::CC_STAT_WIDTH);
        int h = stats.at<int>(i, cv::CC_STAT_HEIGHT);
        if (w > image.size.width / 3) {
            CGRect rect = CGRectMake(x, y, w, h);
            [regions addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    return regions;
#else
    return @[];
#endif
}

+ (NSArray<NSDictionary *> *)detectStaffLinesInRegionFromMat:(const cv::Mat &)regionMat regionWidth:(CGFloat)regionWidth {
#ifdef __cplusplus
    std::vector<cv::Vec4i> lines;
    // HoughLinesP: 1픽셀 해상도, 1도 단위, 100 임계값, 최소 선 길이: regionWidth * 0.3, 최소 간격 20픽셀
    cv::HoughLinesP(regionMat, lines, 1, CV_PI/180, 100, regionWidth * 0.3, 20);
    
    NSMutableArray *result = [NSMutableArray array];
    for (size_t i = 0; i < lines.size(); i++) {
        cv::Vec4i l = lines[i];
        CGPoint start = CGPointMake(l[0], l[1]);
        CGPoint end = CGPointMake(l[2], l[3]);
        NSDictionary *lineDict = @{@"start": [NSValue valueWithCGPoint:start],
                                   @"end": [NSValue valueWithCGPoint:end]};
        [result addObject:lineDict];
    }
    return result;
#else
    return @[];
#endif
}

+ (UIImage *)removeStaffLinesInStaffRegions:(UIImage *)image {
#ifdef __cplusplus
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    NSArray<NSValue *> *staffRegions = [CVWrapper detectStaffRegionsInImage:image];
    
    for (NSValue *regionValue in staffRegions) {
        CGRect regionRect = [regionValue CGRectValue];
        cv::Rect cvRegion(regionRect.origin.x, regionRect.origin.y, regionRect.size.width, regionRect.size.height);
        cv::Mat regionMat = cvImage(cvRegion);
        
        NSArray<NSDictionary *> *lines = [CVWrapper detectStaffLinesInRegionFromMat:regionMat regionWidth:regionRect.size.width];
        if (lines.count == 0) continue;
        
        CGFloat minY = CGFLOAT_MAX;
        CGFloat maxY = 0;
        for (NSDictionary *line in lines) {
            CGPoint start = [[line objectForKey:@"start"] CGPointValue];
            CGPoint end = [[line objectForKey:@"end"] CGPointValue];
            CGFloat localMin = MIN(start.y, end.y);
            CGFloat localMax = MAX(start.y, end.y);
            if (localMin < minY) minY = localMin;
            if (localMax > maxY) maxY = localMax;
        }
        
        int globalMinY = regionRect.origin.y + minY;
        int globalMaxY = regionRect.origin.y + maxY;
        
        cv::Rect fillRect(regionRect.origin.x, globalMinY, regionRect.size.width, globalMaxY - globalMinY);
        cv::rectangle(cvImage, fillRect, cv::Scalar(0), cv::FILLED);
    }
    
    return MatToUIImage(cvImage);
#else
    return image;
#endif
}

+ (UIImage *)processScore:(UIImage *)image {
    UIImage *preprocessed = [CVWrapper preprocessScore:image];
    UIImage *finalImage = [CVWrapper removeStaffLinesInStaffRegions:preprocessed];
    return finalImage;
}

@end
