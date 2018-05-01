//
//  SignupStepOneViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"
#import "SignupTypesViewController.h"


@interface PatientStepOneViewController : UIViewController <UITextFieldDelegate,WebHelperDelegate>
{
    BOOL userNameChecked;
    
    IBOutlet FontLabel *step1L;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *emailTF, *lastNameTF, *usernameTF, *firstNameTF;
    
    IBOutlet UIView *firstNameV, *lastNameV, *emailV, *userNameV, *TFContainer, *StepsContainer;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;


- (IBAction)navBack;

- (IBAction)navForward;


@end

