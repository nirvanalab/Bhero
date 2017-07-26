//
//  CameraViewController.h
//  Bhero
//
//  Created by Vidhur Voora on 7/24/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoCamera.h"
@interface CameraViewController : UIViewController<VideoCameraDelegate>{
    VideoCamera* videoCamera;
    
}
@property (nonatomic, strong) VideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotView;
@property NSString *targetPlate;


@end


