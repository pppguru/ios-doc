//
//  PendingRequestViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "IMYourDocButton.h"


@interface PendingRequestViewController : UIViewController <ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate,WebHelperDelegate>
{
    IBOutlet UILabel *titleL;
    
    IBOutlet UITableView *listTB;
    
    __block NSString *statusBlockParam;
    
    __block NSIndexPath *indexPathBlockParam;
    
    IBOutlet IMYourDocButton *pendingBtn, *declinedBtn;
}


@property (nonatomic, strong) NSMutableDictionary *requestDict;


- (void)getPendingRequestsAndShowSpinner:(BOOL)showSpinner;


- (IBAction)navBack;

- (IBAction)pendingList;

- (IBAction)declinedList;


@end

