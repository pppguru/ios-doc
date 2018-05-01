//
//  ViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 15/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SimpleFontButton.h"
#import "DeviceRegistrationViewController.h"


@interface LoginViewController : UIViewController<WebHelperDelegate>
{
    CGRect keyBRect;
    
    IBOutlet UIScrollView *scrollV;
    
    IBOutlet UIView *scrollView;
    
    IBOutlet UIButton *helpBtn, *forgotBtn;
    
    IBOutlet SimpleFontButton *rememberBtn;
    
    IBOutlet IMYourDocButton *loginBtn, *signupBtn;
    
    IBOutlet FontTextField *passwordTF, *userNameTF;
    
    IBOutlet NSLayoutConstraint *profileHeight, *userNameTopSpaceConst, *rememberTopSpaceConst, *logionTopSpaceConst, *needHelpTopConst;
}


- (void) loginReqest;

- (void) showDeviceRegistrationStatus;

- (void) setUsernameAndPassWordAsEmpty;


- (IBAction)userHelp;

- (IBAction)userLogin;

- (IBAction)userSignUp;

- (IBAction)rememberTap;

- (IBAction)forgotPassword;


@end

