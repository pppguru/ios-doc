//
//  MessageInboxViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 22/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "APIManager.h"
#import "MessageInboxCell.h"
#import "ChatViewController.h"
#import "InboxMessage+ClassMethods.h"
#import "MessageInboxViewController.h"
#import "BroadcastRecieverChatViewController.h"




@interface MessageInboxViewController () <  UITextFieldDelegate>
{
    BOOL bool_search;
    NSString *str_search;
    
    BOOL isLoadingMoreThread;
}
@end


@implementation MessageInboxViewController
@synthesize txt_search,lbl_syncing,messageFetchController;

#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [ChatMessage deleteEmptyJIDRowFromInboxAndChatTable];
    [InboxMessage changeLastUpdateForInboxMessages];
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateTransferArrayUpdateNotification:) name:@"KstateTransferArrayUpdateNotification" object:nil];
    
    isLoadingMoreThread = NO;
}


- (void)stateTransferArrayUpdateNotification:(NSNotification *)notify
{
        lbl_syncing.text=@"";
        lbl_syncing.hidden=YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [ChatMessage deleteEmptyJIDRowFromInboxAndChatTable];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.secureDelegate = self;

        lbl_syncing.hidden=YES;
    
    [self setRequiredFont2];
    
    [self loadTableViewAndResetSearchField];

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
    
    [messagesTB reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
    
	[self searchViewAttribute];
}

#pragma mark - IBAction

- (IBAction)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if ([[self.messageFetchController sections] count] > 0 ) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.messageFetchController sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    
    return rows;
    
    /*
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.messageFetchController sections] objectAtIndex:section];
    
    
    return [sectionInfo numberOfObjects];
     */
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageInboxCell"];

	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageInboxCell" owner:self options:nil] lastObject];
        cell.userImg.layer.cornerRadius = 26;
        cell.userImg.layer.backgroundColor = [[UIColor clearColor] CGColor];
        [cell.userImg.layer setMasksToBounds:YES];
    }
    
    //Set default display options
    cell.greenNotifyIcon.hidden = YES;
    cell.msgCountLbl.hidden = YES;
    cell.msgNotifyIcon.hidden = YES;
    

    InboxMessage *inboxMessage = [ self.messageFetchController objectAtIndexPath:indexPath];
    
    //Set Unread message count
    if (inboxMessage.numberOfUnReadMessages > 0)
    {
        cell.msgCountLbl.hidden = NO;
        cell.msgNotifyIcon.hidden = NO;
        cell.msgCountLbl.text = [NSString stringWithFormat:@"%ld", (long)inboxMessage.numberOfUnReadMessages];
    }
    
    
    //Set the last updated date
    NSDateFormatter *dateFomatter = [NSDateFormatter new];
    dateFomatter.dateFormat = @"EEE MM-dd-YY hh:mm";
    cell.dateLbl.text = [dateFomatter stringFromDate:inboxMessage.lastUpdated];
    
    //Set the user name label
    cell.userNameLbl.textColor = [UIColor colorWithRed:156.0/255.0 green:205.0/255.0 blue:33.0/255 alpha:1];
  
    
    NSPredicate *pre=nil;
    if (str_search>0)
    {
        pre=[NSPredicate predicateWithFormat:@"content  contains[cd] %@ AND  mark_deleted == 0 ",str_search] ;
        if( [[inboxMessage.message filteredOrderedSetUsingPredicate:pre ]count]<1)
            pre=[NSPredicate predicateWithFormat:@"mark_deleted == 0  and content!=%@ ",[NSString stringWithFormat:@"~$^^xxx*xxx~$^^"]] ;
    }
    else{
        pre=[NSPredicate predicateWithFormat:@"mark_deleted == 0 and content!=%@ ",[NSString stringWithFormat:@"~$^^xxx*xxx~$^^"]] ;
    }
    

    ChatMessage * messawge= [[[inboxMessage.message filteredOrderedSetUsingPredicate:pre]
                                                    sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]]] lastObject];

    NSString *text = messawge ? messawge.content : @"";
    if(!text || !text.length )
        NSLog(@"Message has empty content: %@", messawge);

    

    if ([[inboxMessage messageType] boolValue])  //-------------------  If Group Chat --------------------- //
    {
        XMPPRoomObject *room = inboxMessage.room;
        
        //Set the name of thread with room name
        if (room.name == nil)
            cell.userNameLbl.text = [[XMPPJID jidWithString:inboxMessage.jidStr] user];
        else
            cell.userNameLbl.text = room.name;
        

        // Attribute String to messages
        if (str_search.length>0)
        {
            
            // If attributed text is supported (iOS6+)
            if ([cell.msgLbl respondsToSelector:@selector(setAttributedText:)])
            {
                
                // Define general attributes for the entire text
                NSDictionary *attribs = @{
                                          NSForegroundColorAttributeName: cell.msgLbl.textColor,
                                          NSFontAttributeName: cell.msgLbl.font
                                          };
                NSMutableAttributedString *attributedText =
                [[NSMutableAttributedString alloc] initWithString:text
                                                       attributes:attribs];
                
                // Red text attributes
                UIColor *blueColor = [UIColor blueColor];
                
                NSRange redTextRange = [text rangeOfString:str_search options:NSCaseInsensitiveSearch];
                // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
                
                
                
                
                
                [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  cell.msgLbl.font}
                                        range:redTextRange];
                cell.msgLbl.attributedText = attributedText;
                
            }
            else{
                cell.msgLbl.text = text;
             }
            
            
        }
        else{
            cell.msgLbl.text = text;
        }
        
        
        if ([messawge.fileTypeChat boolValue])
        {
            if(messawge.fileMediaType)
                cell.msgLbl.text=messawge.fileMediaType;
            else
            cell.msgLbl.text = @"image";
        }
        
        
        if ([room isPatientRoom] == 0)
        {
            cell.userImg.image = [UIImage imageNamed:@"group_profile"];
        }
        
        else
        {
            cell.userNameLbl.textColor = [UIColor colorWithRed:255/255.0 green:84.0/255.0 blue:57.0/255.0 alpha:1];
            
            cell.userImg.image = [UIImage imageNamed:@"red_group_profile"];
            
            cell.greenNotifyIcon.hidden = NO;
        }
    }
    else if ([inboxMessage.chatMessageTypeOf integerValue ] == ChatMessageType_Broadcast)
    {


        cell.userNameLbl.textColor=[UIColor blueColor];
        cell.userImg.image=[UIImage imageNamed:@"bc_profile_icon"];
      
        cell.userNameLbl.text=messawge.bcSubject;
        
        
        // Attribute String to messages
        
        if (str_search.length>0)
        {
            
            // If attributed text is supported (iOS6+)
            if ([cell.msgLbl respondsToSelector:@selector(setAttributedText:)])
            {
                
                // Define general attributes for the entire text
                NSDictionary *attribs = @{
                                          NSForegroundColorAttributeName: cell.msgLbl.textColor,
                                          NSFontAttributeName: cell.msgLbl.font
                                          };
                NSMutableAttributedString *attributedText =
                [[NSMutableAttributedString alloc] initWithString:text
                                                       attributes:attribs];
                
                // Red text attributes
                UIColor *blueColor = [UIColor blueColor];
                
                NSRange redTextRange = [text rangeOfString:str_search options:NSCaseInsensitiveSearch];
                // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
                
                
                
                
                
                [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  cell.msgLbl.font}
                                        range:redTextRange];
                cell.msgLbl.attributedText = attributedText;
                
            }
            else{
                cell.msgLbl.text = text;
            }
            
            
        }
        else{
            cell.msgLbl.text = text;
        }
        
        
        
        
    }
    else
    {
        XMPPUserCoreDataStorageObject *user = [AppDel fetchUserForJIDString:inboxMessage.jidStr];
        
        if (user)
        {
            
            if([[user.subscription lowercaseString] isEqualToString:@"both"]==NO)
            {
                
                for (ChatMessage * messages in inboxMessage.message) {
                
                    messages.mark_deleted=[NSNumber numberWithBool:YES];
                    
                }
                
                [[AppDel managedObjectContext_roster] deleteObject:inboxMessage];
                
                [[AppDel managedObjectContext_roster] save:nil];
            }
            if ([[[[user.groups anyObject] name] uppercaseString] isEqualToString:@"PATIENT"])
            {
                cell.userNameLbl.textColor = [UIColor colorWithRed:255/255.0 green:84.0/255.0 blue:57.0/255.0 alpha:1];
            }
            
            
            VCard *vCard = [AppDel fetchVCard:user.jid];
            
            cell.userNameLbl.text = user.nickname;
            if (vCard.name != nil)
            {
                cell.userNameLbl.text = vCard.name;
            }
            
     
         // Attribute String to messages
            if (str_search.length>0)
            {
                // If attributed text is supported (iOS6+)
                if ([cell.msgLbl respondsToSelector:@selector(setAttributedText:)])
                {
                    
                    // Define general attributes for the entire text
                    NSDictionary *attribs = @{
                                              NSForegroundColorAttributeName: cell.msgLbl.textColor,
                                              NSFontAttributeName: cell.msgLbl.font
                                              };
                    NSMutableAttributedString *attributedText =
                    [[NSMutableAttributedString alloc] initWithString:text
                                                           attributes:attribs];
                    
                    // Red text attributes
                    UIColor *blueColor = [UIColor blueColor];
                  
                    NSRange redTextRange = [text rangeOfString:str_search options:NSCaseInsensitiveSearch];
                    // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
                   
                    
                    
           
                    
                    [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  cell.msgLbl.font}
                                            range:redTextRange];
                    cell.msgLbl.attributedText = attributedText;
                    
                    
                    
                  
                    
                    
                    
                    
                    
                }
                else{
                    cell.msgLbl.text = text;
                }
                
                
            }
            else{
                
                
                cell.msgLbl.text = text;
            }
            
            
            
            if ([messawge.fileTypeChat boolValue])
            {
                if(messawge.fileMediaType)
                    cell.msgLbl.text=messawge.fileMediaType;
                else
                    cell.msgLbl.text = @"image";
            }
            
            
            cell.userImg.image = user.photo;
            
            
            if (cell.userImg.image == nil)
            {
                cell.userImg.image = [UIImage imageNamed:@"Profile"];
            }
        }
        
        else
        {
            cell.userNameLbl.text = [[XMPPJID jidWithString:inboxMessage.jidStr] user];
            
            cell.msgLbl.text = text;
            
            cell.userImg.image = [UIImage imageWithData:[[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:inboxMessage.jidStr]]];
            
            
            if (cell.userImg.image == nil)
            {
                cell.userImg.image = [UIImage imageNamed:@"Profile"];
            }
        }
    }
    
    
    //---------------------------  Load more message threads  ---------------------------
    
    NSString *strPageStored = [[NSUserDefaults standardUserDefaults] objectForKey:@"page"];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.messageFetchController sections] objectAtIndex:indexPath.section];
    NSInteger allCounts = [sectionInfo numberOfObjects];
        
    if (!isLoadingMoreThread
        && indexPath.row == allCounts - 1
        && ![strPageStored containsString:@"end"]
        && indexPath.row >= [[tableView visibleCells] count])
    {
        
        isLoadingMoreThread = YES;
        [[APIManager sharedJSONManager] threadRequest:^(ThreadResponseModel *responseModel)
         {
             isLoadingMoreThread = NO;
             
             if (responseModel.content.count < 10)
             {
                 NSString *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"page"];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:[temp stringByAppendingString:@"end"] forKey:@"page"];
             }
             
             NSOperationQueue *opQueue2 = [NSOperationQueue new];
             NSMutableArray *ops = [NSMutableArray new];
             
             for (ThreadContentModel *content in responseModel.content)
             {
                 //Add Inbox Object
                 InboxMessage *inboxMsg = [AppDel addInboxMessageWithThreadModel:content];
                 
                 if (inboxMsg == nil) {
                     continue;
                 }
                 
                 NSBlockOperation *block2 = [NSBlockOperation new];
                 
                 if ([content.type isEqualToString:@"ONE_TO_ONE"])
                 {
                     block2 = [NSBlockOperation blockOperationWithBlock:^{
                         
                         [[APIManager sharedJSONManager] oneToOneMessagesRequest:content.users[0].username
                                                             beforeMessageID:nil
                                                                     success:^(MessageResponseModel *responseModel2)
                          {
                              LastMessageModel *messageModel;
                              NSString *myUsername = [AppData appData].XMPPmyJID;
                              
                              for (messageModel in responseModel2.content)
                              {
                                  ChatMessage *message = [ChatMessage initMessageWithFrom:[NSString stringWithFormat:@"%@@imyourdoc.com", messageModel.sender.username]
                                                                                       to:[NSString stringWithFormat:@"%@@imyourdoc.com", content.users[0].username]
                                                                                  content:messageModel.text
                                                                                timestamp:nil
                                                                                messageID:messageModel.messageId
                                                                              withContext:[AppDel managedObjectContext_roster]
                                                                                    MyJid:[NSString stringWithFormat:@"%@@imyourdoc.com", myUsername]
                                                                             WithFileType:messageModel.fileType
                                                                             WithFilepath:messageModel.filePath];
                                  
                                  message.timeStamp = messageModel.timestamp;
                                  
                                  message.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
                                  
                                  message.readReportSent_Bl = [NSNumber numberWithBool:false];
                                  
                                  if (![myUsername isEqualToString:messageModel.sender.username])
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                  }
                                  
                                  if (messageModel.delivery.acknowledged)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Sent];
                                      }
                                  }
                                  
                                  if (messageModel.delivery.notified || messageModel.delivery.emailed)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                                  }
                                  
                                  if (messageModel.delivery.delivered)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Delivered];
                                      }
                                  }
                                  
                                  if (messageModel.delivery.displayed)
                                  {
                                      message.readReportSent_Bl = [NSNumber numberWithBool:true];
                                      
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Read];
                                      }
                                  }
                                  
                                  [AppDel addChatMessage:message toInboxMessage:inboxMsg];
                              }
                          }
                                                                     failure:^(NSError *error)
                          {
                              NSLog(@"Error: %@ %@", error, [error userInfo]);
                          }];
                     }];
                     
                     [ops addObject:block2];
                 }
                 
                 else
                 {
                     block2 = [NSBlockOperation blockOperationWithBlock:^{
                         
                         [[APIManager sharedJSONManager] roomMessagesRequest:content.name
                                                         beforeMessageID:nil
                                                                 success:^(MessageResponseModel *mesModel)
                          {
                              LastMessageModel *messageModel;
                              NSString *myUsername = [AppData appData].XMPPmyJID;
                              
                              for (messageModel in mesModel.content)
                              {
                                  ChatMessage *message = [ChatMessage initGroupChatMessageFrom:[NSString stringWithFormat:@"%@@imyourdoc.com", messageModel.sender.username]
                                                                                            to:[NSString stringWithFormat:@"%@@newconversation.imyourdoc.com", content.name]
                                                                                       content:messageModel.text
                                                                                   chatMessage:ChatMessageType_Group
                                                                                     timestamp:nil
                                                                                     messageID:messageModel.messageId
                                                                                 ChatStateType:ChatStateType_NotDelivered
                                                                                         MyJid:[NSString stringWithFormat:@"%@@imyourdoc.com", myUsername]
                                                                                  WithFileType:messageModel.fileType
                                                                                  WithFilepath:messageModel.filePath];
                                  
                                  message.timeStamp = messageModel.timestamp;
                                  
                                  message.readReportSent_Bl = [NSNumber numberWithBool:false];
                                  
                                  message.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
                                  
                                  if (![myUsername isEqualToString:messageModel.sender.username])
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                  }
                                  
                                  if (messageModel.delivery.acknowledged)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Sent];
                                      }
                                  }
                                  
                                  message.roomRead = 0;
                                  
                                  StatInfoModel *displayed;
                                  for (displayed in messageModel.delivery.displayed)
                                  {
                                      message.roomRead = [NSNumber numberWithInt:[message.roomRead intValue] + 1];
                                      
                                      if ([myUsername isEqualToString:displayed.username])
                                      {
                                          message.readReportSent_Bl = [NSNumber numberWithBool:true];
                                          
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                                      }
                                  }
                                  
                                  if (messageModel.delivery.displayed.count >= (content.users.count - 1)
                                      && [myUsername isEqualToString:messageModel.sender.username])
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_Read];
                                  }
                                  
                                  [AppDel addChatMessage:message toInboxMessage:inboxMsg];
                              }
                          }
                                                                 failure:^(NSError *error)
                          {
                              NSLog(@"Error: %@ %@", error, [error userInfo]);
                          }];
                         
                     }];
                     
                     [ops addObject:block2];
                 }
             }
             
             opQueue2.maxConcurrentOperationCount = 5;
             [opQueue2 addOperations:ops waitUntilFinished:false];
             
         }
                                          failure:^(NSError *error)
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }];
    }
    
	return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
       [txt_search resignFirstResponder];


    InboxMessage *inboxMessage = [self.messageFetchController objectAtIndexPath:indexPath];
    
    ChatViewController *messageVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    messageVC.forChat = YES;
    
    messageVC.jid = [XMPPJID jidWithString:inboxMessage.jidStr];
    
    
    if ([[inboxMessage messageType] boolValue])
    {
        XMPPRoomObject *room =inboxMessage.room;
        
        messageVC.isGroupChat = YES;
        
        messageVC.roomObj = room;
        
        
        XMPPRoomObject *alreadyJoined = [[[AppDel roomsArr] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", room.room_jidStr]] lastObject];
        
        
        if (alreadyJoined)
        {
            messageVC.room = alreadyJoined.room;
        }
        
        else
        {
           
            
            messageVC.room = room.room;
            
            
            if(messageVC.roomObj.lastMessageDate==nil)
            {
                messageVC.roomObj.lastMessageDate=[NSDate dateWithTimeIntervalSinceNow:-160];
            }
            [room.room activate:[AppDel xmppStream]];
            
            [room.room addDelegate:AppDel delegateQueue:[AppDel xmppDelegateQueue ] ];
            
            NSXMLElement * history=[NSXMLElement elementWithName:@"history"];
            
            NSString * seconds=[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSinceDate:room.lastMessageDate] +500];
            
            if([seconds intValue]<30)
            {
                seconds=@"30";
            }
            
            [history addAttributeWithName:@"seconds" stringValue:seconds];
            
            [room.room joinRoomUsingNickname:[[XMPPJID jidWithString:[AppDel myJID]] user] history:history];
            
      
        }
    }
    
    else if ([inboxMessage.chatMessageTypeOf integerValue ] == ChatMessageType_Broadcast)
    {
        BroadcastRecieverChatViewController * messageVd= [[BroadcastRecieverChatViewController alloc] initWithNibName:@"BroadcastRecieverChatViewController" bundle:nil];
        messageVd.inboxMessage =inboxMessage;
        
        
        [self.navigationController pushViewController:messageVd animated:YES];
        return;
    }
    else
    {
        
        XMPPUserCoreDataStorageObject *user = [AppDel fetchUserForJIDString:inboxMessage.jidStr];
        
        messageVC.user = user;

    }
    
   if ([[inboxMessage messageType] boolValue])
    {
        if (messageVC.room==nil)
        {
            
        }
    }
    
    [self.navigationController pushViewController:messageVC animated:YES];
}


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}




#pragma mark - Void

- (void) searchViewAttribute
{
    searchSubView.layer.cornerRadius = 5.0f;
    
    searchSubView.layer.borderWidth = 0.5f;
    
    searchSubView.layer.borderColor = [[UIColor colorWithRed:175.0/ 250.0 green:177.0/ 250.0 blue:180.0/ 250.0 alpha:1.0] CGColor];
}


#pragma mark - Fetched Results

- (NSFetchedResultsController *)messageFetchController
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"InboxMessage"];
    
    if (!messageFetchController)
    {
        NSSortDescriptor *lastUpdatedDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdated"
                                                                                ascending:NO];
        request.sortDescriptors = @[lastUpdatedDescriptor];
        
        
        messageFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                     managedObjectContext:[AppDel managedObjectContext_roster]
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
        messageFetchController.delegate = self;
        
        NSPredicate *predicate= [NSPredicate predicateWithFormat:@"(ANY message.mark_deleted == 0 ) AND (ANY message.content!=%@ ) AND NOT (jidStr   like[cd] %@)",[NSString stringWithFormat:@"~$^^xxx*xxx~$^^"], [AppDel myJID] ];
        messageFetchController.fetchRequest.predicate = predicate;
        
        NSError *error = nil;
        if (![messageFetchController performFetch:&error])
        {
            NSLog(@"....%@", error);
        }
        
    }
    
    
    
    return messageFetchController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [messagesTB reloadData];
    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"page"] containsString:@"end"]) {
//        [messagesTB reloadData];
//    }
//    else{
//        int countPerPage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"page"] intValue];
//        if (controller.fetchedObjects.count % countPerPage == 0){
//            [messagesTB reloadData];
//        }
//    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
}

#pragma mark - Text Field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==txt_search)
    {
        NSPredicate *predicate= [NSPredicate predicateWithFormat:@"ANY message.mark_deleted ==0 AND   NOT (jidStr   like[cd] %@)", [AppDel myJID]];
        self.messageFetchController.fetchRequest.predicate=predicate;

        NSError *error = nil;
        str_search=@"";
        txt_search.text=str_search;
        if ([self.messageFetchController performFetch:&error])
        {
            [messagesTB reloadData];
        }
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
   // str_search=@"";
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (textField==txt_search)
    {
        NSPredicate *predicate= [NSPredicate predicateWithFormat:@"ANY message.mark_deleted ==0 AND   NOT (jidStr   like[cd] %@)", [AppDel myJID]];
        self.messageFetchController.fetchRequest.predicate=predicate;
        
        NSError *error = nil;
        str_search=@"";
        if ([self.messageFetchController performFetch:&error])
        {
            [messagesTB reloadData];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
   
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%lu  %lu  String  :   %@",(unsigned long)range.length,(unsigned long)range.location,string);
    
    if (textField==txt_search)
    {
        NSString *search = [textField.text stringByReplacingCharactersInRange:range withString:string];

        
        if (search.exactLength > 0)
        {  str_search=search;
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"nickname contains[cd] %@", str_search];
            
            request.propertiesToFetch = @[@"jidStr"];
            
            NSError *error = nil;
            
            
            NSArray *results = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:&error];
            
            
            if (error != nil)
            {
                NSLog(@" ... %@", error);
            }
            
            
            NSMutableArray *finalArr = [[NSMutableArray alloc] init];
            
            
            for (XMPPUserCoreDataStorageObject *myObject in results)
            {
                [finalArr addObject:[myObject valueForKey:@"jidStr"]];
            }
            
            NSPredicate *predicate1= [NSPredicate predicateWithFormat:@" ( (ANY message.content  contains[cd] %@ AND  ANY message.mark_deleted !=1 )AND  (  NOT (jidStr   like[cd] %@)) OR (jidStr contains[cd] %@   ) OR (jidStr in %@))  ",search ,[AppDel myJID],search,[results valueForKey:@"jidStr"] ];
            
            self.messageFetchController.fetchRequest.predicate =predicate1;
           
            NSError *error1 = nil;
            
            if ([self.messageFetchController performFetch:&error1])
            {
                [messagesTB reloadData];
            }
            else
            {
                NSLog(@"%@",error1.description);
            }
        }
        
        else
        {
            NSPredicate *predicate= [NSPredicate predicateWithFormat:@"ANY message.mark_deleted ==0 AND   NOT (jidStr   like[cd] %@)", [AppDel myJID]];
            self.messageFetchController.fetchRequest.predicate=predicate;
            
            NSError *error = nil;
              str_search=@"";
            if ([self.messageFetchController performFetch:&error])
            {
                [messagesTB reloadData];
            }
        }
    }
    return YES;
   
}
#pragma mark- Helper Function
-(void)loadTableViewAndResetSearchField{
    txt_search.text=@"";
    [txt_search resignFirstResponder];
    str_search=[NSString new];
    str_search=@"";
    
    self.messageFetchController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY message.mark_deleted ==0) AND (ANY message. content!=%@ )  AND   NOT (jidStr   like[cd] %@)",[NSString stringWithFormat:@"~$^^xxx*xxx~$^^"], [AppDel myJID] ];
    
    NSError *error1 = nil;
    if ([ self.messageFetchController performFetch:&error1])
    {
        
    }
    
}



#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
}


@end

