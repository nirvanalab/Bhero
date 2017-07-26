//
//  OptInViewController.m
//  Bhero
//
//  Created by Vidhur Voora on 7/26/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

#import "OptInViewController.h"

@interface OptInViewController ()
@property (weak, nonatomic) IBOutlet UIButton *optinBtn;

@end

@implementation OptInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    }

-(void)viewWillAppear:(BOOL)animated {
    self.optinBtn.layer.borderWidth = 2.0f;
    self.optinBtn.layer.cornerRadius = 10.0f;

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
