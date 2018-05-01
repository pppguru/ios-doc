//
//  BroadcastComposeOutboxViewController.h
//  IMYourDoc
//
//  Created by OSX on 15/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"


@interface BroadcastComposeOutboxViewController : ImYouDocViewController<NSFetchedResultsControllerDelegate>
{
    // 1StatusBarContainner
    IBOutlet UISegmentedControl *segment_Compse_outbx;
    IBOutlet UIButton *btn_addMember;
    
    // 2TableViewContainner
    IBOutlet UITableView *tableview_obj;

}

// 1StatusBarContainner
- (IBAction)action_Compse_outbx:(UISegmentedControl*)sender;
- (IBAction)action_addMember:(id)sender;


// 2TableViewContainner

@property (nonatomic,retain)NSFetchedResultsController *broadcastFetchController;
   @property (nonatomic,retain)NSFetchedResultsController *broadcastFetchController_subject;


// 3SecurityBarContainner



@end
