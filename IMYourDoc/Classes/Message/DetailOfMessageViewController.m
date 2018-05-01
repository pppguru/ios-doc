//
//  DetailOfMessageViewController.m
//  IMYourDoc
//
//  Created by OSX on 22/01/16.
//  Copyright (c) 2016 Sarvjeet. All rights reserved.
//

#import "DetailOfMessageViewController.h"

@interface DetailOfMessageViewController ()

@end

@implementation DetailOfMessageViewController
@synthesize chatMessage;
@synthesize txt_detialOfCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    txt_detialOfCell.text = [NSString stringWithFormat:@"%@",chatMessage.description];
    
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
