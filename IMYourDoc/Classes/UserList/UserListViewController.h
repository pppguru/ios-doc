//
//  UserListViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 28/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "UserListCell.h"
#import "FontTextField.h"
#import "GetRosterGrounp.h"

#define LIST_PHYSICIAN   111
#define LIST_PATIENT     222
#define LIST_STAFF       333
#define LIST_GROUP       444


@interface UserListViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, GetRosterGrounpDelegate>
{
    UIRefreshControl *refreshControl;
    
    BOOL loadOnce;
    
    
    IBOutlet FontLabel *secureL;
    
    IBOutlet UITextField *searchTF;
    
    IBOutlet UITableView *listTable;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet NSLayoutConstraint *patViewCenterXConst, *topbarOptionsWidthConst, *grpOptionLeadingConst, *iPadGrpOptionLeadingConst;
    
    IBOutlet UIButton *patientB, *physicianB, *staffB, *addButton,*groupBtn;
}


@property (nonatomic, assign) NSInteger listType;

@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, strong) NSMutableArray *userFilterArr;

@property (nonatomic, strong) NSFetchedResultsController *listFetchResultController;


- (void)refresh;


- (IBAction)navBack;

- (IBAction)addPhysician;

- (IBAction)segmentTap:(UIButton *)sender;


@end

