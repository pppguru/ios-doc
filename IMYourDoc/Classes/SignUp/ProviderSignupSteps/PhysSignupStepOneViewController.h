//
//  PhysSingupStepOneViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"


@interface PhysSignupStepOneViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet FontLabel *step1L;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UIView *firstNameV, *lastNameV, *createPswdV, *confirmPswdV,  *userNameV, *TFContainer, *stepsContainer;
    
    IBOutlet FontTextField *firstNameTF, *lastNameTF, *confirmPswdTF, *createPswdTF, *userNameTF;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;


- (IBAction)navBack;

- (IBAction)navForward;


@end





















