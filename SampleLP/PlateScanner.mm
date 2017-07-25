//
//  PlateScanner.m
//  AlprSample
//
//  Created by Alex on 04/11/15.
//  Copyright © 2015 alpr. All rights reserved.
//

#import "PlateScanner.h"
#import "Plate.h"

#import <openalpr/alpr.h>

@implementation PlateScanner {
    alpr::Alpr* delegate;
}

- (id) init {
    if (self = [super init]) {
        
        delegate = new alpr::Alpr(
                                  [@"us" UTF8String],
                                  [[[NSBundle mainBundle] pathForResource:@"openalpr.conf" ofType:nil] UTF8String],
                                  [[[NSBundle mainBundle] pathForResource:@"runtime_data" ofType:nil] UTF8String]
                                  );
        delegate->setTopN(3);
        
        if (delegate->isLoaded() == false) {
            NSLog(@"Error initializing OpenALPR library");
            delegate = nil;
        }
        if (!delegate) self = nil;
    }
    return self;
    
}

- (void)scanImage:(cv::Mat &)colorImage
        onSuccess:(onPlateScanSuccess)success
        onFailure:(onPlateScanFailure)failure {
    
    static BOOL processing = false;
//    if ( processing ) {
//        return;
//    }
    processing = true;
    if (delegate->isLoaded() == false) {
        NSError *error = [NSError errorWithDomain:@"alpr" code:-100
                                         userInfo:[NSDictionary dictionaryWithObject:@"Error loading OpenALPR" forKey:NSLocalizedDescriptionKey]];
        failure(error);
    }
    
    std::vector<alpr::AlprRegionOfInterest> regionsOfInterest;
    alpr::AlprResults results = delegate->recognize(colorImage.data, (int)colorImage.elemSize(), colorImage.cols, colorImage.rows, regionsOfInterest);
    
    NSMutableArray *bestPlates = [[NSMutableArray alloc]initWithCapacity:results.plates.size()];
    cv::Point p1,p2;
    for (int i = 0; i < results.plates.size(); i++) {
        alpr::AlprPlateResult plateResult = results.plates[i];
        
        alpr::AlprCoordinate point = plateResult.plate_points[0];
        alpr::AlprCoordinate point2 = plateResult.plate_points[2];

        cv::Point p1 = cv::Point(point.x-60,point.y-60);
        cv::Point p2 = cv::Point(point2.x+30,point2.y+30);
        [bestPlates addObject:[[Plate alloc]initWithAlprPlate:&plateResult.bestPlate roiP1:p1 roiP2:p2]];
//                    NSLog(@"---------------------");
//        for ( int i=0; i< 4;i++) {
//            alpr::AlprCoordinate point = plateResult.plate_points[i];
//
//            NSLog(@"Points :%d,%d",point.x,point.y);
//           
//        }
//         NSLog(@"----------------------");
        
    }
    
    success(bestPlates);
    processing = false;
}

@end
