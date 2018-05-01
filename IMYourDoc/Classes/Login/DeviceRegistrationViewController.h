//
//  DeviceRegistrationViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"


@interface DeviceRegistrationViewController : UIViewController <UITextFieldDelegate, WebHelperDelegate>
{
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UILabel *titleLbl;

    IBOutlet FontTextField *deviceNameTF;
}


- (IBAction)registerDevice;


@end

