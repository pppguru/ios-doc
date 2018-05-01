//
//  GroupProfileViewController.h
//  IMYourDoc
//
//  Created by OSX on 27/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"
#import "SimpleFontButton.h"

@interface GroupProfileViewController : ImYouDocViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,WebHelperDelegate>
{
    
}
@property (strong, nonatomic) IBOutlet ImageViewAsincLoader *imageView_GroupImage;

@property (strong, nonatomic) IBOutlet UITextField *txt_GroupName;
- (IBAction)action_EditGroupName:(id)sender;

- (IBAction)titleChanged:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btn_EditGroupName;
@property (strong, nonatomic) IBOutlet UITableView *table_members;
@property (strong, nonatomic) IBOutlet SimpleFontButton *btn_LeaveOrDelete;
- (IBAction)action_LeaveORDeleteGroup:(id)sender;


@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (nonatomic, strong) XMPPRoomObject *roomObj;

@property (strong, nonatomic) IBOutlet UIButton *btn_addMembers;
- (IBAction)action_addMembers:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;


@end
