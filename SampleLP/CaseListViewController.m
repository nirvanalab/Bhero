//
//  CaseListViewController.m
//  SampleLP
//
//  Created by Vidhur Voora on 7/25/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

@import FirebaseDatabase;
@import FirebaseCore;
@import FirebaseStorage;

#import "CaseListViewController.h"

@interface CaseListViewController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property NSDictionary *content;
@property NSDictionary *msgContent;
@end

@implementation CaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
}


- (void)monitorDataUpdate {
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.content = snapshot.value;
        NSLog(@"%@",self.content);
        NSLog(@"%@",self.content[@"Case1"]);
    }];
    
    [self.ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *msg = snapshot.value;
        if ( [msg isKindOfClass:[NSString class]] && msg!= nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"Message from bureau"
                                            message:msg
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
        
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
