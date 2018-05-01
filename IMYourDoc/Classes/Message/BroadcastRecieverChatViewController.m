//
//  BroadcastRecieverChatViewController.m
//  IMYourDoc
//
//  Created by vijayveer on 24/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadcastRecieverChatViewController.h"
#import "InboxMessage+ClassMethods.h"
#import "DetailOfMessageViewController.h"

@interface BroadcastRecieverChatViewController ()
{
        NSOperationQueue * chatstateQue;
}
@end

@implementation BroadcastRecieverChatViewController
@synthesize chatController,inboxMessage;


- (void)viewDidLoad {
    
    
    chatstateQue=[[NSOperationQueue alloc] init];
    
    chatstateQue.name=@"readStatusQue";
    
    chatstateQue.maxConcurrentOperationCount=2;
    if (![[UIDevice currentDevice].systemVersion floatValue] < 8.0)
    [chatstateQue setQualityOfService:NSQualityOfServiceBackground];
    
    [super viewDidLoad];
    
    
    
    
    
    

}
- (void) viewWillAppear:(BOOL)animated
{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.secureDelegate = self;
    
    [super viewWillAppear:animated];

    
    
lbl_Subject.text = [ChatMessage getSubjectofMessageWithSubjectId:inboxMessage.jidStr];
    
    [tableView_chat reloadData];
}
    - (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}





#pragma mark tableview 

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}







- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.chatController.sections objectAtIndex:section];
    
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    

    {
        
        
        
        
        static NSString *cellID = @"ChatCell";
        __block  STBubbleTableViewCell *cell =(STBubbleTableViewCell*) [tableView_chat dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            cell =[[STBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            
        }
        
        
        cell.delegate = self;
        
        cell.dataSource = self;
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.imageView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        cell.imageView.layer.cornerRadius = 15;
        
        cell.imageView.layer.masksToBounds = YES;
        
        
        ChatMessage *message = [[self chatController] objectAtIndexPath:indexPath];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (message.isOutbound)
            {
                return;
            }
            
            

            
            if ([message.chatState isEqualToNumber:[NSNumber numberWithInt:ChatStateType_deliveredByReciever]])
            {
                
                message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                
                if([[AppDel managedObjectContext_roster] hasChanges])
                    [[AppDel managedObjectContext_roster] save:nil];
                
            }
            
            if ([message.readReportSent_Bl isEqualToNumber:[NSNumber numberWithBool:NO]])
            {
                
                message.readReportSent_Bl  = [NSNumber numberWithBool:YES];
                
      
                
                __block NSString * messageID=message.messageID,*buddyID;
           
                
                buddyID=message.uri;
                

                
                
              [chatstateQue addOperationWithBlock:^{
                  
                      [AppDel sendChatState:SendChatStateType_displayed withBuddy:buddyID withMessageID:messageID isGroupChat:false];
                
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
            cell.imageView.image =[AppDel image];
            
            
        }
        
        else
        {
            
            XMPPUserCoreDataStorageObject * user=[AppDel fetchUserForJIDString:message.uri];
            
            if (user)
            {
                cell.imageView.image=user.photo;
            }
            else
            {
                
                cell.imageView.image =
                [UIImage imageWithData:[[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:message.displayName]]];
            }
        }
        
        
        if (cell.imageView.image == nil)
        {
            cell.imageView.image = [UIImage imageNamed:@"Profile"];
        }
        
        
        cell.lbl_messageContent.text = @"";
        
        cell.thumbImage = nil;
        
        cell.attachmentImage.image = nil;
        
        cell.message = message;
        
        cell.infoButton.hidden = YES;
        
        cell.messageStatLB.text = @"";
        
        

 
        {
            cell.lbl_messageContent.text =  [NSString stringWithFormat:@"%@",message.content];//
            
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
    if (self.searchDisplayController.searchResultsTableView == tableView)
    {
        return 65;
    }
    
    else
    {
        
        
        ChatMessage *message = [[self chatController] objectAtIndexPath:indexPath];
        
        
        if ([[message fileTypeChat] boolValue])
        {
            return 260;
        }
        
        

        
        
        UIFont *labelFont = [UIFont systemFontOfSize:17.0f];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];

        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:labelFont,
                                  NSFontAttributeName,
                                  paragraphStyle,
                                  NSParagraphStyleAttributeName,
                                  nil];
        
        

        
        
        CGSize size = [message.content boundingRectWithSize:CGSizeMake(tableView_chat.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - STBubbleImageSize - 8.0f - STBubbleWidthOffset, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attrDict
                                                    context:nil].size;
        
       
        if (size.height + 15.0f < STBubbleImageSize + 17.0f)
        {
            return STBubbleImageSize + 54.0f;
        }
        
        
        size.height = size.height + 50;
        
        
        return size.height + 15.0f;
    }
}



#pragma mark chat view controller


- (CGFloat)minInsetForCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        return 100.0f;
    }
    
    
    return 50.0f;
}
- (NSFetchedResultsController *)chatController
{
    if (chatController)
    {
        return chatController;
    }
    
    

    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
        
        
       NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
        
        
        NSString *jid =inboxMessage.jidStr ;
       
        
   
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@" thumb=%@ ", jid ];
  
        
       [request setPredicate:predicate];
        
        request.sortDescriptors = @[sorter];
        
        
        chatController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
        
        chatController.delegate = self;
        
        
        if ([chatController performFetch:nil])
        {
            return chatController;
        }
         return chatController;
    }

    
    
    
    return nil;
}





- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    [tableView_chat  reloadData];
}




- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![self isViewLoaded])
    {
        return;
    }
    


}



- (void)tappedDetailOfMessageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    
    DetailOfMessageViewController *mfVC = [[DetailOfMessageViewController alloc] initWithNibName:@"DetailOfMessageViewController" bundle:nil];
    mfVC.chatMessage = cell.message;
    
    
    [self.navigationController pushViewController:mfVC animated:YES];
    
}


#pragma mark -  action



- (IBAction)action_delete:(id)sender
{
    
    
    
    
    [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Are You sure want to delete the conversation?" cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
     {
         if (btnIndex==0)// no
         {
             
         }
         
         
         if (btnIndex == 1)
             {
                 {
                     
                     [AppDel showSpinnerWithText:@" Delete broadcast group  ..."];
                     NSDictionary *dict_add_members = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       
                                                       @"update_broadcast_message_last_delivery", @"method",
                                              
                                                       [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                                       
                                                      inboxMessage.jidStr, @"subject_id",
                                                       nil];
                     
                     
                     
                     [[WebHelper sharedHelper]servicesWebHelperWith:dict_add_members successBlock:^(BOOL succeeded, NSDictionary *response)
                      { [AppDel hideSpinner];
                          
                          
                          if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
                          {
                              
                              
                              {
                                  [self.navigationController popViewControllerAnimated:YES];
                                  for (id obj in inboxMessage.message) {
                                      [[AppDel managedObjectContext_roster ] deleteObject:obj];
                                  }
                                  
                                  
                                  [[AppDel managedObjectContext_roster] deleteObject:inboxMessage];
                                  
                                  
                                  [[AppDel managedObjectContext_roster]save:nil];
                              }
                              
                              
                              
                              [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                               
                               {
                                   
                                   
                               } otherButtonTitles:@"OK", nil];
                              
                              
                              
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
                              [[AppDel navController] popViewControllerAnimated:YES];
                          }
                          
                          
                      } failureBlock:^(BOOL succeeded, NSDictionary *resultdict)
                      {
                          [AppDel hideSpinner];
                      }];
                     
                     
                 }
                 
                 
               
                 
             }
         
     
     } otherButtonTitles:@"NO",@"YES", nil];
    
    
    

   
    
    NSLog(@"fds");
    

}
@end
