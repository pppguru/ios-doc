typedef enum : NSInteger
{
    BC_ComposeSegment =0 ,
    BC_OutBoxSegment =1,

}BC_ComposeOutboxType;

#import "GroupListCell.h"
#import "MessageInboxCell.h"

#import "BroadCastGroup+ClassMethod.h"
#import "BroadCastMessageSender+ClassMetod.h"

#import "NSMutableArray+OlderMessages.h"

#import "BroadCastViewController.h"
#import "BroadcastContactListViewController.h"
#import "BroadcastComposeOutboxViewController.h"

@interface BroadcastComposeOutboxViewController ()

@end

@implementation BroadcastComposeOutboxViewController
@synthesize broadcastFetchController, broadcastFetchController_subject;
#pragma mark SDLC
- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.secureDelegate = self;
    
 
    [tableview_obj reloadData];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (IBAction)action_Compse_outbx:(UISegmentedControl*)sender {
    

    
   
    
    if (segment_Compse_outbx.selectedSegmentIndex == BC_ComposeSegment)
    {
        
        broadcastFetchController.fetchRequest.predicate =nil;
        broadcastFetchController.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
        
        NSError *error1 = nil;
        
        
        if ([broadcastFetchController performFetch:&error1])
        {
            
            [tableview_obj reloadData];
            
            
            
        }
        else{
            NSLog(@"%@",error1.description);
        }
    }
    else if(segment_Compse_outbx.selectedSegmentIndex == BC_OutBoxSegment)
    {
    
        
        [tableview_obj reloadData ];
        
        NSPredicate *haveMessage= [NSPredicate predicateWithFormat:@"messages.@count > 0 "];
     
        
       [broadcastFetchController_subject fetchRequest].predicate =haveMessage;
       [broadcastFetchController_subject fetchRequest].sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastupdate" ascending:NO]];
        
        
        
        
        
        NSError *error1 = nil;
        
        
        
        
        
        
        if ([broadcastFetchController_subject performFetch:&error1])
        {
            
            [tableview_obj reloadData];
            
            
            
        }
        else{
            NSLog(@"%@",error1.description);
        }
        
        
    }
    
    
   

    
    
}

- (IBAction)action_addMember:(id)sender
{
    
    BroadcastContactListViewController *feedVC =
    [[BroadcastContactListViewController alloc] initWithNibName:@"BroadcastContactListViewController" bundle:nil];
    
    feedVC.callBackBlock=^(NSArray *arr_contactList,NSString* str_groupName)
    {
        NSLog(@"%@",arr_contactList.description);
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    
                                    @"create_broadcast_list", @"method",
                                    
                                    [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                    
                              str_groupName, @"group_name",nil];
        
        
         [AppDel showSpinnerWithText:@"Creating broadcast group on server ..."];
        
        [[WebHelper sharedHelper]servicesWebHelperWith:dict successBlock:^(BOOL succeeded, NSDictionary *responseG)
         {   [AppDel hideSpinner];
             
             if ([[responseG objectForKey:@"err-code"] intValue] == 1)    // Success
         {

             [AppDel showSpinnerWithText:@"Adding members in  group ..."];
             NSDictionary *dict_add_members = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   @"add_members", @"method",
                                  [NSMutableArray broadcastMembersList:arr_contactList], @"members",
                                   [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                   
                                   [responseG objectForKey:@"group_id"], @"group_id",nil];
             
             
             
             [[WebHelper sharedHelper]servicesWebHelperWith:dict_add_members successBlock:^(BOOL succeeded, NSDictionary *response)
              {[AppDel hideSpinner];
                  
               
                 if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
                 {
                     BroadCastGroup *group=[BroadCastGroup initWithGroupName:str_groupName  withgroupId:[[responseG objectForKey:@"group_id"] stringValue]  withGroupMembersArray:arr_contactList];
                     
                     if (group!=nil)
                     {
                         BroadCastViewController *bCVC =
                         
                         [[BroadCastViewController alloc] initWithNibName:@"BroadCastViewController" bundle:nil];
                         bCVC.currnetGroup=group;
                         
                         
                         bCVC.arr_contacts=[arr_contactList mutableCopy];
                         [self.navigationController pushViewController:bCVC animated:NO];
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
                     [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                     [[AppDel navController] popViewControllerAnimated:YES];
                 }
                 
                 
             } failureBlock:^(BOOL succeeded, NSDictionary *resultdict)
              {
                 [AppDel hideSpinner];
             }];
             
             
             
             
             
             
         }
             
         else if ([[responseG objectForKey:@"err-code"] intValue] == 600)    // Session expired
         { [AppDel signOutFromAppSilent];
             [[RDCallbackAlertView alloc] initWithTitle:nil message:[responseG objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
              
              {
                  
                  
              } otherButtonTitles:@"OK", nil];
         }
             
         else if ([[responseG objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
         {
             [[[UIAlertView alloc] initWithTitle:nil message:[responseG objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             [[AppDel navController] popViewControllerAnimated:YES];
         }
            
        } failureBlock:^(BOOL succeeded, NSDictionary *resultdict)
        {
               [AppDel hideSpinner];
        }];
        
        
        
    
        
      

    };
    [self.navigationController pushViewController:feedVC animated:YES];
}



#pragma mark 


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    

    if (segment_Compse_outbx.selectedSegmentIndex == BC_ComposeSegment)
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.broadcastFetchController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
        
    }
    else if(segment_Compse_outbx.selectedSegmentIndex == BC_OutBoxSegment)
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.broadcastFetchController_subject sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (segment_Compse_outbx.selectedSegmentIndex == BC_ComposeSegment)
    {
        
        {
            GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupListCell"];
            
            
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"GroupListCell" owner:self options:nil] lastObject];
                
                cell.userIMGV.layer.cornerRadius = 26;
                
                cell.userIMGV.layer.backgroundColor = [[UIColor clearColor] CGColor];
                
                [cell.userIMGV.layer setMasksToBounds:YES];
            }
            BroadCastGroup *groupAtIndex=nil;
            
            
            groupAtIndex = [[self broadcastFetchController] objectAtIndexPath:indexPath];
            
            
            if (groupAtIndex.name!=nil)
            {
                cell.userNameLB.text=groupAtIndex.name;
            }
            
            
            
            // code for if group contain patient
            if ([groupAtIndex isPatientRoom] == 0)
                cell.userIMGV.image = [UIImage imageNamed:@"group_profile"];
            else
            {
                cell.userNameLB.textColor = [UIColor colorWithRed:255/255.0 green:84.0/255.0 blue:57.0/255.0 alpha:1];
                
                cell.userIMGV.image = [UIImage imageNamed:@"red_group_profile"];
            }
            return cell;
        }
        
        
    }
    else if(segment_Compse_outbx.selectedSegmentIndex == BC_OutBoxSegment)
    {
        NSLog(@"Vijayvir Singh Saini");
        
        
    
    
    
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    MessageInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageInboxCell"];
    
    

    
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageInboxCell" owner:self options:nil] lastObject];
        
        cell.userImg.layer.cornerRadius = 26;
        
        cell.userImg.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        [cell.userImg.layer setMasksToBounds:YES];
    }
    
    
    cell.greenNotifyIcon.hidden = YES;
    
    cell.msgCountLbl.hidden = YES;
    
    cell.msgNotifyIcon.hidden = YES;
    

    BroadcastSubjectSender *subjectAtIndex0 = [ self.broadcastFetchController_subject objectAtIndexPath:indexPath];
    

    {
        
        BroadCastMessageSender * message=
        [
          [subjectAtIndex0.messages
          sortedArrayUsingDescriptors:
          @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]]lastObject];
        
        

        
        
   
        cell.userNameLbl.text =  subjectAtIndex0.subject;
         cell.userNameLbl.textColor = [UIColor  blueColor];
        cell.msgLbl.text = message.message;
        NSDateFormatter *dateFomatter = [NSDateFormatter new];
        dateFomatter.dateFormat = @"EEE MM-dd-YY hh:mm";
        cell.dateLbl.text = [dateFomatter stringFromDate:message.date];
        cell.userImg.image = [UIImage imageNamed:@"bc_profile_icon"];
       
    }
    
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (segment_Compse_outbx.selectedSegmentIndex == BC_ComposeSegment)
    {
        
   return NO;
    }
    else if(segment_Compse_outbx.selectedSegmentIndex == BC_OutBoxSegment)
    {
         return YES;
        
        
    }
    
    
    return NO;
}


- (void)tableView:(UITableView *)tableView1 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView1 == tableview_obj)
    {
        
        if(segment_Compse_outbx.selectedSegmentIndex == BC_OutBoxSegment)
        {
            
            if (editingStyle == UITableViewCellEditingStyleDelete)
            {
                BroadcastSubjectSender *subjectATIndexToDel = [[self broadcastFetchController_subject] objectAtIndexPath:indexPath];
 
                [subjectATIndexToDel removeMessages:subjectATIndexToDel.messages];
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   
                                   NSError *error = nil;
                                   
                                   
                                   if (![[AppDel managedObjectContext_roster] save:&error])
                                   {
                                       NSLog(@"%@", [error domain]);
                                   }
                                      [tableview_obj reloadData];
                               });
            }
            
            else if (editingStyle == UITableViewCellEditingStyleInsert)
            {
                
            }
        }
        
       
    }
}






- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (segment_Compse_outbx.selectedSegmentIndex == BC_ComposeSegment)
    {
        
        NSLog(@"Vijayvir Singh");
        
    BroadCastGroup *manageObject = [broadcastFetchController objectAtIndexPath:indexPath];
        
        BroadCastViewController *vc = [[BroadCastViewController alloc] initWithNibName:@"BroadCastViewController" bundle:nil];
        vc.currnetGroup =manageObject;
        
        
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }
    else if(segment_Compse_outbx.selectedSegmentIndex == BC_OutBoxSegment)
    {
        NSLog(@"Vijayvir Singh Saini");
        BroadcastSubjectSender *manageObject = [broadcastFetchController_subject objectAtIndexPath:indexPath];
        
        BroadCastViewController *vc = [[BroadCastViewController alloc] initWithNibName:@"BroadCastViewController" bundle:nil];
        vc.currentSubject=manageObject;
         vc.currnetGroup =manageObject.ofGroup;
        [self.navigationController pushViewController:vc animated:YES];
        
    }

 
    
    

    
    

}



#pragma mark - Fetchcontroller
- (NSFetchedResultsController *)broadcastFetchController
{
    if (broadcastFetchController
        == nil)
    {
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastGroup"];
       
        
//        NSString *jidTemp=[NSString new];
//        jidTemp=[AppDel myJID];
//        
//        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
        

        broadcastFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
        
        broadcastFetchController.delegate = self;
        
        
        NSError *error = nil;
        
        
        if (![broadcastFetchController performFetch:&error])
        {
            NSLog(@"....%@", error);
        }
    }
    

    return broadcastFetchController;
}
- (NSFetchedResultsController *)broadcastFetchController_subject
{
    if (broadcastFetchController_subject
        == nil)
    {
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BroadcastSubjectSender"];

        
//        NSString *jidTemp=[NSString new];
//        jidTemp=[AppDel myJID];
        
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastupdate" ascending:NO]];
        
       
        broadcastFetchController_subject = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
        
        broadcastFetchController_subject.delegate = self;
        
        
        NSError *error = nil;
        
        
        if (![broadcastFetchController_subject performFetch:&error])
        {
            NSLog(@"....%@", error);
        }
    }
    
    
    return broadcastFetchController_subject;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    
    [tableview_obj reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{

}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
}


@end
