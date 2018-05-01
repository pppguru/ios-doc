//
//  ResetPasswordViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>


#import "AppDelegate.h"
#import "FontLabel.h"
#import "FontTextField.h"
#import "FontHeaderLabel.h"
#import "ResetPinStepTwoViewController.h"


@interface ResetPinViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UILabel *titleL;
    
    IBOutlet FontTextField *secAnsTF;
    
    IBOutlet UIView *secQuesV, *secAnsV;

    IBOutlet FontLabel *secQuesLbl, *secQuesL;
}


@property (nonatomic, strong) IBOutlet FontHeaderLabel *topL;


- (IBAction)navBack;

- (IBAction)forwardTap;


@end

