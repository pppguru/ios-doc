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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "OfflineContactDetailsViewController.h"
#import "NSMutableDictionary+Contact.h"

#import "ImYouDocViewController.h"

@interface OfflineNetworkViewController : ImYouDocViewController <UITextFieldDelegate, WebHelperDelegate>
{
    IBOutlet FontLabel *secureL;
    
	IBOutlet UIView *searchSubView;
    
    IBOutlet UIImageView *secureIcon;
	
    IBOutlet UITableView *messagesTB;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentbtn_ContactInbox;

//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *segmentBtn_ContactInbox;
- (IBAction)segment_ContactInbox:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *messageFetchController;

@property (strong, nonatomic) IBOutlet FontTextField *txt_search;
@property (nonatomic,strong) UIControl *footerForSDCMain;
- (IBAction)navBack;

- (IBAction)offlineChatCompose;


@end

