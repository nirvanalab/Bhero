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

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property PlateScanner *plateScanner;
@property (strong, nonatomic) NSMutableArray *plates;
@property (weak, nonatomic) IBOutlet UITableView *plateTableView;
@property (weak, nonatomic) IBOutlet UIView *foundMatchView;
@property (weak, nonatomic) IBOutlet UIView *summaryView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;
@property (weak, nonatomic) IBOutlet UILabel *foundVehicleLP;
@property (weak, nonatomic) IBOutlet UILabel *foundVehicleLocation;

@property UIImage *snappedImage;

@property (weak, nonatomic) IBOutlet UILabel *snapshotViewTitle;

@property BOOL didResponseReceived;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UIImageView *toastImageView;
@property (weak, nonatomic) IBOutlet UILabel *toastContent;


@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.targetPlate = @"7TTT048";
    
   self.ref = [[FIRDatabase database] reference];
    [self monitorDataUpdate];
    
    self.cameraView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.cameraView.layer.borderWidth = 5.0f;
    self.cameraView.layer.cornerRadius = 4.0f;
    
    self.snapshotView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.snapshotView.layer.borderWidth = 5.0f;
    self.snapshotView.layer.cornerRadius = 4.0f;
    
    // Do any additional setup after loading the view, typically from a nib.
    videoCamera = [[VideoCamera alloc] initWithParentView:nil];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    videoCamera.defaultAVCaptureVideoOrientation =  AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 30;
    
    // videoCamera.grayscaleMode = true;
    [videoCamera start];//to start camera previewsna
    
    self.plateScanner = [[PlateScanner alloc] init];
    self.plates = [NSMutableArray arrayWithCapacity:0];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     self.foundMatchView.frame = CGRectMake(self.foundMatchView.frame.origin.x, self.view.frame.size.height+self.foundMatchView.frame.size.height, self.foundMatchView.frame.size.width, self.foundMatchView.frame.size.height);
    
    self.summaryView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.summaryView.layer.borderWidth = 3.0f;
    self.summaryView.layer.cornerRadius = 5.0f;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCongratulateToast:(NSString *)msg {
    
    self.toastImageView.image = [UIImage imageNamed:@"medal.png"];
    self.toastContent.text = @"You got a message!";
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.foundMatchView setHidden:NO];
    }];
    
    self.snapshotViewTitle.text = @"Congrats!!";
    self.snapshotImageView.image = [UIImage imageNamed:@"medal.png"];
    self.foundVehicleLP.text = msg;
    
    
    self.didResponseReceived = YES;
    
}

- (void)monitorDataUpdate {
    
    
    [self.ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *msg = snapshot.value;
        if ( [msg isKindOfClass:[NSString class]] && msg!= nil && [snapshot.key isEqualToString:@"congrats"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showCongratulateToast:msg];
//                UIAlertController *alert = [UIAlertController
//                                            alertControllerWithTitle:@"Message from bureau"
//                                            message:msg
//                                            preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction* yesButton = [UIAlertAction
//                                            actionWithTitle:@"OK"
//                                            style:UIAlertActionStyleDefault
//                                            handler:^(UIAlertAction * action) {
//                                                [alert dismissViewControllerAnimated:YES completion:nil];
//                                            }];
//                
//                [alert addAction:yesButton];
//                [self presentViewController:alert animated:YES completion:nil];
//
                
                
            });
            
        }
        
        
    }];
    
}

- (void)showFoundAlert {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.foundMatchView setHidden:NO];
        self.foundMatchView.frame = CGRectMake(self.foundMatchView.frame.origin.x, self.view.frame.size.height-self.foundMatchView.frame.size.height, self.foundMatchView.frame.size.width, self.foundMatchView.frame.size.height);
    }];
}
- (IBAction)showSummaryView:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.foundMatchView setHidden:YES];
    }];
    
    if ( !self.didResponseReceived ) {
         self.snapshotImageView.image = self.snappedImage;
    }
   
    [UIView animateWithDuration:0.5 animations:^{
        [self.summaryView setHidden:NO];
    }];

}
- (IBAction)dismissSummaryView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        [self.summaryView setHidden:YES];
    }];
}

- (IBAction)closeBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)processImage:(cv::Mat&)image
{
    [self doProcess:image];return;
    
}

- (void)doProcess:(cv::Mat&)image
{
    static int ctr = 0;
    __block Mat myImage = image.clone();
    __block cv::Mat rgbImage;
    cv::cvtColor(image, rgbImage, CV_BGR2RGB);
    __block BOOL found = false;
    [self.plateScanner
     scanImage: rgbImage
     onSuccess:^(NSArray * results) {
         if ( [results count] > 0 ) {
             NSLog(@"Successss!!!!!");
             
             for ( Plate *plate in results ) {
                 NSString *plateNumber = [plate.number lowercaseString];
                 NSLog(@"Plate Number: %@",plateNumber);
                 NSString *targetPlateLower = [self.targetPlate lowercaseString];
                 if ( [plateNumber isEqualToString:targetPlateLower] ||
                     [targetPlateLower containsString:plateNumber]
                     || [plateNumber containsString:@"tt"]) {
                     found = true;
                     cv::rectangle(rgbImage,plate.p1,plate.p2,cv::Scalar(255, 0, 0),5);
                     break;
                 }
                 
                 cv::rectangle(rgbImage,plate.p1,plate.p2,cv::Scalar(0, 255, 0),5);
                 //cv::line(rgbImage,cv::Point(0,0),cv::Point(300,300),cv::Scalar(0,0,255),5);
             }
             
             
             if ( found ) {
                 
                 //upload file
                 UIImage *myImage = [ImageUtils UIImageFromCVMat:rgbImage];
                 [self uploadFile:myImage];
                
                 self.snappedImage = myImage;
                 
             }

         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             UIImage *myImage = [ImageUtils UIImageFromCVMat:rgbImage];
             [self.snapshotView setImage:myImage];
             
             if ( found ) {
                  [self showFoundAlert];
                 self.foundVehicleLP.text = [NSString stringWithFormat:@"Vehicle LP: %@ \n Location: 37.776,-122.417",self.targetPlate];
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
    
}

- (void)uploadFile:(UIImage *)image {
    static int ctr = 0;
    NSString *name = [NSString stringWithFormat:@"Img%d.jpg",ctr++];
    NSString *path = [NSString stringWithFormat:@"Demo/%@",name];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    NSString *location = @"37.7769022,-122.4177054";
    NSDictionary *metadata = @{
                               @"user": @"BheroTest007"
                               ,@"time": dateString
                               ,@"location": location
                               };
    [FirebaseUploadUtil uploadFile:image path:path metaData:metadata];
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
    if ( self.targetPlate != nil && [self.targetPlate isEqualToString:[plate number]]) {
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:165/255 blue:0 alpha:1.0];
        cell.imageView.image = [UIImage imageNamed:@"alertIcon.png"];
        cell.detailTextLabel.text = @"Match";
    }
    else {
        cell.backgroundColor = [UIColor greenColor];
        cell.imageView.image = [UIImage imageNamed:@"checkIcon.png"];
        cell.detailTextLabel.text = @"No Match";
        
    }
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
