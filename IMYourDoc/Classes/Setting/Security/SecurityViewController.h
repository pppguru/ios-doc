//
//  SecurityViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "ResetPinViewController.h"
#import "ChangePasswordViewController.h"
#import "ChangeSecurityQuestionViewController.h"

@interface SecurityViewController : UIViewController
{
    IBOutlet UILabel *titleL, *changePassL, *changePinL;
}


- (IBAction)backTap;

- (IBAction)resetPin;

- (IBAction)changePassword;
- (IBAction)changeSecurityQuestionAndAnser;


@end

