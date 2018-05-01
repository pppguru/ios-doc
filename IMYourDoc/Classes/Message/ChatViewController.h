//
//  ChatViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate+ClassMethods.h"
#import "AppDelegate+XmppMethods.h"
#import "VCard.h"
#import "UserSubView.h"
#import "FontTextView.h"
#import "FontTextField.h"
#import "FontHeaderLabel.h"
#import "IMYourDocButton.h"
#import "STBubbleTableViewCell.h"


#import "AUIAutoGrowingTextView.h"
#import "ImYouDocViewController.h"

@interface ChatViewController : ImYouDocViewController <UITextViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate, UISearchControllerDelegate, UIImagePickerControllerDelegate, STBubbleTableViewCellDelegate, STBubbleTableViewCellDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate,WebHelperDelegate>
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
    
    IBOutlet NSLayoutConstraint *TBVerticalSpaceConstraint,
                                                    *TVBottomSpaceConstraint,
                                                    *cameraBtnBottomSpaceConstraint,
                                                     *sendBtnBottomSpaceConstraint;
    
    // Load Older Messages 
    IBOutlet UIButton *btn_LoadOlderMessages;
}


@property (assign) BOOL isForward;

@property (nonatomic) BOOL forChat;

@property (assign) BOOL isViewDidAppear;

@property (nonatomic, assign) BOOL isGroupChat;

@property (nonatomic, strong) IBOutlet UITableView *chatTB;

@property (nonatomic, strong) NSMutableArray *jids, *searchUsers;

@property (nonatomic, retain) NSMutableDictionary *heightAtIndexPath;

@property (nonatomic, strong) NSFetchedResultsController *chatController;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;


@property (nonatomic, strong) XMPPJID *jid;

@property (nonatomic, strong) XMPPRoom *room;

@property (nonatomic, strong) XMPPRoomObject *roomObj;

@property (nonatomic, strong) ChatMessage *forwardMessage;

@property (nonatomic, strong) XMPPUserCoreDataStorageObject *user;


- (IBAction)backTap;

- (IBAction)sendTap;

- (IBAction)cameraTap;

- (IBAction)tapOnTitle;

- (IBAction)editModeTap;

- (IBAction)titleChanged;

- (IBAction)editChoiceTap:(IMYourDocButton *)sender;

- (IBAction)action_loadMessage_buttonLoadMoreTouched:(UIButton *)sender;

@end

