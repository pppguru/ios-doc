//
//  ForgotPswdStepThreeViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FontTextField.h"


@interface ForgotPswdStepThreeViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, WebHelperDelegate>
{
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UIView *newPwdV, *confirmPwdV;
    
    IBOutlet FontTextField *newPwdTF, *confirmPwdTF;
}


@property (nonatomic) NSMutableDictionary *pwdInfo;



- (IBAction)submit;

- (IBAction)navBack;

- (IBAction)step1Method;

- (IBAction)step2Method;

- (IBAction)step3Method;


@end

