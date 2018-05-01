//
//  BroadcastRecieverChatViewController.h
//  IMYourDoc
//
//  Created by vijayveer on 24/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"
#import "STBubbleTableViewCell.h"
#import "AUIAutoGrowingTextView.h"


#import "ImYouDocViewController.h"

#import "BroadCastGroup+ClassMethod.h"
#import "BroadcastSubjectSender+ClassMethod.h"
@class InboxMessage;


@interface BroadcastRecieverChatViewController : ImYouDocViewController<UITableViewDataSource,UITableViewDelegate, STBubbleTableViewCellDelegate, STBubbleTableViewCellDataSource,NSFetchedResultsControllerDelegate>
{
    
    __weak IBOutlet UILabel *lbl_Subject;
    __weak IBOutlet UIButton *btnDelete;
    
    __weak IBOutlet UITableView *tableView_chat;
    
}

- (IBAction)action_delete:(id)sender;



// TableviewController Container

@property (nonatomic, strong) NSFetchedResultsController *chatController;

@property (nonatomic, strong) InboxMessage *inboxMessage ;

@end
