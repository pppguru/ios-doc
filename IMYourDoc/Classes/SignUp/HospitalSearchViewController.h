//
//  HospitalSearchViewController.h
//  IMYourDoc
//
//  Created by Harminder on 03/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SimpleFontButton.h"


typedef enum : NSUInteger {
    HospitalSelectionModeSingle,
    HospitalSelectionModeMultiple,
    
} HospitalSelectionMode;


@class HospitalSearchViewController;


@protocol HospitalSearchViewControllerDelegate <NSObject>


@optional


- (void)HospitalController:(HospitalSearchViewController *)controller selectedHosptials:(NSMutableArray *)selectedHosps;


- (NSMutableArray *)selectedHospitals:(HospitalSearchViewController *)controller;


@end


@interface HospitalSearchViewController : UIViewController <UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate,WebHelperDelegate>
{
    BOOL addNetwork;
    
    IBOutlet UILabel *titleL, *searchInstructionL;
    
    IBOutlet UITableView *hosptableView;
    
    IBOutlet SimpleFontButton *tickBtn;
    
    IBOutlet UIButton *backBtn;
    
    IBOutlet NSLayoutConstraint  *addNetworkIconWConst;
}

@property (nonatomic,assign)    BOOL addNetwork;

@property (nonatomic, assign) BOOL fromSearch;

@property (nonatomic, assign) HospitalSelectionMode hospitalSelectionMode;

@property (nonatomic, strong) NSMutableArray *searchedArray, *selectedArray;

@property (nonatomic, strong) id <HospitalSearchViewControllerDelegate> delegate;


- (IBAction)addTap;

- (IBAction)doneTap;
- (IBAction)action_back:(id)sender;

@end

