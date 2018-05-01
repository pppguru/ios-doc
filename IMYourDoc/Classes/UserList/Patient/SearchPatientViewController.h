//
//  SearchPatientViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"


@interface SearchPatientViewController : UIViewController <UITextFieldDelegate, WebHelperDelegate>
{
    NSDictionary *searchDict;
    
    IBOutlet UILabel *titleL;

    IBOutlet FontLabel *secureL;
    
    IBOutlet UIScrollView *TFScroll;

    IBOutlet UIImageView *secureIcon;
    
    IBOutlet FontTextField *patientNameTF, *txt_userName;
}



- (IBAction)navBack;

- (IBAction)searchPatient;


@end

