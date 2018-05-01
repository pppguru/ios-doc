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


@interface SignupStepTwoViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet FontLabel *step1L;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet NSLayoutConstraint *passwordVTopConst, *propHTOfPwdVConst;
    
    IBOutlet FontTextField *passwordTF, *pinTF, *confirmPassTF, *securityAnsTF, *securityQuesTF, *npiTF;
    
    IBOutlet UIView *pinV, *passwordV, *secQuesV, *secAnsV, *confirmPassV, *npiV, *TFContainer, *StepsContainer, *mainContainer;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;


- (IBAction)navBack;

- (IBAction)navForward;


@end

