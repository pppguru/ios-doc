//
//  SearchStaffViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"
#import "AutocompletionTableView.h"

@interface SearchStaffViewController : UIViewController <UITextFieldDelegate, WebHelperDelegate,AutocompletionTableViewDelegate>
{
    BOOL fetchingHospital;
    
    NSDictionary *searchDict;
    
    IBOutlet UILabel *anyOneL, *titleL;
    
    IBOutlet FontLabel *secureL;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UIImageView *secureIcon;

    IBOutlet FontTextField *staffNameTF, *hospitalTF, *providerIdTF , *txt_userName;;
    
    IBOutlet UIView *staffNameV, *hospitalV, *providerV, *TxtFieldContainer;
}

@property (nonatomic, strong) AutocompletionTableView *autoCompTV;
@property (strong, nonatomic) NSMutableArray *arr_practiceType;

@property (strong, nonatomic) NSMutableDictionary *hospital;


- (IBAction)navBack;

- (IBAction)hospitalTap;

- (IBAction)searchStaff;


@end

