//
//  BroadCastViewController.m
//  IMYourDoc
//
//  Created by OSX on 03/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastViewController.h"
#import "BroadCast_MemberListViewController.h"
#import "BroadCastMessageSender+ClassMetod.h"
#import "BroadcastSubjectSender+ClassMethod.h"
#import "AppDelegate+XmppMethods.h"
#import "NSString+Validations.h"


@interface BroadCastViewController ()
{


    
}
@end

@implementation BroadCastViewController
@synthesize arr_contacts,currnetGroup,currentSubject;

#pragma mark - SDLC

- (void)viewDidLoad {

    [super viewDidLoad];
    
    

    
    
    
    txt_message.placeholder = @"Type your message..";
    
    txt_subject.placeholder = @"Type your Subject..";
    
    if (currentSubject)
    {
        
        txt_subject.text=currentSubject.subject;
        
        txt_subject.userInteractionEnabled=NO;
    
    }
    
    
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.secureDelegate = self;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
     
          txt_subject.maxHeight = 31;
           txt_message.maxHeight = 51;
    }
    
    else
    {
        txt_subject.maxHeight =31;
        txt_message.maxHeight =51;
    }
    
    [self basicfunctionalityOfSDLC];
    
    lbl_GroupName.text=currnetGroup.name;
    
    if (currentSubject)
    {
            lbl_GroupName.text=currentSubject.ofGroup.name;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - life cycle basic functionality
-(void)basicfunctionalityOfSDLC
{
    btn_MoreOption.selected=NO;
    
    const_SubviewHeight.constant=45;
    
    view_SubviewContainer.hidden = YES;
    
    const_subviewConToTableViewCon.constant = -45;
    
    

}


#pragma mark helper function
-(void)helperResetCondtion{
    
    [txt_subject resignFirstResponder];
    
    [txt_message resignFirstResponder];
}

#pragma mark Delegate Text view
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (btn_MoreOption.selected==YES)
    {
        [self action_MoreOption:nil];
    }
    return YES;
}


#pragma mark - Keyboard

- (void) keyboardWillShow: (NSNotification *) noti
{
    CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    
    if(txt_message.isFirstResponder){
        
        txtViewContainerBottomConst.constant = (keyBFrame.size.height - 44.0);
        
        if (tableView_chat.contentSize.height > tableView_chat.contentOffset.y-txtViewContainerBottomConst.constant) //424
        {
            [tableView_chat setContentOffset:CGPointMake(0, tableView_chat.contentSize.height-txtViewContainerBottomConst.constant  )];

        }
    }
        
    
    

    
}
    


- (void) keyboardWillHide: (NSNotification *) noti
{
    
    if(txt_message.isFirstResponder){
        
        if (txtViewContainerBottomConst) {
            txtViewContainerBottomConst.constant = 0;
        }
    }
    
   
 
}







#pragma mark - actions

- (IBAction)action_members:(id)sender
{
    [self helperResetCondtion];
    
    
    if (currnetGroup) {
        BroadCast_MemberListViewController *feedVC =
        
        [[BroadCast_MemberListViewController alloc] initWithNibName:@"BroadCast_MemberListViewController" bundle:nil];
        
        feedVC.currnetGroup=currnetGroup;
        
        [self.navigationController pushViewController:feedVC animated:YES];
    }
  
    
    
 
}

- (IBAction)action_MoreOption:(UIButton *)sender
{
    
   

    
    [self helperResetCondtion];
    
     btn_MoreOption.selected = !btn_MoreOption.selected;
    
    if (btn_MoreOption.selected)
    {
        view_SubviewContainer.hidden = NO;
        
        const_subviewConToTableViewCon.constant = 0;
        
    }
    else
    {
        
        view_SubviewContainer.hidden = YES;
        
        const_subviewConToTableViewCon.constant = -45;
        
    }
    
}

- (IBAction)action_send:(id)sender
{
     [self helperResetCondtion];
    
    if ([AppDel appIsDisconnected]==YES )
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    
        return;
    }
    
    if ([[AppDel xmppStream] isConnected] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please wait. Connecting to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        return;
    }
    
    if(txt_message.text.length<=0 || txt_subject.text.length<=0)
    {
         NSString * str_Subject_Message =@"Please add Subject and Message";
       
        if (txt_message.text.length<=0 && txt_subject.text.length<=0)
        {
            str_Subject_Message =@"Please add Subject and Message";
           
            [txt_subject becomeFirstResponder];
            
        }
        else if (txt_subject.text.length<=0 )
        {
             str_Subject_Message =@"Please add Subject ";
            
            [txt_subject becomeFirstResponder];
            
        }
        else if (txt_message.text.length<=0 )
        {
            str_Subject_Message =@"Please add Message ";
            
            [txt_message becomeFirstResponder];
        }
        
        
    
        
        [[RDCallbackAlertView alloc] initWithTitle:nil message:str_Subject_Message  cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
         {
             if (btnIndex==0)
             {
                 
                 
             }
             
         } otherButtonTitles:@"OK", nil];
        
             return ;
    }
    
    [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Are you sure you want to send this alert ?" cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
     {
         if (btnIndex==0) //NO
         {
             
         }
         
         if (btnIndex == 1)
         {
             
             
             
             {
                 
                 if (!currentSubject)
                 {
                      BroadcastSubjectSender * subject =[BroadcastSubjectSender initWithSubject:txt_subject.text group:currnetGroup];
                     currentSubject =subject;
                     
                     
                     
                     
                     NSPredicate *      predicate = [NSPredicate predicateWithFormat:@" subjectid   =  %@ ", [currentSubject subjectId]];
                     
                     
                     broadcastFetchController.fetchRequest.predicate =predicate;
                     
                     broadcastFetchController.fetchRequest.sortDescriptors =  broadcastFetchController.fetchRequest.sortDescriptors;
                     
                     
                     
                     
                     
                     
                     NSError *error1 = nil;
                     
                     
                     
                     
                     
                     
                     if ([broadcastFetchController performFetch:&error1])
                     {
                         
                         [tableView_chat reloadData];
                         
                         
                         
                     }
                     
                     
                     
                     
                 }
                 
          
              
                 
                 if (currentSubject)
                 {
                 
                     BroadCastMessageSender * message =
                     [BroadCastMessageSender initMessage:txt_message.text  ofsubject:currentSubject status:BCMessageType_Sending withSubjectId: currentSubject.subjectId];
                     
                     NSLog(@"vijha %@" ,message.description);
                     
         
                 
                 
    
                 
               
                 
                 
                 
                 txt_subject.userInteractionEnabled=NO;
            
                 
                 
                     
                     if (message) {
                       
                     
                     
             
                 
                 
        
                 
                 
                 NSDictionary *dict_message = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 
                                                    @"create_broadcast_message",    @"method",  //1
                                                                txt_subject.text,   @"subject",//2
                                                        message.subjectid,          @"subject_id",//3
                                             [[[AppDel xmppStream] myJID] bare],    @"from", //4
                                 [NSString stringWithFormat:@"%@",message.date],    @"timestamp", //5
                                                              message.message,      @"content", //6
                                              message.ofSubject.ofGroup.groupId ,   @"group_id", //7
                                                   message.messageId ,              @"message_id", //8
                [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"],  @"login_token",//9
                                                 nil];

                        

                 
                 
                 {
                 
                 
                 @try {
                     
                     
                     
                     
                     
                     
                     [[WebHelper sharedHelper]servicesWebHelperWith:dict_message successBlock:^(BOOL succeeded, NSDictionary *response)
                      {
                          
                        
                          
                 
                          
                          
                          if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
                          {
                              
                              [AppDel sendbroadcastMessageToOpenFire:message];
                              
                              NSLog(@"%@",response);
                              
                              
                              
                       
                              
                              
                              double delayInSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"] == 0 ? 30.0 : [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"];
                              
                              
                              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
                              
                              
                              dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                              {
                                  
                              
                                  
                                  {
                                      NSDictionary *dict_send_push_non_del_broadcast_users = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                              @"send_push_non_del_broadcast_users",    @"method",
                                                                                              message.ofSubject.ofGroup.groupId ,   @"group_id",
                                                                                              message.messageId ,                 @"message_id",
                                                                                              [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"],  @"login_token",
                                                                                              nil];
                                      
                                      
                                      [[WebHelper sharedHelper]servicesWebHelperWith:dict_send_push_non_del_broadcast_users successBlock:^(BOOL succeeded, NSDictionary *response)
                                       
                                       {
                                           
                                           
                                           if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
                                           {
                                               
                                           
                                               
                                               if ([[response objectForKey:@"found"]  isEqualToString: @"false"])
                                               {
                                                   
                                                   
                                               
                                                   
                                                   if ([message.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_delivered]] ||[message.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_delivered]] )
                                                   {
                                                 
                                                   }
                                                   else{
                                                       
                                                       [AppDel sendbroadcastMessageToOpenFire:message];

                                                   }
                                                   
                                                   
                                              
                                               }
                                               
                                               
                                           }
                                           
                                           else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
                                           { [AppDel signOutFromAppSilent];
                                               
                                               [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                                                
                                                {
                                                    
                                                    
                                                } otherButtonTitles:@"OK", nil];
                                           }
                                           
                                           
                                           else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
                                           {
                                               
                                           }
                                           
                                           
                                           
                                       } failureBlock:^(BOOL succeeded, NSDictionary *resultdict) {
                                           
                                       }];
                                  }
                                  
                                  
                                  
                              });
                              
                              
                             
                             
                        
                              
                              
                              
                              
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
                          
                      }];
                     
                 }
                 @catch (NSException * e) {
                     
                     
                     NSLog(@"Exception: %@", e);
                 }
                 @finally {
                     
                     
                     NSLog(@"finally");
                 }
                 }
                
                     }
                     
                     
                  
                     
                 }
                    txt_message.text= @"";
             }

         }
         
         
     } otherButtonTitles:@"NO",@"YES", nil];
    
    
}

#pragma mark- tableViewDelegate and dataSourse

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.broadcastFetchController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
    
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    {
        static NSString *cellID = @"ChatCell";
        
        
        BCBubbleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        
        if (cell == nil)
        {
            cell = [[BCBubbleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        else
        {
            [cell resetFramesWhenCellIsNotNil];
            
        }
        
        cell.delegate = self;
        
        cell.dataSource = self;
        
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.imageView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        cell.imageView.layer.cornerRadius = 15;
        
        cell.imageView.layer.masksToBounds = YES;
        
        
        
        
        BroadCastMessageSender *messageAtIndex=nil;
        
        
        messageAtIndex = (BroadCastMessageSender*)[[self broadcastFetchController] objectAtIndexPath:indexPath];
        
        
       
        
  
  
        
        if (cell.imageView.image == nil)
        {
            cell.imageView.image = [UIImage imageNamed:@"profile"];
        }
        
        


       
        cell.lbl_messageContent.text = messageAtIndex.message;
        
        cell.thumbImage = nil;
        
        cell.attachmentImage.image = nil;

        cell.infoButton.hidden = YES;
        
        

  
        if ([messageAtIndex.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_Sending]])
        {
             cell.lbl_status.text= @"Sending...";
          
            [cell didDelieved:NO];
            
        }
        else  if ([messageAtIndex.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_Sent]])
        {
            cell.lbl_status.text= @"Sent";
            
            [cell didDelieved:NO];
    
            
            
        }
        
        else  if ([messageAtIndex.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_delivered]])
        {
            cell.lbl_dileveredTo.text =[BroadCastMessageSender getDelievedToWithMessage:messageAtIndex];
           
            cell.lbl_readBy.text = [BroadCastMessageSender getReadByWithMessage:messageAtIndex];
            
            [cell didDelieved:YES];
        }
        else  if ([messageAtIndex.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_delivered]])
        {
            cell.lbl_dileveredTo.text =[BroadCastMessageSender getDelievedToWithMessage:messageAtIndex];
            
            cell.lbl_readBy.text = [BroadCastMessageSender getReadByWithMessage:messageAtIndex];
            
                  [cell didDelieved:YES];
        }
        
        
        else  if ([messageAtIndex.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_displayed]])
        {
            
            cell.lbl_dileveredTo.text =[BroadCastMessageSender getDelievedToWithMessage:messageAtIndex];
            
            cell.lbl_readBy.text = [BroadCastMessageSender getReadByWithMessage:messageAtIndex];
            ;
                  [cell didDelieved:YES];
        }
        else  if ([messageAtIndex.status isEqualToNumber:[NSNumber numberWithInt:BCMessageType_Read]])
        {
           
            cell.lbl_status.text= @"Read";
            
            [cell didDelieved:NO];
            
        }
      

      
        cell.imageView.image =[AppDel image];
        
   
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"MMM dd hh:mm a"];
        
        cell.timeLB.text = [formatter stringFromDate:messageAtIndex.date];

        cell.bubbleColor = BCBubbleTableViewCellBubbleColorGreen;
        
        cell.authorType = BCBubbleTableViewCellAuthorTypeSelf;
        
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
        
        
        BroadCastMessageSender *message = [[self broadcastFetchController] objectAtIndexPath:indexPath];
        //******
        
        
        UIFont *labelFont = [UIFont systemFontOfSize:17.0f];
        
        UIFont *labelFontSubject = [UIFont systemFontOfSize:16.0f];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        //set the line break mode
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:labelFont,
                                  NSFontAttributeName,
                                  paragraphStyle,
                                  NSParagraphStyleAttributeName,
                                  nil];
        
        NSDictionary *attrDictSubject = [NSDictionary dictionaryWithObjectsAndKeys:labelFontSubject,
                                  NSFontAttributeName,
                                  paragraphStyle,
                                  NSParagraphStyleAttributeName,
                                  nil];
        
        
  
        CGSize sizeMessageHeight = [message.message boundingRectWithSize:CGSizeMake(
    tableView_chat.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - BCBubbleImageSize - 8.0f - BCBubbleWidthOffset, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attrDict
                                                    context:nil].size;
        
   CGSize sizeSubjectHeight = [@"" boundingRectWithSize:CGSizeMake(
                                                                       tableView_chat.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - BCBubbleImageSize - 8.0f - BCBubbleWidthOffset, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attrDictSubject
                                                    context:nil].size;
        
        
        if (sizeMessageHeight.height + sizeSubjectHeight.height+ 15.0f < BCBubbleImageSize + 17.0f)
        {
            return BCBubbleImageSize + 54.0f;
        }
        
        
       
        sizeMessageHeight.height = sizeMessageHeight.height + 50;
       
        sizeSubjectHeight.height = sizeSubjectHeight.height ;
       
        return sizeMessageHeight.height +sizeSubjectHeight.height +15+15;
    }
}





#pragma mark - Fetchcontroller
- (NSFetchedResultsController *)broadcastFetchController
{
    if (broadcastFetchController
        == nil)
    {
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMessageSender"];

        
        
        

        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        NSPredicate *predicate =nil;
        
        if (currnetGroup)
        {
           predicate = [NSPredicate predicateWithFormat:@" subjectid   =  %@ ", [currentSubject subjectId]];
            
        }
        else{
               predicate = [NSPredicate predicateWithFormat:@" subjectid   =  %@ ", [currentSubject subjectId]];
        }
        
             request.predicate=predicate;
        broadcastFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
        
        broadcastFetchController.delegate = self;
        
        
        NSError *error = nil;
        
        
        if (![broadcastFetchController performFetch:&error])
        {
            NSLog(@"....%@", error);
        }
        
      
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.broadcastFetchController sections] objectAtIndex:0];

        
        if ( [sectionInfo numberOfObjects]>0) {
            NSIndexPath* ip = [NSIndexPath indexPathForRow:[tableView_chat numberOfRowsInSection:0] - 1 inSection:0];
            
            [tableView_chat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];

        }
    }
    
    
    return broadcastFetchController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

    
  
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [tableView_chat reloadData];
    
    [tableView_chat layoutIfNeeded];
   
    [tableView_chat scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
}




#pragma mark - Scroll view delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == tableView_chat)
    { if(txt_message.isFirstResponder == false)
    {
        if (txtViewContainerBottomConst.constant>0)
        {
            
            [self.view endEditing: YES];
            
            txtViewContainerBottomConst.constant = 0.0;
            
            
            
        }
    }
      
        
        
       
        
       
    }

}



#pragma mark - STBubbleTableViewCell Delegate
- (CGFloat)minInsetForCell:(BCBubbleViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        return 100.0f;
    }
    
    
    return 50.0f;
}


- (void)bcBubbleResetHeightOfCellAtIndexPath:(NSIndexPath *)indexPath
{
   
}



@end
