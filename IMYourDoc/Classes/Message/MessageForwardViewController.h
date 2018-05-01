//
//  MessageForwardViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 16/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "UserListCell.h"
#import "FontTextField.h"
#import "GetRosterGrounp.h"
#import "IMYourDocButton.h"
#import "FontSegmentedControl.h"


@interface MessageForwardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, GetRosterGrounpDelegate>
{
    IBOutlet UIView *searchSV;
    
    IBOutlet FontLabel *secureLabel;
    
    IBOutlet FontTextField *searchTF;
    
    UIRefreshControl *refreshControl;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet UITableView *searchTable;
    
    IBOutlet UISegmentedControl *segmentBtn;

    IBOutlet IMYourDocButton *usersBtn, *groupsBtn;
}


@property (nonatomic) BOOL forChat, isGroupChat;

@property (nonatomic, strong) ChatMessage *forwardMessage;

@property (nonatomic, strong) NSMutableArray *userFilterArr;

@property (nonatomic, strong) NSFetchedResultsController *listFetchResultController, *roomFetchController;


- (void)refresh;


@end

