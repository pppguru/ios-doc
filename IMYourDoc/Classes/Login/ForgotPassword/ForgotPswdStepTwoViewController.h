//
//  ForgotPswdStepTwoViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "FontTextField.h"


@interface ForgotPswdStepTwoViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet FontLabel *secQuesLbl, *secQuesL;

    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *secAnsTF;
    
    IBOutlet UIView *secAnsContainer;
}


@property (nonatomic) NSMutableDictionary *pwdInfo;

@property (nonatomic) NSString *secQuesStrg, *secAnsStrg;


- (IBAction)next;

- (IBAction)navBack;

- (IBAction)step1Method;

- (IBAction)step2Method;

- (IBAction)step3Method;


@end

