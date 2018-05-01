//
//  ForgotPswdStepOneViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FontTextField.h"


@interface ForgotPswdStepOneViewController : UIViewController <UITextFieldDelegate, WebHelperDelegate>
{
    IBOutlet UIScrollView *TFScroll;

    IBOutlet FontTextField *nameTF, *emailTF;
    
    IBOutlet UIView *userNameContainer, *mailContainer;
}


@property (nonatomic) NSMutableDictionary *pwdInfo;


- (IBAction)next;

- (IBAction)navBack;

- (IBAction)step1Method;

- (IBAction)step2Method;

- (IBAction)step3Method;


@end

