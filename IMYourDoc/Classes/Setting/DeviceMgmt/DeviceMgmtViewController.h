//
//  DeviceMgmtViewController.h
//  IMYourDoc
//
//  Created by Manpreet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SimpleFontButton.h"


@interface DeviceMgmtViewController : UIViewController
{
    IBOutlet UILabel *titleL;
    
    IBOutlet SimpleFontButton *registerBtn, *blockedBtn;
}


- (IBAction)backTap;

- (IBAction)deviceMgmtTap:(UIButton *)sender;


@end

