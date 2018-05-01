//
//  PersonalInfoViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"
#import "AutocompletionTableView.h"
#import "HospitalSearchViewController.h"


@interface PersonalInfoViewController : UIViewController < UITextFieldDelegate, HospitalSearchViewControllerDelegate, AutocompletionTableViewDelegate,WebHelperDelegate>
{
    NSString *privacyFlag;
    
    
    BOOL editingDone, fetchingHosp, staffProfile, patientProfile, physicianProfile;
    
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UISwitch *privacySwitch;
    
	IBOutlet UIImageView  *editIconImg, *secureIcon;
    
    IBOutlet FontLabel *secureL, *otherAffL, *primaryAffL;
    
    IBOutlet UIButton *editBtn, *primaryAffBtn, *otherAffBtn;
    
    IBOutlet NSLayoutConstraint *phoneVVerticalConst, *privacyVerticalConst;
	
    IBOutlet UIView *firstNameV, *lastNameV, *secQuesV, *phoneV, *secAnsV, *practiceV, *zipcodeV, *primaryAffV, *otherAffV, *privacyV;
    
    IBOutlet FontTextField *firstNameTF, *lastNameTF, *secQuesTF, *phoneTF, *secAnsTF, *zipcodeTF,  *practiceTF, *jobTitleTF, *desigTF;
    
    IBOutlet UILabel *titleL, *fNameL, *lNameL, *secQuesL, *secAnsL, *jobL, *desgL, *practiceL, *phoneL, *zipL, *primaryL, *otherL, *privateL;
}


@property (nonatomic, assign) BOOL isForStaffProfile;

@property (nonatomic, strong) NSMutableDictionary *primaryAff;

@property (nonatomic, strong) NSMutableArray *otherAff, *practiceType, *jobTitle, *designation;

@property (nonatomic, strong) AutocompletionTableView *autoCompTV, *autoJobCompTV, *autoDesigCompTV;


- (void)saveInfo;

- (void)fetchPersonalProfileStaff;

- (void)fetchPersonalProfilePatient;


- (void)allowEditing:(BOOL)allow;



- (IBAction)navBack;

- (IBAction)editProfile;

- (IBAction)selectPrimaryHospital;

- (IBAction)selectSecondaryHospital;


@end

