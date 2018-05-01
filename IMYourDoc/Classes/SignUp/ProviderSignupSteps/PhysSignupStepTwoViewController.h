//
//  PhysSignupStepTwoViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FontTextField.h"


@interface PhysSignupStepTwoViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *step1L;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *pinTF, *emailTF, *phoneTF, *secQuesTF, *secAnsTF;
    
    IBOutlet UIView *createPswdV, *confirmPswdV, *secQuesV, *secAnsV, *TFContainer, *StepsContainer, *pinV, *phoneV, *emailV;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;


- (IBAction)navBack;

- (IBAction)navForward;


@end

