//
//  SearchViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 09/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontHeaderLabel.h"


@interface SearchViewController : UIViewController <WebHelperDelegate>
{
    int counter;

    IBOutlet FontLabel *secureL;
    
    IBOutlet UITableView *searchTB;

    IBOutlet UIImageView *secureIcon;
    
    IBOutlet FontHeaderLabel *statusL;
}


@property (nonatomic, assign) int searchType;               // 1 = Physician, 2 = Staff, 3 = Patient

@property (nonatomic, strong) NSMutableArray *searchArr;

@property (nonatomic, strong) NSMutableDictionary *searchParam;


- (IBAction)backTap;


@end

