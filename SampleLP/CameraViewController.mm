//
//  CameraViewController.m
//  Bhero
//
//  Created by Vidhur Voora on 7/24/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

#import "CameraViewController.h"
#import "PlateScanner.h"
#import "Plate.h"
#import "ImageUtils.h"
#import "FirebaseUploadUtil.h"

#import <opencv2/videoio/cap_ios.h>

#import <opencv2/imgproc.hpp>

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property PlateScanner *plateScanner;
@property (strong, nonatomic) NSMutableArray *plates;
@property (weak, nonatomic) IBOutlet UITableView *plateTableView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    videoCamera = [[VideoCamera alloc] initWithParentView:_cameraView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    videoCamera.defaultAVCaptureVideoOrientation =  AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 30;
    
   // videoCamera.grayscaleMode = true;
    [videoCamera start];//to start camera preview
    
    self.plateScanner = [[PlateScanner alloc] init];
    self.plates = [NSMutableArray arrayWithCapacity:0];

    
//    cv::VideoCapture capture;
//    NSString* pathToInputFile =[[NSBundle mainBundle] pathForResource:@"Carvideo" ofType:@"mp4"];
//    if(capture.open(std::string([pathToInputFile UTF8String]))){
//            for(int i=0;i<10000;i++)
//            {
//                Mat frame;
//                capture >> frame; // get a new frame from camera
//                [self processImage:frame];
//               // [NSThread sleepForTimeInterval:100];
//        
//            }
//    }else{
//        NSLog(@"Failed to open");
//    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processImage:(cv::Mat&)image
{
    //process here
    static int i = 0;
    if ( i == 3 ) {
        i = 0;
        [self doProcess:image];return;
        __block cv::Mat rgbImage;
        cv::cvtColor(image, rgbImage, CV_BGR2RGB);

//        UIImage *myImage = [ImageUtils UIImageFromCVMat:rgbImage];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.snapshotView setImage:myImage];
//        });
//        
         //cv::Mat myMat = [ImageUtils cvMatWithImage:myImage];
        
        //process 1  in 10 frames
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self.plateScanner
             scanImage: rgbImage
             onSuccess:^(NSArray * results) {
                 if ( [results count] > 0 ) {
                     NSLog(@"Successss!!!!!");
                     for ( Plate *plate in results ) {
                         [self.plates insertObject:plate atIndex:0];
                         
                         cv::rectangle(rgbImage,plate.p1,plate.p2,cv::Scalar(0, 255, 0),15);
                         //cv::line(rgbImage,cv::Point(0,0),cv::Point(300,300),cv::Scalar(0,0,255),5);
                         
                         //[self.plates addObjectsFromArray:results];
                         
                     }
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if ( [results count] > 0 ) {
                         UIImage *myImage = [ImageUtils UIImageFromCVMat:rgbImage];
                         [self.snapshotView setImage:myImage];
                         [self.plateTableView reloadData];
                     }
                    
                 });
                 
             }
             onFailure:^(NSError * error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"Error: %@", [error localizedDescription]);
                     [self showErrorDialogWithTitle:@"Error with scan."
                                            message:[NSString stringWithFormat:@"Unable to process license plate image: %@", [error localizedDescription]]];
                 });
             }];
        //});

        
    }
    i++;
}

- (void)doProcess:(cv::Mat&)image
{
    static int ctr = 0;
    __block Mat myImage = image.clone();
    __block cv::Mat rgbImage;
    cv::cvtColor(image, rgbImage, CV_BGR2RGB);
 //   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        
        
        
        [self.plateScanner
         scanImage: rgbImage
         onSuccess:^(NSArray * results) {
             if ( [results count] > 0 ) {
                 NSLog(@"Successss!!!!!");
                 for ( Plate *plate in results ) {
                     [self.plates insertObject:plate atIndex:0];
                    
                     cv::rectangle(rgbImage,plate.p1,plate.p2,cv::Scalar(0, 255, 0),15);
                     //cv::line(rgbImage,cv::Point(0,0),cv::Point(300,300),cv::Scalar(0,0,255),5);
                 }
                 
                 //upload file
                 UIImage *myImage = [ImageUtils UIImageFromCVMat:rgbImage];
                 NSString *name = [NSString stringWithFormat:@"Img%d.jpg",ctr++];
                 NSString *path = [NSString stringWithFormat:@"Test/%@",name];
                 NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                       dateStyle:NSDateFormatterShortStyle
                                                                       timeStyle:NSDateFormatterFullStyle];
                 
                 NSDictionary *metadata = @{
                                            @"user": @"BheroTest007"
                                            ,@"time": dateString
                                            };
                 [FirebaseUploadUtil uploadFile:myImage path:path metaData:metadata];
                 
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ( [results count] > 0 ) {
                     UIImage *myImage = [ImageUtils UIImageFromCVMat:rgbImage];
                     [self.snapshotView setImage:myImage];
                     [self.plateTableView reloadData];
                 }
                 
             });
             
         }
         onFailure:^(NSError * error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Error: %@", [error localizedDescription]);
                 [self showErrorDialogWithTitle:@"Error with scan."
                                        message:[NSString stringWithFormat:@"Unable to process license plate image: %@", [error localizedDescription]]];
             });
         }];
  //  });
}

#pragma mark table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.plates.count;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Scan Results";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Plate *plate = self.plates[indexPath.row];
    cell.textLabel.text = [plate number];
    return cell;
}

#pragma mark error

- (void)showErrorDialogWithTitle:(NSString *)title
                         message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    });
}


@end
