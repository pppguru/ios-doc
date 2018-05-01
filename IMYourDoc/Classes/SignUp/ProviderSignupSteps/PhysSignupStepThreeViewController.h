//
//  PhysSignupStepThreeViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"


@interface PhysSignupStepThreeViewController : UIViewController <UITextFieldDelegate>
{
    BOOL fetchingHospital;

    IBOutlet UILabel *step1L;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *npiTF, *primaryHospTF, *zipcodeTF, *secondaryHospTF;
    
    IBOutlet UIView *phoneV, *pincodeV, *zipcodeV, *TFContainer, *StepsContainer, *primaryHospV, *secondaryHospV, *npiV;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo, *hospital;

@property (nonatomic, assign) RegistrationType registrationType;

@property (nonatomic, strong) NSMutableArray *secondryHosp;


- (IBAction)navBack;

- (IBAction)navForward;

- (IBAction)selectPrimaryHospital;

- (IBAction)selectSecondaryHospital;



@end

