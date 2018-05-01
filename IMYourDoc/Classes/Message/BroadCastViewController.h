//
//  BroadCastViewController.h
//  IMYourDoc
//
//  Created by OSX on 03/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "BCBubbleViewCell.h"
#import "AUIAutoGrowingTextView.h"


#import "ImYouDocViewController.h"

#import "BroadCastGroup+ClassMethod.h"
#import "BroadcastSubjectSender+ClassMethod.h"

@interface BroadCastViewController : ImYouDocViewController <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate, BCBubbleTableViewCellDelegate, BCBubbleTableViewCellDataSource,NSFetchedResultsControllerDelegate>
{
    

    // secureContainer

    
    // textviewContainer
    IBOutlet AUIAutoGrowingTextView *txt_message;//51
    
    IBOutlet AUIAutoGrowingTextView *txt_subject; //31
    
    IBOutlet UIButton *btn_send;

    // TableviewContainer
    IBOutlet UITableView *tableView_chat;
    
    NSFetchedResultsController * broadcastFetchController;
    
    // SubviewContainer
    IBOutlet UIView *view_SubviewContainer;
    
    IBOutlet UIButton *btn_MoreOption;
    
    //constraint
    IBOutlet NSLayoutConstraint *const_SubviewHeight;
    
    IBOutlet NSLayoutConstraint *const_subviewConToTableViewCon;
    
    
     // StatusBarContainer
    IBOutlet IMYourDocButton *btn_Members;
    
    __weak IBOutlet UILabel *lbl_GroupName;
    
    
    IBOutlet NSLayoutConstraint *txtViewContainerBottomConst;
}

@property (nonatomic,retain)NSMutableArray *arr_contacts;
@property (nonatomic,retain)BroadCastGroup* currnetGroup;
@property (nonatomic,retain)BroadcastSubjectSender *currentSubject;


- (IBAction)action_members:(id)sender;
- (IBAction)action_MoreOption:(UIButton *)sender;
- (IBAction)action_send:(id)sender;


@end
