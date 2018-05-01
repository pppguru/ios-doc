//
//  MessageInboxViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 22/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "ImYouDocViewController.h"

@interface MessageInboxViewController : ImYouDocViewController <UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate>
{
    IBOutlet FontLabel *secureL;
    
    IBOutlet UILabel *titleL;
    
	IBOutlet UIView *searchSubView;
    
    IBOutlet UIImageView *secureIcon;
	
    __weak IBOutlet UITableView *messagesTB;

}


@property (nonatomic, strong) NSFetchedResultsController *messageFetchController;
@property (nonatomic, strong) NSMutableArray *arr_messageFetchController;
@property (strong, nonatomic) IBOutlet UILabel *lbl_syncing;
@property (weak, nonatomic) IBOutlet FontTextField *txt_search;


- (IBAction)navBack;


@end

