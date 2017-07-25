//
//  VideoCamera.h
//  Bhero
//
//  Created by Vidhur Voora on 7/24/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

#import <opencv2/videoio/cap_ios.h>

@protocol VideoCameraDelegate <CvVideoCameraDelegate>
@end

@interface VideoCamera : CvVideoCamera

- (void)updateOrientation;
- (void)layoutPreviewLayer;

@end
