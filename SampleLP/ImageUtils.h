//
//  ImageUtils.h
//  Bhero
//
//  Created by Vidhur Voora on 7/24/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/videoio/cap_ios.h>

@interface ImageUtils : NSObject

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+ (cv::Mat)cvMatWithImage:(UIImage *)image;

@end
