//
//  Plate.h
//  AlprSample
//
//  Created by Alex on 04/11/15.
//  Copyright © 2015 alpr. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <openalpr/alpr.h>
#include <opencv2/videoio/cap_ios.h>

@interface Plate : NSObject

@property NSString *number;
@property float confidence;
@property cv::Point p1;
@property cv::Point p2;

- (id)initWithAlprPlate:(alpr::AlprPlate *)plate;
- (id)initWithAlprPlate:(alpr::AlprPlate *)plate roiP1:(cv::Point)p1 roiP2:(cv::Point)p2;

@end
