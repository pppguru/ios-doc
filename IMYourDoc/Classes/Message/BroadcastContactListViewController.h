//
//  BroadcastContactListViewController.h
//  IMYourDoc
//
//  Created by OSX on 17/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "AppDelegate.h"
#import "ImYouDocViewController.h"
#import "Broadcast_ContactListCell.h"

#import "BroadCastSelectAllHeaderView.h"


#import "EditNameObjectClass.h"

@interface BroadcastContactListViewController : ImYouDocViewController<UITableViewDataSource,UITableViewDataSource,UISearchBarDelegate>
{
     // •••••• StatusBarContainer
    
    IBOutlet UIButton *btn_RightTop;
        // •••••• TableviewContainer
    __weak IBOutlet UISearchBar *searchBar_Contact;
    IBOutlet UITableView *tableview_contctLst;
}
    // •••••• StatusBarContainer
- (IBAction)action_createList:(id)sender;

//••••••••••••• 
@property (nonatomic, copy) void (^callBackBlock)(NSArray*arr_jids,NSString*str_groupName);


@property (strong, nonatomic) IBOutlet EditNameObjectClass *editNameObject;

@end
