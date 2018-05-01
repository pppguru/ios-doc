//
//  ChangePasswordViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FontTextField.h"


@interface ChangePasswordViewController : UIViewController <UITextFieldDelegate,WebHelperDelegate>
{
    CGRect keyBoardFrame;
    
    IBOutlet UILabel *ttitleL;
    
    IBOutlet UIScrollView *TFScroll;

    IBOutlet UIView *oldPassV, *newPassV, *confirmPassV;
    
    IBOutlet FontTextField *oldPassTF, *newPassTF, *confirmPassTF;
}


- (IBAction)navBack;

- (IBAction)savePassword;


@end

