//
//  ChatViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "NSData+XMPP.h"
#import "UserSubView.h"
#import "UserListCell.h"
#import "NSString+DDXML.h"
#import "CoreDataHelper.h"
#import "XMPPRoomObject.h"
#import "ChatViewController.h"
#import "RDCallbackAlertView.h"
#import "ReadByViewController.h"
#import "AttachmentViewController.h"
#import "GroupMembersViewController.h"
#import "AttachmentWebViewController.h"
#import "MessageForwardViewController.h"
#import "DetailOfMessageViewController.h"
#import "ChatViewController+HenceForth.h"
#import "ReadByWebServicesViewController.h"


#import "UIAlertController+Window.h"

@interface ChatViewController ()
{
    UILabel *searchLB;
    
    BOOL add_members_taped;
    IBOutlet UIView *view_loadmore;
    
    NSFetchedResultsChangeType  lastOperation;
    
    NSOperationQueue * chatstateQue;
    
    NSTimer *timerTyping;
    NSString *strCurrentText;
    BOOL isTyping;
}

// Declare some collection properties to hold the various updates we might get from the NSFetchedResultsControllerDelegate
@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;

@end


@implementation ChatViewController

#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    strCurrentText = @"";
    isTyping = NO;
    msgTV.delegate = self;
    
    chatstateQue = [[NSOperationQueue alloc] init];
    
    chatstateQue.name=@"readStatusQue";
    
    chatstateQue.maxConcurrentOperationCount=2;
    
    if (8.0 > ![[UIDevice currentDevice].systemVersion floatValue])
        [chatstateQue setQualityOfService:NSQualityOfServiceBackground];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.jids = [NSMutableArray array];
    
    self.chatTB.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData) name:@"ReloadAppDelegateTable" object:nil];
    
    chatNotification.text = @"";
    
    msgTV.placeholder = @"Type your message..";
    
    ContentView = [[UIControl alloc] init];
    
    [ContentView setTag:0];
    
    [ContentView addTarget:self action:@selector(editChoiceTap:) forControlEvents:UIControlEventTouchUpInside];
    
    ContentView.translatesAutoresizingMaskIntoConstraints = YES;
    
    ContentView.frame = userScroll.bounds;
    
    ContentView.backgroundColor = [UIColor clearColor];
    
    userScroll.contentSize = ContentView.frame.size;
    
    [userScroll addSubview:ContentView];
    
    [self setUpScrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadOlderMessagesNotification:) name:@"KLoadOlderMessagesNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadOlderMessagesWithIncreaseCountNotification:) name:@"KLoadOlderMessagesWithIncreaseCountNotification" object:nil];
    
    if (self.isGroupChat)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadOlderMessagesNotificationForGroup:) name:@"KreceiveLoadOlderMessagesNotificationForGroup" object:nil];
    }
    
    self.heightAtIndexPath = [NSMutableDictionary new];
    
    [self.chatTB registerNib:[UINib nibWithNibName:@"RightSTBubbleTableViewCell" bundle:nil] forCellReuseIdentifier:@"RightChatCell"];
    
    [self.chatTB registerNib:[UINib nibWithNibName:@"STBubbleTableViewCell" bundle:nil] forCellReuseIdentifier:@"LeftChatCell"];
}

-(void) reloadTableViewData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatTB reloadData];
    });
}

//View will scroll to the last row when the superview is in view
-(void)viewDidLayoutSubviews{
    if( self.view.superview && !self.isViewDidAppear && (self.user || self.isGroupChat))
            [self setTableViewAtBottom];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.secureDelegate = self;
    
    [self addrefreshControlToChatTable];
    
    [self setRequiredFont2];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        msgTV.maxHeight = 80;
    }
    
    else
    {
        msgTV.maxHeight = 100;
    }
    
    editBtn.hidden = YES;
    
    editBtnIcon.hidden=YES;
    
    if ([AppDel isConnected])
    {
        secureL.text = @"Securely Connected";
        
        secureIcon.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureL.text = @"Not Connected";
        
        secureIcon.image = [UIImage imageNamed:@"unsecure_icon"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChatNotification:) name:@"KChatStateNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (self.user)
    {
        [[AppDel notifyArrayForChat] addObject:self.jid];
        
        editBtn.hidden  = NO;
        
        editBtnIcon.hidden=YES;
        
        [searchbar removeFromSuperview];
        
        _chatTB.tableHeaderView.hidden=NO;
        
        barTitleLbl.text = self.user.nickname;
        
        VCard *vCard = [AppDel fetchVCard:self.user.jid];
        
        if (vCard.name != nil)
        {
            barTitleLbl.text = vCard.name;
        }
        
        self.jids = [NSMutableArray arrayWithObject:self.user];
        
        
        if ([AppDel isFromPhysician] != isPatient)
        {
            [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
            
            
            self.navigationItem.rightBarButtonItem.title = @"Close";
        }
        
        [_chatTB reloadData];
    }
    
    else if (self.isGroupChat)
    {
        [searchbar removeFromSuperview];
        
        editBtn.hidden = NO;
        
        editBtnIcon.hidden = YES;
        
        _chatTB.tableHeaderView.hidden=NO;
        
        if ([ChatMessage checkLoadingCompleteInGroupChatForJid:self.roomObj.room_jidStr] == YES)
        {
            _chatTB.tableHeaderView.hidden=YES;
        }
        
        barTitleLbl.text = self.roomObj.name;
        
        
        if ([barTitleLbl.text length] == 0)
        {
            barTitleLbl.text = [[XMPPJID jidWithString:self.roomObj.room_jidStr] user];
            
            
            [self.room fetchRoomInfo];
        }
        
        
        if ([AppDel isFromPhysician] != isPatient)
        {
            [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
            
            
            self.navigationItem.rightBarButtonItem.title = @"..";
        }
        
        
        [_chatTB reloadData];
        
        
        [self.jids removeAllObjects];
        
        
        dispatch_queue_t que1 = dispatch_get_main_queue();
        
        
        [self.room addDelegate:self delegateQueue:que1];
        
        if([[self.roomObj roleForJid:[XMPPJID jidWithString:[AppDel myJID]]] isEqualToString:@"owner"])
        {
            titleBtn.hidden=NO;
            editBtnIcon.hidden=NO;
        }
        
    }
    
    else
    {
        barTitleLbl.text = @"New Conversation";
    }
    
    if (self.user) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                       {
//                           [self loadMessageListDefault_onceStep1];
                           
                       } );
    }
    
    if (self.forChat == YES)
    {
        [self viewForChat:YES];
    }
    
    else
    {
        [self viewForChat:NO];
    }
    
    if (self.forwardMessage)
    {
        if (self.jid == nil)
        {
            msgTV.text = self.forwardMessage.content;
        }
        
        else
        {
            ChatMessage *message    = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:[AppDel managedObjectContext_roster]];
            
            message.lastResend      = [NSDate date];
            
            message.messageID       = [[AppDel xmppStream] generateUUID];
            
            message.content         = self.forwardMessage.content;
            
            message.uri             = [self.jid bare];
            
            message.groupMessageID  = self.forwardMessage.groupMessageID;
            
            message.isRoomMessage   = [NSNumber numberWithBool:self.isGroupChat];
            
            message.content         = self.forwardMessage.content;
            
            message.thumb           = self.forwardMessage.thumb;
            
            message.chatState       = [NSNumber numberWithInt:ChatStateType_Sending];
            
            message.timeStamp       = [NSDate date];
            
            message.mark_deleted    = self.forwardMessage.mark_deleted;
            
            message.outbound        = [NSNumber numberWithBool:YES];
            
            message.fileTypeChat    = self.forwardMessage.fileTypeChat;
            
            message.displayName     = [self.jid bare];
            
            message.identityuri     = [AppDel myJID];
            
            message.requestStatus   = self.forwardMessage.requestStatus;
            
            message.fileMediaType   = self.forwardMessage.fileMediaType;
            
            self.forwardMessage = nil;
            
            
            [AppDel addInboxMessage:message];
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"addInboxMessage" Content:message.messageID parameter:[ChatMessage ChatTypeToStr:[message.chatState intValue]]];
            
            [[AppDel managedObjectContext_roster] save:nil];
            
            
            if (self.isGroupChat == NO)
            {
                if ([message.fileTypeChat boolValue] == NO)
                {
                    [AppDel sendMsg:message.content toIMYourDocUser:[self.jid bare] withMessageID:message.messageID];
                }
                
                else
                {
                    [AppDel sendFileTransferMessagetoUser:message.uri withFileName:message.content withImage:message.thumb withMessageID:message.messageID type:message.fileMediaType];
                }
            }
            
            else
            {
                if ([message.fileTypeChat boolValue] == NO)
                {
                    XMPPMessage *message2 = [XMPPMessage message];
                    
                    [message2 addAttributeWithName:@"id" stringValue:message.messageID];
                    
                    [message2 addAttributeWithName:@"from" stringValue:message.identityuri];
                    
                    [message2 addAttributeWithName:@"to" stringValue:message.uri];
                    
                    [message2 addAttributeWithName:@"type" stringValue:@"groupchat"];
                    
                    @autoreleasepool {
                        
                        VCard * vcard=[AppDel fetchVCard:[XMPPJID jidWithString:message.uri]];
                        (void)vcard;
                    }
                    
                    {
                        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:message.content,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",message.identityuri,@"from",message.uri,@"to",message.messageID,@"messageID", nil];
                        
                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                        
                        [message2 addChild:body];
                        
                        [message2 addProperty:@"message_version" value:@"2.0" type:@"string"];
                    }
                    
                    [[AppDel xmppStream] sendElement:message2];
                    
                    [AppDel addTimerForMessage:message.messageID];
                }
                
                else
                {
                    [AppDel sendFileTransferMessagetoGroup:message.uri withFileName:message.content withImage:message.thumb withMessageID:message.messageID type:message.fileMediaType];
                }
            }
        }
    }
    
    [self.chatTB reloadData];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isViewDidAppear = true;
}


- (void) viewWillDisappear:(BOOL)animated
{
    if (self.user)
    {
        [[AppDel notifyArrayForChat] removeObject:self.user.jid.bare];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    [msgTV resignFirstResponder];
    
    if (self.isGroupChat)
    {
        dispatch_queue_t que1 = dispatch_get_main_queue();
        
        
        [self.room removeDelegate:self delegateQueue:que1];
    }
    
    self.isViewDidAppear = false;
    
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    editBtn.selected = NO;
    editIcon.image = [UIImage imageNamed:@"More_on"];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KLoadOlderMessagesNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KLoadOlderMessagesWithIncreaseCountNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KreceiveLoadOlderMessagesNotificationForGroup" object:nil];
}


#pragma mark - NSFetchRequest

- (NSFetchedResultsController *)chatController
{
    if (_chatController)
    {
        return _chatController;
    }
    
    if (self.jids.count == 1 || self.room != nil)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
        
        NSString *jid;
        
        NSPredicate *predicate;
        
        if (self.jids.count == 1)
        {
            jid = [self.jid bare];
            predicate = [NSPredicate predicateWithFormat:@" uri=%@ and identityuri=%@ and mark_deleted!=%@ and chatMessageTypeOf == 0 ", jid, [AppDel myJID], [NSNumber numberWithBool:mark_deleted_YES]];
        }
        
        else
        {
            jid = self.roomObj.room_jidStr;
            predicate = [NSPredicate predicateWithFormat:@" uri=%@ and identityuri=%@ and mark_deleted!=%@ and content!=%@  ", jid, [AppDel myJID] , [NSNumber numberWithBool:mark_deleted_YES],[NSString stringWithFormat:@"~$^^xxx*xxx~$^^"]];
        }
        
        [request setPredicate:predicate];
        
        request.sortDescriptors = @[sorter];
        
        _chatController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
        
        _chatController.delegate = self;
        
        if ([_chatController performFetch:nil])
        {
            return _chatController;
        }
    }
    return nil;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KReadByViewControllerStatusChange" object:nil userInfo:nil];
    
//    [self.chatTB beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete:
            [self.deletedSectionIndexes addIndex:sectionIndex];
            break;
        default:
            ; // Shouldn't have a default
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (![self isViewLoaded])
    {
        return;
    }
    
    lastOperation=type;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:{
            if ([self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
                // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
                return;
            }
            
            [self.insertedRowIndexPaths addObject:newIndexPath];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setTableViewAtBottom];
            });
        }
            
            break;
            
            
        case NSFetchedResultsChangeDelete:{
            
            if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
                // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
                return;
            }
            
            [self.deletedRowIndexPaths addObject:indexPath];
        }
            
            break;
            
            
        case NSFetchedResultsChangeUpdate:{
            [self.updatedRowIndexPaths addObject:indexPath];
        }
            
            break;
            
        case NSFetchedResultsChangeMove:{
            
            if ([self.insertedSectionIndexes containsIndex:newIndexPath.section] == NO) {
                [self.insertedRowIndexPaths addObject:newIndexPath];
            }
            
            if ([self.deletedSectionIndexes containsIndex:indexPath.section] == NO) {
                [self.deletedRowIndexPaths addObject:indexPath];
            }
        
            
        }
            
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSInteger totalChanges = [self.deletedSectionIndexes count] +
                            [self.insertedSectionIndexes count] +
                            [self.deletedRowIndexPaths count] +
                            [self.insertedRowIndexPaths count] +
                            [self.updatedRowIndexPaths count];
    
    if (totalChanges > 50) {
        self.insertedSectionIndexes = nil;
        self.deletedSectionIndexes = nil;
        self.deletedRowIndexPaths = nil;
        self.insertedRowIndexPaths = nil;
        self.updatedRowIndexPaths = nil;
        
        [self.chatTB reloadData];
        return;
    }
    
    [self.chatTB beginUpdates];
    
    [self.chatTB deleteSections:self.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationNone];
    [self.chatTB insertSections:self.insertedSectionIndexes withRowAnimation:UITableViewRowAnimationNone];
    
    [self.chatTB deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.chatTB insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.chatTB reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationNone];

    [self.chatTB endUpdates];
    
    // nil out the collections so they are ready for their next use.
    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.deletedRowIndexPaths = nil;
    self.insertedRowIndexPaths = nil;
    self.updatedRowIndexPaths = nil;

    
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self setTableViewAtBottom];
//    });
}

#pragma mark - Overridden getters

/**
 * Lazily instantiate these collections.
 */

- (NSMutableIndexSet *)deletedSectionIndexes
{
    if (_deletedSectionIndexes == nil) {
        _deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    
    return _deletedSectionIndexes;
}

- (NSMutableIndexSet *)insertedSectionIndexes
{
    if (_insertedSectionIndexes == nil) {
        _insertedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    
    return _insertedSectionIndexes;
}

- (NSMutableArray *)deletedRowIndexPaths
{
    if (_deletedRowIndexPaths == nil) {
        _deletedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    
    return _deletedRowIndexPaths;
}

- (NSMutableArray *)insertedRowIndexPaths
{
    if (_insertedRowIndexPaths == nil) {
        _insertedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    
    return _insertedRowIndexPaths;
}

- (NSMutableArray *)updatedRowIndexPaths
{
    if (_updatedRowIndexPaths == nil) {
        _updatedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    
    return _updatedRowIndexPaths;
}


#pragma mark - Void
- (void)setTableViewAtTop
{
    if ([[self.chatController sections] count] > 0)
    {
        
        id<NSFetchedResultsSectionInfo> sectionInfo = [self.chatController.sections objectAtIndex:0];
        
        if ([sectionInfo numberOfObjects] > 0)
        {
            [self.chatTB scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        else
        {
            [self.chatTB   setContentOffset:CGPointMake(0, 0)];
        }
    }
}

- (void)setTableViewAtBottom
{
    if ([self.chatTB numberOfRowsInSection:0] > 0) {
        [self.chatTB scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatTB numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}


- (void)setUpScrollView
{
    for (UIView *user in ContentView.subviews)
    {
        [user removeFromSuperview];
    }
    
    ContentView.frame = CGRectMake(0, 0, 0, userScroll.frame.size.height);
    
    int xAxis = 0;
    int yAxis = 0;
    
    if(self.jids.count==1)
    {
        self.jid=[[self.jids lastObject] jid];
    }
    
    for (XMPPUserCoreDataStorageObject *user in self.jids)
    {
        UserSubView *userSubView = [[[NSBundle mainBundle] loadNibNamed:@"UserSubView" owner:self options:nil] lastObject];
        
        userSubView.user = user;
        
        userSubView.nameLB.text = user.nickname;
        
        userSubView.profileImage.image = [UIImage imageWithData:[[AppDel xmppvCardAvatarModule] photoDataForJID:user.jid]];
        
        
        if (userSubView.profileImage.image == nil)
        {
            userSubView.profileImage.image = [UIImage imageNamed:@"Profile"];
        }
        
        
        if (((xAxis * (userSubView.frame.size.width + 5)) + userSubView.frame.size.width) > userScroll.frame.size.width)
        {
            yAxis++;
            
            xAxis = 0;
        }
        
        
        userSubView.frame = CGRectMake((xAxis * (userSubView.frame.size.width + 5)), (yAxis * (userSubView.frame.size.height + 5)), userSubView.frame.size.width, userSubView.frame.size.height);
        
        
        xAxis++;
        
        
        userSubView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        userSubView.layer.cornerRadius = 5;
        
        userSubView.layer.masksToBounds = YES;
        
        userSubView.profileImage.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        userSubView.profileImage.layer.cornerRadius = 14;
        
        userSubView.profileImage.layer.masksToBounds = YES;
        
        [userSubView.actionBtn addTarget:self action:@selector(removeUserView:) forControlEvents:UIControlEventTouchUpInside];
        
        [ContentView addSubview:userSubView];
    }
    
    searchLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
    
    if (((xAxis * (searchLB.frame.size.width + 5)) + searchLB.frame.size.width) > userScroll.frame.size.width)
    {
        yAxis++;
        
        xAxis = 0;
        
        searchLB.frame = CGRectMake(0, 0, userScroll.frame.size.width, 35);
    }
    
    searchLB.frame = CGRectMake((xAxis * (searchLB.frame.size.width + 5)), (yAxis * (searchLB.frame.size.height + 0)), searchLB.frame.size.width, searchLB.frame.size.height);
    
    [ContentView addSubview:searchLB];
    
    ContentView.frame = CGRectMake(0, 0, userScroll.frame.size.width/*110 * xAxis*/, 35 * (yAxis + 1));
    
    userScroll.contentSize = ContentView.frame.size;
    
    if (ContentView.frame.size.height + 5 > searchSubView.frame.size.height)
    {
        searchSubView.frame = CGRectMake(searchSubView.frame.origin.x, searchSubView.frame.origin.y, searchSubView.frame.size.width, ContentView.frame.size.height + 5);
        
        
        userScroll.frame = CGRectMake(userScroll.frame.origin.x, userScroll.frame.origin.y, userScroll.frame.size.width, ContentView.frame.size.height + 5);
    }
    
    verticalHeightConst.constant = 45 + (yAxis * 30) + (yAxis * 4);
    
    if (self.jids.count > 0)
    {
        NSArray *names = [self.jids valueForKey:@"nickname"];
        
        barTitleLbl.text = [names componentsJoinedByString:@","];
    }
}

- (void)viewForChat:(BOOL)forChat
{
    if (forChat)
    {
        subViewContainer.hidden = YES;
        
        TBVerticalSpaceConstraint.constant = -45;
    }
    
    else
    {
        subViewContainer.hidden = NO;
        
        TBVerticalSpaceConstraint.constant = 0;
        
        [self addSubview:searchSubView toSuperView:subViewContainer];
    }
    
    [self.view layoutIfNeeded];
}


- (void)search:(NSString *)searchTxt
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(nickname beginswith[cd] %@ or jidStr beginswith[cd]  %@ or displayName beginswith[cd]  %@ or displayName contains[cd]  %@) and subscription=%@", searchTxt, searchTxt, searchTxt, [NSString stringWithFormat:@" %@", searchTxt], @"both"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    request.predicate = predicate;
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES]];
    
    NSMutableArray *roomsAndUsers = [[[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil] mutableCopy];
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"room_status!='deleted' AND name beginswith[cd] %@", searchTxt];
    
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomObject"];
    
    request2.predicate = predicate2;
    
    request2.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSMutableArray *rooms = [[[AppDel managedObjectContext_roster] executeFetchRequest:request2 error:nil] mutableCopy];
    
    [roomsAndUsers addObjectsFromArray:rooms];
    
    
    self.searchUsers = roomsAndUsers;
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}


- (void)acceptButtonPressed:(UIButton *)sender
{
    NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    
    ChatMessage *chatToUpdate = [[self chatController] objectAtIndexPath:currentIndex];
    
    chatToUpdate.requestStatus = [NSNumber numberWithInt:RequestStatusType_UnKnown];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *error = nil;
        
        
        if (![[AppDel managedObjectContext_roster] save:&error])
        {
            NSLog(@"%@", [error domain]);
        }
    });
}


- (void)appEnterBackground: (NSNotification *)noti
{
    [msgTV resignFirstResponder];
}


- (void)declineButtonPressed:(UIButton *)sender
{
    NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    ChatMessage *chatToDel = [[self chatController] objectAtIndexPath:currentIndex];
    
    [[AppDel managedObjectContext_roster] deleteObject:chatToDel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *error = nil;
        
        if (![[AppDel managedObjectContext_roster] save:&error])
        {
            NSLog(@"%@", [error domain]);
        }
    });
}

- (void)retryButtonPressed:(UIButton *)sender
{
    NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    ChatMessage *chat = [[self chatController] objectAtIndexPath:currentIndex];
    
    chat.requestStatus = [NSNumber numberWithInt:RequestStatusType_isYetToBeUpload];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *error = nil;
        
        if (![[AppDel managedObjectContext_roster] save:&error])
        {
            NSLog(@"%@", [error domain]);
        }
    });
    
    [self startIconDownload:currentIndex.row withImagePath:chat.content];
}

- (void)addSubview1: (UIView *)subView toSuperView: (UIView *)superView
{
    {
        [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [superView addSubview:subView];
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:superView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:45]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
        
        [superView layoutIfNeeded];
    }
}

- (void)addSubview: (UIView *)subView toSuperView: (UIView *)superView
{
    if (!subViewContainer.hidden)
    {
        [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [superView addSubview:subView];
        
        NSDictionary *views = @{@"subview" : subView, @"superview" : superView};
        
        [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
        
        [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subview(==superview)]" options:0 metrics:nil views:views]];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem: subView
                                                                      attribute: NSLayoutAttributeTop
                                                                      relatedBy: NSLayoutRelationEqual
                                                                         toItem: superView
                                                                      attribute: NSLayoutAttributeTop
                                                                     multiplier: 1.0
                                                                       constant: 0];
        
        [superView addConstraint:constraint];
        
        [superView layoutIfNeeded];
    }
}

#pragma mark - IBAction

- (IBAction)backTap
{
    [self.chatTB setEditing:NO animated:YES];
    
    if (self.isForward == NO)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    else
    {
        [self.navigationController popToViewController:[AppDel homeView] animated:YES];
    }
}


- (IBAction)sendTap
{
    
    if ([[AppDel xmppStream] isConnected] == NO || [AppDel appIsDisconnected] || ![secureL.text isEqualToString:@"Securely Connected"])
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please wait. Connecting to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        return;
    }
    
    if ([msgTV.text exactLength] == 0)
    {
        return;
    }
    
    [msgTV.text checkStringLength:^(BOOL isLess, NSString *string) {
        if (isLess == false)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"This message is too long. Please shorten it to less than 2000 characters and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            return ;
        }
        
        else
        {
            [self sendMessage:string];
            
            msgTV.text = @"";
            
//            [self sendUserChatNotification:SendChatStateType_gone2];
            
            CameraBtn.hidden = NO;
            SendButton.hidden = YES;
        }
        
    }];
}


- (IBAction)cameraTap
{
    
    //Check if at least one recipient is chosen
    if ( !self.jid ) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please specify at least one recipient in To: before sending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        return;
    }
    
    //Show the image picker
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Pick a source" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull_action) {
        
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull_action) {
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:imagePicker animated:YES completion:^{
        }];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull_action) {
        [self presentViewController:imagePicker animated:YES completion:^{
        }];
    }]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [sheet setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [sheet popoverPresentationController];
        popPresenter.sourceView = CameraBtn;
        popPresenter.sourceRect = CameraBtn.bounds;

        [self presentViewController:sheet animated:YES completion:nil];
    }
    else{
        [sheet show];
    }
    
}


- (IBAction)editModeTap
{
    editBtn.selected = !editBtn.selected;
    
    if (editBtn.selected)
    {
        subViewContainer.hidden = NO;
        
        editIcon.image = [UIImage imageNamed:@"More_over"];
        
        TBVerticalSpaceConstraint.constant = 0;
        
        if ([self.jids count] == 1 || self.user != nil)
        {
            [self addSubview:singleUserEditModeSubView toSuperView:subViewContainer];
        }
        
        if (self.isGroupChat || self.room)
        {
            if ((self.room && self.isGroupChat == 0) || [[self.roomObj roleForJid:[XMPPJID jidWithString:[AppDel myJID]]] isEqualToString:@"owner"])
            {
                [self addSubview:adminEditModeSubView toSuperView:subViewContainer];
            }
            
            else
            {
                [self addSubview:nonAdminEditModeSubView toSuperView:subViewContainer];
            }
        }
    }
    
    else
    {
        subViewContainer.hidden = NO;
        
        editIcon.image = [UIImage imageNamed:@"More_on"];
        
        TBVerticalSpaceConstraint.constant = 0;
        
        [self viewForChat:YES];
    }
}

- (IBAction)editChoiceTap:(IMYourDocButton *)sender
{
    if (sender.tag == 0)              // for Search Bar  "Add Tap"
    {
        self.searchDisplayController.searchBar.hidden = NO;
        
        self.searchDisplayController.searchBar.text = @"";
        
        [self.searchDisplayController.searchBar becomeFirstResponder];
    }
    
    else if (sender.tag == 1)         // for Admin "Add Recipient"
    {
        GroupMembersViewController *groupMember = [[GroupMembersViewController alloc] initWithNibName:@"GroupMembersViewController" bundle:nil];
        
        groupMember.roomObj = self.roomObj;
        
        groupMember.xmppRoom = self.room;
        
        [self.navigationController pushViewController:groupMember animated:YES];
    }
    
    else if (sender.tag == 2)         // for Admin  "Close Conversation"
    {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Closing the conversation will remove it from your inbox. Are you sure you want to close?" cancelButtonTitle:@"YES" andCompletionHandler:^(int button) {
            
            if (button == 0)
            {
                
                if(self.isGroupChat)
                    [ChatMessage resetIsLodingCompleteInGroupChatForJid:self.roomObj.room_jidStr];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    XMPPMessage *message = [XMPPMessage message];
                    
                    [message addAttributeWithName:@"id" stringValue:@"IMYOURDOC_CLOSE"];
                    
                    [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
                    
                    [message addAttributeWithName:@"to" stringValue:[self.room.roomJID bare]];
                    
                    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                    
                    
                    //************qwerty***********************
                    
                    
                    @autoreleasepool {
                        
                        VCard * vcard=[AppDel
                                       fetchVCard:[XMPPJID jidWithString:self.room.roomJID.bare]];
                        (void)vcard;
                    }
                    
                    
                    {
                        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:@"~$^^xxx*xxx~$^^",@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",[[[AppDel xmppStream] myJID] bare],@"from",self.room.roomJID.bare,@"to",@"IMYOURDOC_CLOSE",@"messageID", nil];
                        
                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                        
                        [message addChild:body];
                        
                        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
                    }
                    
                    //************qwerty***********************
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[AppDel xmppStream] sendElement:message];
                    });
                });
                
            }
            
        } otherButtonTitles:@"NO", nil];
    }
    
    else if (sender.tag == 3)         // for Admin  "Show Members"
    {
        GroupMembersViewController *groupMember = [[GroupMembersViewController alloc] initWithNibName:@"GroupMembersViewController" bundle:nil];
        
        groupMember.roomObj = self.roomObj;
        
        groupMember.xmppRoom = self.room;
        
        [self.navigationController pushViewController:groupMember animated:YES];
    }
    
    else if (sender.tag == 4)         // for Admin  "Delete Group"
    {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this group?" cancelButtonTitle:@"YES" andCompletionHandler:^(int button) {
            
            if (button == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    XMPPMessage *message = [XMPPMessage message];
                    
                    [message addAttributeWithName:@"id" stringValue:@"IMYOURDOC_DELETE"];
                    
                    [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
                    
                    [message addAttributeWithName:@"to" stringValue:[self.room.roomJID bare]];
                    
                    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                    
                    
                    
                    
                    
                    //*************qwerty********************
                    
                    
                    
                    @autoreleasepool {
                        
                        VCard * vcard=[AppDel
                                       fetchVCard:[XMPPJID jidWithString:self.room.roomJID.bare]];
                        (void)vcard;
                    }
                    
                    
                    {
                        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:@"DELETE ROOM",@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",[[[AppDel xmppStream] myJID] bare],@"from",self.room.roomJID.bare,@"to",@"IMYOURDOC_DELETE",@"messageID", nil];
                        
                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                        
                        [message addChild:body];
                        
                        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[AppDel xmppStream] sendElement:message];
                        
                        
                        [self.room destroyRoom];
                        
                        
                        // [self.navigationController popViewControllerAnimated:YES];
                    });
                    
                    
                    self.roomObj.room_status = @"deleted";
                    
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                });
            }
            
        } otherButtonTitles:@"NO", nil];
    }
    
    else if (sender.tag == 5)         // for Non-Admin   "Close Conversation"
    {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Closing the conversation will remove it from your inbox. Are you sure you want to close?" cancelButtonTitle:@"YES" andCompletionHandler:^(int button) {
            
            if (button == 0)
            {
                if(self.isGroupChat)
                    [ChatMessage resetIsLodingCompleteInGroupChatForJid:self.roomObj.room_jidStr];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    XMPPMessage *message = [XMPPMessage message];
                    
                    [message addAttributeWithName:@"id" stringValue:@"IMYOURDOC_CLOSE"];
                    
                    [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
                    
                    [message addAttributeWithName:@"to" stringValue:[self.room.roomJID bare]];
                    
                    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                    
                    
                    
                    //****************qwerty*********************
                    
                    
                    @autoreleasepool {
                        
                        VCard * vcard=[AppDel
                                       fetchVCard:[XMPPJID jidWithString:[self.room.roomJID bare]]];
                        (void)vcard;
                    }
                    
                    {
                        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:@"~$^^xxx*xxx~$^^",@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",[[[AppDel xmppStream] myJID] bare],@"from",[self.room.roomJID bare],@"to",@"IMYOURDOC_CLOSE",@"messageID", nil];
                        
                        
                        
                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                        
                        [message addChild:body];
                        
                        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
                    }
                    
                    
                    
                    
                    //****************************************
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[AppDel xmppStream] sendElement:message];
                    });
                });
                
                
            }
            
        } otherButtonTitles:@"NO", nil];
    }
    
    else if (sender.tag == 6)         // for Non-Admin   "Show Members"
    {
        GroupMembersViewController *groupMember = [[GroupMembersViewController alloc] initWithNibName:@"GroupMembersViewController" bundle:nil];
        
        groupMember.roomObj = self.roomObj;
        
        groupMember.xmppRoom = self.room;
        
        [self.navigationController pushViewController:groupMember animated:YES];
    }
    
    else if (sender.tag == 7)         // for Non-Admin   "Leave Group"
    {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Are you sure you want to leave this group?" cancelButtonTitle:@"YES" andCompletionHandler:^(int button) {
            
            if (button == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
                    
                    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                    
                    [message addAttributeWithName:@"id" stringValue:@"REMOVE_REQUEST"];
                    
                    [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
                    
                    [message addAttributeWithName:@"to" stringValue:[[self.room roomJID] bare]];
                    
                    
                    //****************qwerty*********************
                    
                    
                    @autoreleasepool {
                        
                        VCard * vcard=[AppDel
                                       fetchVCard:[XMPPJID jidWithString:[self.room.roomJID bare]]];
                        (void)vcard;
                    }
                    
                    {
                        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:@"left the room",@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",[[[AppDel xmppStream] myJID] bare],@"from",[self.room.roomJID bare],@"to",@"REMOVE_REQUEST",@"messageID", nil];
                        
                        
                        
                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                        
                        [message addChild:body];
                        
                        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
                    }
                    
                    
                    //****************************************
                    
                    [[AppDel xmppStream] sendElement:message];
                    
                    
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
                    
                    request.predicate = [NSPredicate predicateWithFormat:@"uri=%@",[self.room.roomJID bare]];
                    
                    
                    NSArray *messagesForRoom = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
                    
                    
                    for (ChatMessage *message in messagesForRoom)
                    {
                        message.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
                    }
                    
                    
                    [self.navigationController popToViewController:[AppDel homeView] animated:YES];
                    
                    
                    self.roomObj.room_status = @"deleted";
                    
                    
                    [self.room leaveRoom];
                    
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                });
            }
            
        } otherButtonTitles:@"NO", nil];
    }
    
    else if (sender.tag == 8)         //   for Single-User   "Close Conversation"
    {
        [self.view endEditing:YES];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Do you want to close this conversation for this user?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
    }
    
    else if (sender.tag == 9)         // for Single-User   "Add-Recipient"
    {
        //[self.jids addObject:self.user];
        
        
        [self createRoom];
        
        
        add_members_taped = YES;
    }
}


- (IBAction)titleChanged
{
    editBtnIcon.hidden = editBtn.hidden = NO;
    
    if ([titleTF.text exactLength] > 3)
    {
        barTitleLbl.text = titleTF.text;
        
        [self.room fetchConfigurationForm];
        
        XMPPMessage *message = [XMPPMessage message];
        
        NSString *messageID =  [[AppDel xmppStream] generateUUID];
        
        [message addAttributeWithName:@"id" stringValue:messageID];
        
        [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
        
        [message addAttributeWithName:@"to" stringValue:self.room.roomJID.bare];
        
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject" stringValue:barTitleLbl.text];
        
        [message addChild:subject];
        
        [[AppDel xmppStream] sendElement:message];
    }
    
    titleTF.text = @"";
    
    barTitleLbl.hidden = NO;
    
    titleTF.hidden = YES;
}


- (IBAction)tapOnTitle
{
    if ([[self.roomObj roleForJid:[XMPPJID jidWithString:[AppDel myJID]]] isEqualToString:@"owner"])
    {
        barTitleLbl.hidden = YES;
        
        titleTF.hidden = NO;
        
        
        [titleTF becomeFirstResponder];
        
        editBtnIcon.hidden = YES;
    }
}


#pragma mark - Update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - Keyboard Notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    {
        CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
        
        {
            sendBtnBottomSpaceConstraint.constant = 5;
            sendBtnBottomSpaceConstraint.constant = cameraBtnBottomSpaceConstraint.constant = TVBottomSpaceConstraint.constant = (keyBFrame.size.height - 40);
            
            
            if(![self.searchDisplayController.searchBar isFirstResponder])
            {
                if (self.chatTB.contentSize.height > self.chatTB.frame.size.height / 2) //424
                {
                    [self.chatTB setContentOffset:CGPointMake(0, self.chatTB.contentSize.height-sendBtnBottomSpaceConstraint.constant )];
                }
                
            }
        }
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    sendBtnBottomSpaceConstraint.constant = cameraBtnBottomSpaceConstraint.constant = TVBottomSpaceConstraint.constant = 5;
    
//    [self sendUserChatNotification:SendChatStateType_gone];
}

#pragma mark - Check Composing/Stop
- (void)checkTyping{
    if ([strCurrentText isEqualToString:msgTV.text]){
        if (isTyping) {
            NSLog(@"-----------STOPPED");
            [self sendUserChatNotification:SendChatStateType_gone2];
            
            isTyping = NO;
        }
    }
    else{
        if (!isTyping) {
            NSLog(@"-----------STARTED");
            [self sendUserChatNotification:SendChatStateType_composing1];
        }
        
        NSLog(@"-----------TYPING..........");
        strCurrentText = msgTV.text;
        isTyping = YES;
    }
}

#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    strCurrentText = textView.text;
    timerTyping = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkTyping) userInfo:nil repeats:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [timerTyping invalidate];
    timerTyping = nil;
    
    if (isTyping){
        NSLog(@"-----------STOPPED");
        [self sendUserChatNotification:SendChatStateType_gone2];
        isTyping = NO;
    }
}


#pragma mark - Text Field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == titleTF && [[self.roomObj roleForJid:[XMPPJID jidWithString:[AppDel myJID]]] isEqualToString:@"owner"])
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //if (textField == titleTF) { return YES; }
    
    return YES;
}


#pragma mark - Text View

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([[textView.text stringByReplacingCharactersInRange:range withString:text] length] == 0)
    {
        CameraBtn.hidden = NO;
        
        SendButton.hidden = YES;
        
        
//        [self sendUserChatNotification:SendChatStateType_gone2];
    }
    
    else
    {
        CameraBtn.hidden = YES;
        
        SendButton.hidden = NO;
        
        
//        if([[textView.text stringByReplacingCharactersInRange:range withString:text] length]<4)
//            [self sendUserChatNotification:SendChatStateType_composing1];
    }
    
    return YES;
}


#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)  // For normal  converstation
    {
        [self.navigationController popToViewController:[AppDel homeView] animated:YES];
        
        
        NSString *toJid = [self.jid bare];
        
        
        if (self.jid == nil)
        {
            toJid = [(XMPPJID*)[[self.jids lastObject] jid]bare];
        }
        
        
        [AppDel sendMsg:@"~$^^xxx*xxx~$^^" toIMYourDocUser:toJid withMessageID:@"iPhoneForCloseAndDelete"];
        
        
        double delayInSeconds = 2.0;
        
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
           	NSString *identityURI = [AppDel myJID];
            
            
            NSPredicate *predicateForIM = [NSPredicate predicateWithFormat:@"identityuri like %@ and uri like %@", identityURI, toJid];
            
            
            NSMutableArray *itemsIM = [[NSMutableArray alloc] initWithArray:[CoreDataHelper searchObjectsInContext:@"ChatMessage" :predicateForIM :@"timeStamp" :NO :[AppDel managedObjectContext_roster]]];
            
            
            NSMutableString *tempDisplayName = [[NSMutableString alloc] initWithString:@" "];
            
            
            for (int i = 0; i < [itemsIM count]; i++)
            {
                tempDisplayName = [[[itemsIM objectAtIndex:i] displayName] mutableCopy];
                
                
                [[AppDel managedObjectContext_roster] deleteObject:[itemsIM objectAtIndex:i]];
                
                
                [self.chatTB reloadData];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSError *error = nil;
                    
                    
                    if (![[AppDel managedObjectContext_roster] save:&error])
                    {
                        NSLog(@"%@", [error domain]);
                    }
                });
            }
            
            
            if (self.user.jid)
            {
                [ConversationLog resetConversationLogMYJiD:[AppDel myJID] WithJID:[self.user.jid bare] withContext:[AppDel managedObjectContext_roster]];
                
                
            }
            
            [self service_ReportCloseConversationWithjid:toJid];
            
            if ([[AppDel openConversationArray] containsObject:tempDisplayName])
            {
                [[AppDel openConversationArray] removeObject:tempDisplayName];
            }
        });
    }
}


#pragma mark - Table



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.chatTB)
    {
        return self.searchUsers.count;
    }
    
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.chatController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.chatTB)
    {
        static NSString *listTBID = @"LIST_TB_CELLID";
        
        
        UserListCell *tbCell = [tableView dequeueReusableCellWithIdentifier:listTBID];
        
        
        if (tbCell == nil)
        {
            tbCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListCell" owner:self options:nil] lastObject];
            
            tbCell.userIMGV.layer.cornerRadius = 30;
            
            tbCell.userIMGV.layer.masksToBounds = YES;
        }
        
        
        NSManagedObject *user = [self.searchUsers objectAtIndex:indexPath.row];
        
        
        if ([user isKindOfClass:[XMPPUserCoreDataStorageObject class]])
        {
            tbCell.userNameLB.text = [(NSManagedObject *)user valueForKey:@"nickname"];
            
            
            NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[(NSManagedObject *)user valueForKey:@"jidStr"]]];
            
            
            if (imgData)
            {
                tbCell.userIMGV.image = [UIImage imageWithData:imgData];
            }
        }
        
        else if ([user isKindOfClass:[XMPPRoomObject class]])
        {
            tbCell.userNameLB.text = [(NSManagedObject *)user valueForKey:@"name"];
            
            tbCell.userIMGV.image = [UIImage imageNamed:@"Group_profile"];
            
            
            if ([[(XMPPRoomObject *) user isPatient] boolValue] == 1)
            {
                tbCell.userIMGV.image = [UIImage imageNamed:@"Red_group_profile"];
            }
        }
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        
        UIImage *img = [addBtn imageForState:UIControlStateNormal];
        
        tbCell.accessoryView = [[UIImageView alloc] initWithImage:img];
        
        return tbCell;
    }
    
    else
    {
        ChatMessage *message = [[self chatController] objectAtIndexPath:indexPath];
        
        NSString *cellID = @"RightChatCell";
        
        if (!message.isOutbound)
        {
            cellID = @"LeftChatCell";
        }
        
        __block  STBubbleTableViewCell *cell =(STBubbleTableViewCell*) [self.chatTB dequeueReusableCellWithIdentifier:cellID];
        
        
        cell.delegate = self;
        
        cell.dataSource = self;
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.userImage.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        cell.userImage.layer.cornerRadius = 15;
        
        cell.userImage.layer.masksToBounds = YES;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([[UIApplication  sharedApplication] applicationState]!=UIApplicationStateActive)
            {
                
                //if application is not in background mode then application will not send read report.
                
                return ;
            }
            if (message.isOutbound)
            {
                return;
            }
            if ([message.chatState isEqualToNumber:[NSNumber numberWithInt:ChatStateType_deliveredByReciever]])
            {
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"Right>>From>>To" Content:[NSString stringWithFormat:@"%@ %@",message.messageID, [ChatMessage ChatTypeToStr:message.chatState.intValue]]parameter:[ChatMessage ChatTypeToStr:ChatStateType_displayedByReciever]];
                
                
                message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                
                if([[AppDel managedObjectContext_roster] hasChanges])
                    [[AppDel managedObjectContext_roster] save:nil];
                
            }
            
            if ([message.readReportSent_Bl isEqualToNumber:[NSNumber numberWithBool:NO]])
            {
                
                message.readReportSent_Bl  = [NSNumber numberWithBool:YES];
                
                __block NSString * messageID=message.messageID,*buddyID;
                __block BOOL isRoom=[message.isRoomMessage boolValue];
                
                buddyID=message.uri;
                
                if([message.isRoomMessage boolValue])
                    buddyID=message.displayName;
                
                [chatstateQue addOperationWithBlock:^{
                    
                    [AppDel sendChatState:SendChatStateType_displayed withBuddy:buddyID  withMessageID:messageID isGroupChat:isRoom];
                }];
                
                
            }
        });
        
        
        
        if (message.isOutbound)
        {
            cell.bubbleColor = STBubbleTableViewCellBubbleColorGreen;
            
            cell.authorType = STBubbleTableViewCellAuthorTypeSelf;
        }
        
        else
        {
            cell.bubbleColor = STBubbleTableViewCellBubbleColorGray;
            
            cell.authorType = STBubbleTableViewCellAuthorTypeOther;
        }
        
        
        if ([message isOutbound])
        {
            cell.userImage.image =[AppDel image];
        }
        
        else
        {
            
            XMPPUserCoreDataStorageObject * user=[AppDel fetchUserForJIDString:message.displayName];
            
            if (user)
            {
                cell.userImage.image=user.photo;
            }
            else
            {
                
                cell.userImage.image =
                [UIImage imageWithData:[[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:message.displayName]]];
            }
        }
        
        
        if (cell.userImage.image == nil)
        {
            cell.userImage.image = [UIImage imageNamed:@"Profile"];
        }
        
        
        cell.lbl_messageContent.text = @"";
        
        cell.thumbImage = nil;
        
        cell.attachmentImage.image = nil;
        
        cell.message = message;
        
        cell.infoButton.hidden = YES;
        
        cell.messageStatLB.text = @"";
        
        
        
        // isOutbound is Sender
        
        
        if (message.isOutbound)
        {
            switch ([message.chatState intValue])
            {
                case ChatStateType_Sending:
                {
                    
                    
                    /*
                    if([message.isResending intValue]==1)
                    {
                        if ([message.retryState isEqualToNumber:@(RetryStatusType_three)])
                        {
                            cell.messageStatLB.text = @"Sending failed";
                        }
                        else{
                            cell.messageStatLB.text = @"retrying..";
                        }
                    }
                     */
                    
                    if ([message.retryState isEqualToNumber:@(RetryStatusType_three)])
                    {
                        cell.infoButton.hidden = NO;
                        cell.messageStatLB.text = @"Sending failed";
                    }
                    else if([message.isResending intValue] == 1
                            || [message.retryState isEqualToNumber:@(RetryStatusType_two)]){
                        cell.messageStatLB.text = @"Retrying..";
                    }
                    else{
                        cell.messageStatLB.text = @"Sending";
                    }
                }
                    break;
                    
                    
                case ChatStateType_Sent:
                    cell.messageStatLB.text = @"Sent";
                    break;
                    
                    
                case ChatStateType_Delivered:
                    cell.messageStatLB.text = @"Delivered";
                    break;
                    
                    
                case ChatStateType_Read:
                    cell.messageStatLB.text = @"Read";
                    break;
                    
                case ChatStateType_Notification_EmailSent:
                    
                    cell.messageStatLB.text = @"Notification sent";
                    
                    break;
                case ChatStateType_deliveredByReciever:
                    cell.messageStatLB.text = @"Delivered";
                    break;
                    
                    
                case ChatStateType_displayedByReciever:
                    cell.messageStatLB.text = @"Read";
                    break;
                    
                    
                case ChatStateType_NotDelivered:{
                    cell.messageStatLB.text = @"Not Delivered";
//                    [self tappedResendOfCell:cell atIndexPath:indexPath];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        
        if ([message.fileTypeChat boolValue])
        {
            cell.thumbImage = [UIImage imageWithData:[[message.thumb dataUsingEncoding:NSUTF8StringEncoding] xmpp_base64Decoded]];
            
            cell.attachmentImage.image = cell.thumbImage ;
            
            
            if (message.isOutbound)
            {
                switch ([message.requestStatus integerValue])
                {
                    case RequestStatusType_isYetToBeUpload:
                    {
                        @autoreleasepool {
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               FileUplader *obje=   [FileUplader createRequestWithChatMessage:message WithManagedObjectContext:[AppDel managedObjectContext_roster ]];
                                               
                                               (void)obje;
                                           });
                        }
                    }
                        
                        break;
                        
                    case RequestStatusType_uploading:
                    {
                        
                        
                        if ([message.dataSent integerValue] !=0 && [message.dataSent integerValue]<100)
                        {
                            cell.messageStatLB.text =  [NSString stringWithFormat:@"Sending %@ %%",message.dataSent];
                            
                            
                        }
                        else{
                            cell.infoButton.hidden = YES;
                            cell.messageStatLB.text =  [NSString stringWithFormat:@"Sending"];
                        }
                        
                        
                        break;
                    }
                        
                    case RequestStatusType_uploaded:
                    {
                        
                        switch ([message.chatState intValue])
                        {
                            case ChatStateType_Notification_EmailSent:
                                cell.messageStatLB.text = @"Notification sent";
                                break;
                            case ChatStateType_Delivered:
                                cell.messageStatLB.text = @"Delivered";
                                break;
                            case ChatStateType_Read:
                                cell.messageStatLB.text = @"Read";
                                break;
                            case ChatStateType_deliveredByReciever:
                                cell.messageStatLB.text = @"Delivered";
                                break;
                            case ChatStateType_displayedByReciever:
                                cell.messageStatLB.text = @"Read";
                                break;
                            case ChatStateType_Sent:
                                cell.messageStatLB.text = @"Sent";
                                
                            default:
                                cell.messageStatLB.text = @"Sent";
                                break;
                                
                        }
                        
                        break;
                    }
                        
                    case RequestStatusType_Failed:
                        
                        cell.infoButton.hidden = NO;
                        cell.messageStatLB.text = @"Sending failed";
                        
                        break;
                        
                        
                    default:
                        
                        break;
                }
            }
        }
        else
            
        {
            cell.lbl_messageContent.text =  [NSString stringWithFormat:@"%@",message.content];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd hh:mm a"];
        cell.timeLB.text = [formatter stringFromDate:message.timeStamp];
        cell.userNameLB.text = [[XMPPJID jidWithString:message.displayName] user];
        
        return cell;
    }
}


- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.chatTB)
    {
        ChatMessage *message = [[self chatController] objectAtIndexPath:indexPath];
        
        if ([[message fileTypeChat] boolValue])
        {
            return 240;
        }
    }

    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = [self.heightAtIndexPath objectForKey:indexPath];
    if(height)
    {
        return height.floatValue;
    }
    
    else
    {
        return UITableViewAutomaticDimension;
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *height = @(cell.frame.size.height);
    
    [self.heightAtIndexPath setObject:height forKey:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.chatTB != tableView)
    {
        if ([[self.searchUsers objectAtIndex:indexPath.row] isKindOfClass:[XMPPRoomObject class]])
        {
            XMPPRoomObject *room = [self.searchUsers objectAtIndex:indexPath.row];
            
            
            XMPPRoomObject *roomObj = [[[AppDel roomsArr] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", room.room_jidStr]] lastObject];
            
            
            if (roomObj == nil)
            {
                
                room.lastMessageDate=[NSDate date];
                
                [room.room addDelegate:AppDel delegateQueue:dispatch_get_main_queue()];
                
                [room.room activate:[AppDel xmppStream]];
                
                [room.room fetchRoomInfo];
                
                
                roomObj = room;
            }
            
            
            self.room = roomObj.room;
            
            
            self.roomObj = roomObj;
            
            self.jid=[XMPPJID jidWithString:self.roomObj.room_jidStr];
            
            
            self.isGroupChat = YES;
            
            
            self.forChat = YES;
            
            
            [self viewWillAppear:YES];
            
            
            [self.searchDisplayController setActive:NO animated:YES];
            
            
            return;
        }
        
        
        XMPPUserCoreDataStorageObject *user = [self.searchUsers objectAtIndex:indexPath.row];
        
        
        if ([AppDel isFromPhysician] == isPatient && [[[[user groups] anyObject] name] isEqualToString:@"Physician"])
        {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
            
            
            NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@" uri=%@ and identityuri=%@", user.jid.bare, [AppDel myJID] ];
            
            
            [request setPredicate:predicate];
            
            request.sortDescriptors = @[sorter];
            
            
            NSUInteger count = [[AppDel managedObjectContext_roster] countForFetchRequest:request error:nil];
            
            
            if (count != NSNotFound && count > 0)
            {
                if ([self.jids containsObject:user] == NO)
                {
                    [self.jids addObject:user];
                }
                
                
                [self checkandcreateroom];
                
                
                
                if (self.jids.count > 1)
                {
                    //The pencil should be displayed when a user adds a second person into the chat
                    editBtnIcon.hidden = NO;
                    
                    self.chatController = nil;
                }
                
                
                [self.searchDisplayController setActive:NO animated:YES];
                
                
                NSMutableString *names = [NSMutableString string];
                
                
                for (XMPPUserCoreDataStorageObject * users in self.jids)
                {
                    [names appendFormat:@"%@,", users.nickname];
                }
                
                
                searchbar.text = names;
                
                
                [self setUpScrollView];
                
                
                [self.chatTB reloadData];
            }
            
            else
            {
                [AppDel showSpinnerWithText:@""];
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 
                                                 @"checkSubscription", @"method",
                                                 
                                                 [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                                 
                                                 user.jid.user, @"physician_name",
                                                 
                                                 nil];
                    
                    
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
                    
                    [request setRequestMethod:@"POST"];
                    
                    [request addRequestHeader:@"Connection" value:@"close"];
                    
                    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                    
                    
                    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestDict options:0 error:nil];
                    
                    
                    [request setPostBody:[postData mutableCopy]];
                    
                    [request setValidatesSecureCertificate:NO];
                    
                    [request startSynchronous];
                    
                    
                    if ([request responseData])
                    {
                        NSDictionary *responsedict = [ NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingAllowFragments error:nil];
                        
                        dispatch_async(dispatch_get_main_queue(),^
                                       {
                                           
                                           [AppDel hideSpinner];
                                       } );
                        
                        
                        
                        
                        if ([[responsedict objectForKey:@"err-code"] intValue] == 1)
                        {
                            if ([self.jids containsObject:user] == NO)
                            {
                                [self.jids addObject:user];
                            }
                            
                            
                            [self checkandcreateroom];
                            
                            
                            if (self.jids.count > 1)
                            {
                                //The pencil should be displayed when a user adds a second person into the chat
                                editBtnIcon.hidden = NO;
                                
                                self.chatController = nil;
                            }
                            
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                
                                [self.searchDisplayController setActive:NO animated:YES];
                                
                                
                                [self setUpScrollView];
                                
                                
                                [self.chatTB reloadData];
                                
                                
                                [AppDel hideSpinner];
                                
                            });
                            
                            
                            
                        }
                        
                        else if ([[responsedict objectForKey:@"err-code"] intValue] == 600)    // Session expired
                        {
                            
                            [AppDel signOutFromAppSilent];
                            
                            
                            [[RDCallbackAlertView alloc] initWithTitle:nil message:[responsedict objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                             
                             {
                                 
                                 
                             } otherButtonTitles:@"OK", nil];
                        }
                        
                        else
                        {
                            [[RDCallbackAlertView alloc] initWithTitle:nil message:[responsedict objectForKey:@"message"] cancelButtonTitle:@"OK" andCompletionHandler:^(int btnIDX) {
                                
                                {
                                    
                                }
                                
                            } otherButtonTitles:@"Cancel", nil];
                        }
                    }
                });
            }
        }
        
        else
        {
            if ([self.jids containsObject:user] == NO)
            {
                [self.jids addObject:user];
            }
            
            
            [self checkandcreateroom];
            
            
            if (self.jids.count > 1)
            {
                //The pencil should be displayed when a user adds a second person into the chat
                editBtnIcon.hidden = NO;
                
                self.chatController = nil;
            }
            
            
            [self.searchDisplayController setActive:NO animated:YES];
            
            
            [self setUpScrollView];
            
            
            [self.chatTB reloadData];
        }
        
        
        [self.searchDisplayController.searchBar setHidden:YES];
    }
    
    else
    {
        ChatMessage *message = [[self chatController] objectAtIndexPath:indexPath];
        
        
        if ([message.fileTypeChat intValue] != fileTypeChat_message && [message.fileTypeChat intValue] != FileTextType_TextInGroup)
        {
            
            if([message.fileMediaType isEqualToString:@"image"])
            {
                AttachmentViewController *attachemtnVC = [[AttachmentViewController alloc] initWithNibName:@"AttachmentViewController" bundle:nil];
                
                attachemtnVC.url = message.content;
                
                [self.navigationController pushViewController:attachemtnVC animated:YES];
            }
            else
            {
                AttachmentWebViewController *attachemtnVC = [[AttachmentWebViewController alloc] initWithNibName:@"AttachmentWebViewController" bundle:nil];
                
                attachemtnVC.url = message.content;
                
                [self.navigationController pushViewController:attachemtnVC animated:YES];
            }
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.chatTB)
    {
        return NO;
    }
    
    return YES;
}


- (void)tableView:(UITableView *)tableView1 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView1 == self.chatTB)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            ChatMessage *chatToDel = [[self chatController] objectAtIndexPath:indexPath];
            
            chatToDel.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               
                               NSError *error = nil;
                               
                               
                               if (![[AppDel managedObjectContext_roster] save:&error])
                               {
                                   NSLog(@"%@", [error domain]);
                               }
                               else{
                                   [self.chatTB reloadData];
                               }
                               
                           });
        }
        
        else if (editingStyle == UITableViewCellEditingStyleInsert)
        {
            
        }
    }
}


#pragma mark - STBubbleTableView

- (CGFloat)minInsetForCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        return 100.0f;
    }
    
    
    return 50.0f;
}

/*
 - (void)tappedImageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
 {
 
 }
 */

- (void)tappedDetailOfMessageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DetailOfMessageViewController *mfVC = [[DetailOfMessageViewController alloc] initWithNibName:@"DetailOfMessageViewController" bundle:nil];
    mfVC.chatMessage = cell.message;
    
    [self.navigationController pushViewController:mfVC animated:YES];
    
}


- (void)tappedForwardOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MessageForwardViewController *mfVC = [[MessageForwardViewController alloc] initWithNibName:@"MessageForwardViewController" bundle:nil];
    
    mfVC.forChat = NO;
    
    mfVC.forwardMessage = cell.message;
    
    [self.navigationController pushViewController:mfVC animated:YES];
}


- (void)tappedResendOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *messageResend = cell.message;
    
    
    if ([[messageResend isRoomMessage] boolValue] == YES)
    {
        XMPPRoom *room = [[XMPPRoom  alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:self.room.roomJID];
        
        [room addDelegate:AppDel delegateQueue:dispatch_get_main_queue()];
        
        [room activate:[AppDel xmppStream]];
        
        
        self.room = room;
        
        [self.room fetchRoomInfo];
        
        
        double delayInSeconds = 2.0;
        
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            messageResend.chatState = [NSNumber numberWithInteger:ChatStateType_Sending];
            
            
            XMPPMessage *message = [XMPPMessage message];
            
            [message addAttributeWithName:@"from" stringValue:messageResend.identityuri];
            
            [message addAttributeWithName:@"id" stringValue:messageResend.messageID];
            
            [message addAttributeWithName:@"to" stringValue:messageResend.uri];
            
            [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"messageResend>>groupchat" Content:messageResend.messageID parameter:[ChatMessage ChatTypeToStr:messageResend.chatState.intValue]];
            
            //*******************
            
            @autoreleasepool {
                VCard * vcard=[AppDel fetchVCard:[XMPPJID jidWithString:messageResend.uri]];
                
                
                (void)vcard;
            }
            
            {
                NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:messageResend.content,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",messageResend.identityuri,@"from",messageResend.uri,@"to",messageResend.messageID,@"messageID", nil];
                
                
                
                NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                
                [message addChild:body];
                
                [message addProperty:@"message_version" value:@"2.0" type:@"string"];
            }
            
            
            [[AppDel xmppStream] sendElement:message];
        });
    }
    
    else
    {
        messageResend.isResending=[NSNumber numberWithBool:YES];
        messageResend.retryState = @(RetryStatusType_one);
        
        //Update the cell which resends
        dispatch_async(dispatch_get_main_queue(), ^{
            //update UI in main thread.
            [self.chatTB beginUpdates];
            [self.chatTB reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            [self.chatTB endUpdates];
        });
        
        [AppDel resendMessage:messageResend];
        [AppDel recheckAndResendMessage:messageResend];
    }
}


- (void)tappedInfoOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *messageResend = cell.message;
    
    ReadByViewController *readBy = [[ReadByViewController alloc] initWithNibName:@"ReadByViewController" bundle:nil];
    
    readBy.msg = messageResend;
    
    
    [self.navigationController pushViewController:readBy animated:YES];
}


#pragma mark - Search Delegate

/*
 - (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
 {
 
 }
 */


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSArray *jids = [searchString componentsSeparatedByString:@","];
    
    NSString *str = [jids lastObject];
    
    if (str)
    {
        [self search:str];
        searchLB.text = str;
    }
    
    return YES;
}


- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    controller.searchBar.hidden = YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar setHidden:YES];
    
    
    if (searchBar.text.length > 0)
    {
        NSMutableString *names = [NSMutableString string];
        
        
        for (XMPPUserCoreDataStorageObject *users in self.jids)
        {
            [names appendFormat:@"%@,", users.nickname];
        }
        
        
        searchbar.text = names;
        
        
        [self.chatTB reloadData];
    }
    
    else
    {
        [self.jids removeAllObjects];
        
        
        self.chatController.delegate = nil;
        
        
        self.chatController = nil;
        
        
        [self.chatTB reloadData];
    }
}

#pragma mark - Active Download...

- (void)startIconDownload:(NSInteger)indexPath withImagePath:(NSString *)path
{
    
}

- (void)appImageDidLoad:(NSString *)URLString forIndex:(NSInteger)index withPath:(NSString *)path
{
    
}

#pragma mark - Room

- (void)createRoom
{
    [AppDel showSpinnerWithText:@""];
    
    
    NSString *roomName = [NSString  stringWithFormat:@"%@_%lld@%@", [[[AppDel xmppStream] myJID] user], (long long)[[NSDate date] timeIntervalSince1970], @"newconversation.imyourdoc.com"];
    
    
    self.room = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage  sharedInstanse] jid:[XMPPJID jidWithString:roomName]];
    
    
    self.jid=self.room.roomJID;
    
    
    [self.room activate:[AppDel xmppStream]];
    
    
    dispatch_queue_t que1 = dispatch_get_main_queue();
    
    
    
    [self.room addDelegate:AppDel delegateQueue:que1];
    
    [self.room addDelegate:self delegateQueue:que1];
    
    [self.room joinRoomUsingNickname:[[[AppDel xmppStream] myJID] user] history:nil];
}


- (void)sendMessageToRoom:(NSString *)text
{
    XMPPMessage *message = [XMPPMessage message];
    
    NSString *messageID =  [[AppDel xmppStream] generateUUID];
    
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
    
    [message addAttributeWithName:@"to" stringValue:self.room.roomJID.bare];
    
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    @autoreleasepool {
        VCard * vcard=[AppDel fetchVCard:[XMPPJID jidWithString:self.room.roomJID.bare]];
        (void)vcard;
    }
    
    {
        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:text,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",[[[AppDel xmppStream] myJID] bare],@"from",self.room.roomJID.bare,@"to",messageID,@"messageID", nil];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
        
        [message addChild:body];
        
        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
    }
    
    [[AppDel xmppStream] sendElement:message];
    
    
    ChatMessage *chat   = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:[AppDel managedObjectContext_roster]];
    
    chat.messageID      = messageID;
    
    chat.identityuri    = [AppDel myJID];
    
    chat.uri            = [message.to bare];
    
    chat.displayName    = [[[AppDel xmppStream] myJID] bare];
    
    chat.isRoomMessage  = [NSNumber numberWithBool:YES];
    
    chat.content        = text;
    
    chat.fileTypeChat = [NSNumber numberWithInt:fileTypeChat_message];
    
    chat.timeStamp      = [NSDate date];
    
    chat.outbound       = [NSNumber numberWithBool:OutBoundType_Right];
    
    chat.mark_deleted = [NSNumber numberWithBool:mark_deleted_NO];
    
    chat.lastResend=[NSDate date];
    
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"addInboxMessage" Content:chat.messageID parameter: [ChatMessage ChatTypeToStr:[chat.chatState intValue]]];
    
    [AppDel addInboxMessage:chat];
    
    
    if([[AppDel managedObjectContext_roster] hasChanges])
        [[AppDel managedObjectContext_roster] save:nil];
    
    [AppDel addTimerForMessage:messageID];
    
}


- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    [sender fetchConfigurationForm];
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm;
{
    NSXMLElement *newConfig = [configForm copy];
    
    
    NSString *name = @"Group chat 1";
    
    name = [barTitleLbl text];
    
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        
        
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"])
        {
            [field removeChildAtIndex:0];
            
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        
        
        if ([var isEqualToString:@"muc#roomconfig_roomname"])
        {
            [field removeChildAtIndex:0];
            
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:name]];
        }
        
        
        if ([var isEqualToString:@"muc#register_roomnick"])
        {
            [field removeChildAtIndex:0];
            
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:name]];
        }
    }
    
    
    NSXMLElement *filed = [NSXMLElement elementWithName:@"field"];
    
    [filed addAttributeWithName:@"var" stringValue:@"muc#roomconfig_getmemberlist"];
    
    [filed addChild:[NSXMLElement elementWithName:@"value" stringValue:@"moderator"]];
    
    [filed addChild:[NSXMLElement elementWithName:@"value" stringValue:@"participant"]];
    
    [filed addChild:[NSXMLElement elementWithName:@"value" stringValue:@"visitor"]];
    
    
    [configForm addChild:filed];
    
    
    [sender configureRoomUsingOptions:newConfig];
    
    
    XMPPMessage *message = [XMPPMessage message];
    
    
    NSString *messageID =  [[AppDel xmppStream] generateUUID];
    
    
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
    
    [message addAttributeWithName:@"to" stringValue:self.room.roomJID.bare];
    
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    
    NSXMLElement *subject = [NSXMLElement elementWithName:@"subject" stringValue:barTitleLbl.text];
    
    
    [message addChild:subject];
    
    
    [[AppDel xmppStream] sendElement:message];
    
    if (self.jids.count > 1)
    {
        [sender addMembers:self.jids];
    }
    
    
    if (add_members_taped == YES)
    {
        [sender addMembers:[NSArray arrayWithObjects:self.user, nil]];
    }
}


- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    self.chatController = nil;
    
    self.jid=sender.roomJID;
    
    self.roomObj = [AppDel fetchRoom:self.jid.bare];
    
    
    [self.chatTB reloadData];
}


- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to create group." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    
    self.room = nil;
    
    [AppDel hideSpinner];
}


- (void)xmppRoom:(XMPPRoom *)sender didAddMember:(XMPPElement *)info
{
    [AppDel hideSpinner];
    
    
    if (add_members_taped == YES)
    {
        add_members_taped = NO;
        
        
        self.isGroupChat = YES;
        
        
        self.user = nil;
        
        
        [self.jids removeAllObjects];
        
        
        self.chatController = nil;
        
        
        GroupMembersViewController *groupMember = [[GroupMembersViewController alloc] initWithNibName:@"GroupMembersViewController" bundle:nil];
        
        
        if (self.roomObj == nil)
        {
            self.roomObj = [[[AppDel roomsArr] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [self.room.roomJID bare]]] lastObject];
            
            
            if (self.roomObj == nil)
            {
                self.roomObj = [AppDel fetchOrInsertRoom:self.room];
            }
        }
        
        
        groupMember.roomObj = self.roomObj;
        
        groupMember.xmppRoom = sender;
        
        
        [self.navigationController pushViewController:groupMember animated:YES];
    }
}


- (void)checkandcreateroom
{
    if ([self.jids count] > 1)
    {
        if (self.room == nil)
        {
            [self createRoom];
        }
        
        else
        {
            if (self.jids.count > 0)
            {
                [AppDel showSpinnerWithText:@""];
                
                
                [self.room addMembers:self.jids];
            }
            
            
            XMPPRoomObject *roomObj = [AppDel fetchOrInsertRoom:self.room];
            
            roomObj.isPatient = [NSNumber numberWithBool:YES];
            
            
            for (XMPPUserCoreDataStorageObject * user in self.jids)
            {
                if ([user isKindOfClass:[XMPPUserCoreDataStorageObject class]])
                {
                    if ([user.groups filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name='PATIENT'"]])
                    {
                        roomObj.isPatient = [NSNumber numberWithBool:YES];
                    }
                }
            }
        }
    }
}


#pragma mark - Chat State



- (void)receiveChatNotification:(NSNotification *)notify
{
    if (self.jids.count == 1)
    {
        XMPPJID *jid = [XMPPJID jidWithString:[[notify userInfo] objectForKey:@"BuddyID"]];
        
        
        if ([[(XMPPJID*)[[self.jids lastObject] jid] bare] isEqualToString:jid.bare])
        {
            if ([[[notify userInfo] objectForKey:@"chatNotificationState"] isEqualToString:@"Inactive"] || [[[notify userInfo] objectForKey:@"chatNotificationState"] isEqualToString:@"gone"])
            {
                chatNotification.hidden = TRUE;
                
                chatNotification.text = @"";
            }
            
            else
            {
                chatNotification.hidden = FALSE;
                
                chatNotification.text = [[notify userInfo] objectForKey:@"chatNotificationState"];
            }
        }
    }
    
    else
    {
        XMPPJID *jidTyper = [XMPPJID jidWithString:[[notify userInfo] objectForKey:@"BuddyID"]];
        
        
        if ([[self.room.roomJID bare] isEqualToString:[jidTyper bare]])
        {
            if ([[[notify userInfo] objectForKey:@"chatNotificationState"] isEqualToString:@"Inactive"] || [[[notify userInfo] objectForKey:@"chatNotificationState"] isEqualToString:@"gone"])
            {
                chatNotification.hidden = TRUE;
                
                chatNotification.text = @"";
            }
            
            else
            {
                chatNotification.hidden = FALSE;
                
                chatNotification.text = [[notify userInfo] objectForKey:@"chatNotificationState"];
            }
        }
    }
}

#pragma mark local notification

- (void)receiveLoadOlderMessagesNotification:(NSNotification *)notify
{
    
    [btn_LoadOlderMessages setTitle:@"Load Older Messages..." forState:UIControlStateNormal];
    btn_LoadOlderMessages.userInteractionEnabled=YES;
    
    [self performSelector:@selector(setTableViewAtTop) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
    
    
}
- (void)receiveLoadOlderMessagesWithIncreaseCountNotification:(NSNotification *)notify
{
//    [self performSelector:@selector(action_loadMessage_buttonLoadMoreTouchedAutommaticallyStep2) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
    
    
}

- (void)receiveLoadOlderMessagesNotificationForGroup:(NSNotification *)notify
{
    
//    [btn_LoadOlderMessages setTitle:@"Load Older Messages..." forState:UIControlStateNormal];
//    btn_LoadOlderMessages.userInteractionEnabled=YES;
//    _chatTB.tableHeaderView.hidden=YES;
//    [_chatTB.tableFooterView layoutIfNeeded];
    
    
    
}
#pragma mark Local Notification LoadEalier Message GroupChat


#pragma mark - Message

- (void) sendMessage: (NSString *) msgContent
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    
    
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    
    if (networkStatus != NotReachable)
    {
        static NSDateFormatter *dateFormatter = nil;
        
        
        if (dateFormatter == nil)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        }
        
		      
        NSTimeInterval today = ([[NSDate date] timeIntervalSince1970] * 1000);
        
        
        NSString *intervalString = [NSString stringWithFormat:@"%f", today];
        
        
        NSArray *absoluteTime = [intervalString componentsSeparatedByString:@"."];
        
        if ([self.jids count] == 1)                // -------------- One To One Chat
        {
            XMPPUserCoreDataStorageObject *user = [self.jids objectAtIndex:0];
            
            
            ChatMessage *msg1 = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:[AppDel managedObjectContext_roster]];
            
            msg1.lastResend=[NSDate date];
            
            
            NSString *to = self.jid.bare;
            
            
            if (self.jid == nil)
            {
                to = user.jid.bare;
            }
            
            
            NSString *msgIdForChatMsg = [[AppDel xmppStream] generateUUID];
            
            if(msgIdForChatMsg.length==0)
                msgIdForChatMsg=[NSString stringWithFormat:@"%@-%@-%@", [absoluteTime objectAtIndex:0], to, [[[AppDel xmppStream] myJID] bare]];
            
            msg1.messageID       = msgIdForChatMsg;
            
            msg1.lastResend=[NSDate date];
            
            msg1.chatState       = [NSNumber numberWithInt:ChatStateType_Sending];
            
            msg1.identityuri     = [AppDel myJID];
            
            msg1.content         = msgContent;
            
            msg1.isOutbound      = OutBoundType_Right;
            
            msg1.hasBeenRead     = NO;
            
            msg1.timeStamp       = [NSDate date];
            
            msg1.uri             = [self.jid bare];
            
            msg1.displayName     = [self.jid bare];
            
            if (self.jid == nil)
            {
                msg1.uri         =  [user.jid bare];
                
                msg1.displayName = [user.jid bare];
            }
            
            
            msg1.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_message];   ;
            
            msg1.requestStatus   = [NSNumber numberWithInt:RequestStatusType_uploading];
            
            msg1.mark_deleted   = [NSNumber numberWithBool:mark_deleted_NO];
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"SendMessage" Content:msg1.messageID parameter:[ChatMessage ChatTypeToStr:[msg1.chatState intValue]]];
            
            [AppDel addInboxMessage:msg1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *error = nil;
                
                
                if (![[AppDel managedObjectContext_roster] save:&error])
                {
                    NSLog(@"%@", [error domain]);
                }
            });
            
            [AppDel sendMsg:msgContent toIMYourDocUser:msg1.uri withMessageID:msgIdForChatMsg];
            
            [AppDel leoResendInQueueWithChatMessage:msg1.messageID];
        }
        
        else                // -------------- Multi-Room Chat
        {
            
            if (self.room) {
                [self sendMessageToRoom:msgContent];
            }
            else{
                if (self.jids.count > 0) {
                    [self createRoom];
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Please specify at least one recipient in To: before sending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }
        }
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)sendUserChatNotification:(SendChatStateType)chatNotificationType;
{
    if (self.jids.count == 1)
    {
        XMPPUserCoreDataStorageObject *user = [self.jids objectAtIndex:0];
        
        [AppDel sendChatState:chatNotificationType withBuddy:[user.jid bare] withMessageID:@"noIDRequired" isGroupChat:NO];
    }
    
    else
    {
        [AppDel sendChatState:chatNotificationType withBuddy:[self.room.roomJID bare] withMessageID:@"noIDRequired" isGroupChat:YES];
    }
}


#pragma mark - Image Picker

- (void)imagePickerController:(UIImagePickerController *)picker_t didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *fileName =  [[[AppDel xmppStream] generateUUID] stringByAppendingPathExtension:@"jpg"];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSData *imageD = UIImageJPEGRepresentation(image, .7);
    
    [imageD writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] atomically:YES];
    
    ChatMessage *message    = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:[AppDel managedObjectContext_roster]];
    
    
    message.lastResend=[NSDate date];
    
    message.messageID       =  [[AppDel xmppStream] generateUUID];
    
    message.identityuri     = [AppDel myJID];
    
    message.uri             = [self.jid bare];
    
    if (self.jids.count == 1)
    {
        if (self.jid == nil)
        {
            message.uri         = [(XMPPJID*)[[self.jids lastObject] jid] bare];
        }
        
        message.displayName     = message.uri;
    }
    
    else
    {
        if (self.jid == nil)
        {
            message.uri         = [[self.room roomJID] bare];
        }
        
        message.displayName     = [AppDel myJID];
        
        message.isRoomMessage   = [NSNumber numberWithBool:YES];
    }
    
    message.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
    
    message.isOutbound      = OutBoundType_Right;
    
    message.requestStatus   = [NSNumber numberWithInt:RequestStatusType_isYetToBeUpload];
    
    message.content         = fileName;
    
    message.thumb           = [UIImageJPEGRepresentation([self resizeImage:image newSize:CGSizeMake(500, 500) imageOrientation:(picker_t.sourceType==UIImagePickerControllerSourceTypeCamera?UIImageOrientationRight:UIImageOrientationUp)], 1) xmpp_base64Encoded];
    
    message.timeStamp       = [NSDate date];
    
    message.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
    
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"addInboxMessage" Content:message.messageID parameter:[ChatMessage ChatTypeToStr:[message.chatState intValue]]];
    
    [AppDel addInboxMessage:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *error = nil;
        
        
        if (![[AppDel managedObjectContext_roster] save:&error])
        {
            NSLog(@"%@", [error domain]);
        }
    });
    
    [picker_t dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)removeUserView:(UIButton *)sender
{
    [self.searchDisplayController setActive:NO animated:YES];
    
    
    [self.jids removeObject:[(UserSubView *)[[sender superview] superview] user]];
    
    
    [self setUpScrollView];
}


#pragma mark - Notification

- (void)textChanged:(NSNotification *)notification
{
    if ([[msgTV text] length] == 0)
    {
        CameraBtn.hidden = NO;
        
        SendButton.hidden = YES;
        
//        [self sendUserChatNotification:SendChatStateType_gone2];
    }
    
    else
    {
        CameraBtn.hidden = YES;
        
        SendButton.hidden = NO;
        
//        [self sendUserChatNotification:SendChatStateType_composing1];
    }
}


#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [barTitleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [titleTF setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [barTitleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:17.00]];
        
        [titleTF setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:17.00]];
    }
}
#pragma mark- Load old data  Data From Server
-(void)addrefreshControlToChatTable{
    
    _chatTB.tableHeaderView=view_loadmore;
    _chatTB.tableHeaderView.hidden=NO;
    
}

- (void)loadMessageListDefault_onceStep1
{
    if ([ConversationLog getUnreadCountConversationLogMYJiD:[AppDel myJID] WithJID:[self.user.jid bare] withContext:[AppDel managedObjectContext_roster]]!=0)
    {
        
        _chatTB.tableHeaderView.hidden=NO;
        [_chatTB.tableFooterView layoutIfNeeded];
    }
    else{
        _chatTB.tableHeaderView.hidden=YES;
        [_chatTB.tableFooterView layoutIfNeeded];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([ConversationLog getUnreadCountConversationLogMYJiD:[AppDel myJID] WithJID:[self.user.jid bare] withContext:[AppDel managedObjectContext_roster]]==0)
        {
            _chatTB.tableHeaderView.hidden=YES;
            [_chatTB.tableFooterView layoutIfNeeded];
        }
        else{
            _chatTB.tableHeaderView.hidden=NO;
            [_chatTB.tableFooterView layoutIfNeeded];
        }
    });
    
    
    _chatTB.tableHeaderView.hidden=NO;
}


- (IBAction)action_loadMessage_buttonLoadMoreTouched:(UIButton*)sender
{
    
    if(self.user.jidStr||self.roomObj.room_jidStr )
    {
        ChatMessage * firstMessage =   [ChatMessage getfirstMessageWithjid: self.isGroupChat? self.roomObj.room_jidStr :self.user.jidStr];
        
        [AppDel showSpinnerWithText:@"Requesting..."];
        
        
        NSString* strConversationIDName;
        NSInteger groupMembersNum = 0;
        
        if (self.isGroupChat){
            strConversationIDName = [[self.roomObj.room_jidStr componentsSeparatedByString:@"@"] objectAtIndex:0];
            groupMembersNum = self.roomObj.members.count;
        }
        else{
            strConversationIDName = [[self.user.jidStr componentsSeparatedByString:@"@"] objectAtIndex:0];
        }
        
        [[AppData appData] fetchMessageThreadsWithConversationIDName:strConversationIDName
                                                   andFirstMessageID:firstMessage.messageID
                                                         isOneORRoom:!self.isGroupChat
                                                             success:^(BOOL isMore) {
                                                                 
                                                                 [AppDel hideSpinner];
                                                                 
                                                                 if (!isMore) {
                                                                     _chatTB.tableHeaderView.hidden=YES;
                                                                 }
                                                                
                                                                 
                                                             } failure:^(NSError *error) {
                                                                 
                                                                 [AppDel hideSpinner];
                                                                 
                                                                 
                                                             }];
    }
    
}


- (void)action_loadMessage_buttonLoadMoreTouchedAutommaticallyStep2
{
    if ([ConversationLog getUnreadCountConversationLogMYJiD:[AppDel myJID] WithJID:[self.user.jid bare] withContext:[AppDel managedObjectContext_roster]]==0)
    {
        _chatTB.tableHeaderView.hidden=YES;
    }
    
    else
    {
        _chatTB.tableHeaderView.hidden=NO;
        
        [btn_LoadOlderMessages setTitle:@"   Loading..." forState:UIControlStateNormal];
        
        btn_LoadOlderMessages.userInteractionEnabled=NO;
        
    }
}

#pragma mark - Service Response
-(void)service_ReportCloseConversationWithjid:(NSString*)jid{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"reportCloseConversation", @"method",
                          jid, @"jid",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_ReportCloseConversation delegate:self];
    
    
}
- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    if ([WebHelper sharedHelper].tag == S_ShowRequestList)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {  [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    
    
    else if ([WebHelper sharedHelper].tag == S_SubscribeUser)
    {
        [AppDel hideSpinner];
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 700)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
    }
    else if ([WebHelper sharedHelper].tag==S_ReportCloseConversation)
    {
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 700)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    }
    
    
}
- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark --ThumbNail code


- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize imageOrientation:(UIImageOrientation)imageOrientation  {
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > newSize.width || height > newSize.height) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = newSize.width;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = newSize.height;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
