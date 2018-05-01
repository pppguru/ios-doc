//
//  ChatViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "UserSubView.h"
#import "FontTextView.h"
#import "FontTextField.h"
#import "FontHeaderLabel.h"
#import "IMYourDocButton.h"
#import "STBubbleTableViewCell.h"
#import "AUIAutoGrowingTextView.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "ImYouDocViewController.h"
@interface OfflineChatViewController : ImYouDocViewController <UITextViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate, UISearchControllerDelegate, UIImagePickerControllerDelegate, STBubbleTableViewCellDelegate, STBubbleTableViewCellDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate,ABPeoplePickerNavigationControllerDelegate,WebHelperDelegate>
{
    UIControl *ContentView;
    
    IBOutlet UIButton *editBtn;
    
    IBOutlet FontLabel *secureL;
    
    IBOutlet UITextField *searchbar;
    
    IBOutlet FontTextField *titleTF;
    
    IBOutlet UIScrollView *userScroll;
    
    IBOutlet UILabel *chatNotification;
    
    IBOutlet FontHeaderLabel *barTitleLbl;
    
    IBOutlet AUIAutoGrowingTextView *msgTV;
    
    IBOutlet NSLayoutConstraint *verticalHeightConst;
    
    IBOutlet UIButton *CameraBtn, *SendButton, *titleBtn;
    
    IBOutlet UIImageView *secureIcon, *editIcon, *editBtnIcon;
    
    IBOutlet UIView *searchSubView, *subViewContainer, *adminEditModeSubView, *nonAdminEditModeSubView, *singleUserEditModeSubView;
    
    IBOutlet NSLayoutConstraint *TBVerticalSpaceConstraint, *TVBottomSpaceConstraint, *cameraBtnBottomSpaceConstraint, *sendBtnBottomSpaceConstraint;
}


@property (assign) BOOL isForward;

@property (nonatomic) BOOL forChat;

@property (nonatomic, assign) BOOL isGroupChat;

@property (nonatomic, strong) IBOutlet UITableView *chatTB;

@property (nonatomic, strong) NSMutableArray *jids, *searchUsers;

@property (nonatomic, strong) NSFetchedResultsController *chatController;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, strong) OfflineContact *user;
@property (nonatomic,strong) UIControl *footerForSDCMain;


- (IBAction)backTap;

- (IBAction)sendTap;

- (IBAction)cameraTap;

- (IBAction)editModeTap;

- (IBAction)titleChanged;

- (IBAction)tapOnTitle;


- (IBAction)editChoiceTap:(IMYourDocButton *)sender;


@end

