//
//  ResetPinStepTwoVC.h
//  IMYourDoc
//
//  Created by Sarvjeet on 17/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FontTextField.h"


@interface ResetPinStepTwoViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate,WebHelperDelegate>
{
    IBOutlet UILabel *titleL;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *oldPinTF, *newPinTF, *confirmPinTF;
}


- (IBAction)saveTap;


@end

