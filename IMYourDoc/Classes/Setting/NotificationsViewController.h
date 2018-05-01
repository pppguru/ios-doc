//
//  NotificationsViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 28/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "MessageRingtoneViewController.h"


@interface NotificationsViewController : UIViewController
{
    IBOutlet FontLabel *secureL;
    
    IBOutlet UIImageView *secureIcon;
    
	IBOutlet UISwitch *alertSwitch, *soundSwitch, *vibrateSwitch;
    
    IBOutlet UILabel *vibratL, *soundL, *alertsL, *selectL, *msgNotifyL, *titleL;
}


- (IBAction)navBack;

- (IBAction)messageRingtone;


- (IBAction)switchChange:(UISwitch *)sender;


@end

