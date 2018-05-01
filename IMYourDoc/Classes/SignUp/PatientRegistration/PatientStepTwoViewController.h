//
//  SignupStepTwoViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>


#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"


@interface PatientStepTwoViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet FontLabel *step1L;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *passwordTF, *confirmPassTF, *securityAnsTF, *securityQuesTF;
    
    IBOutlet UIView *pwdV, *confirmPwdV, *secQuesV, *secAnsV, *TFContainer, *StepsContainer;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;


- (IBAction)navBack;

- (IBAction)navForward;


@end

