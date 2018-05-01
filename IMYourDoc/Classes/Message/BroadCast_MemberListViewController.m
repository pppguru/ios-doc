//
//  BroadCast_MemberListViewController.m
//  IMYourDoc
//
//  Created by OSX on 17/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCast_MemberListViewController.h"
//••••••••••• core data classes
#import "VCard.h"
#import "BroadCastGroup.h"
#import "BroadCastMembers+ClassMethod.h"
#import "UserListCell.h"
#import "GroupMemberCell.h"
#import <objc/runtime.h>
static char str_titleKeyForCell;
@interface BroadCast_MemberListViewController ()
{
    NSMutableDictionary *dict_selectedState;
}
@property (nonatomic, strong) NSMutableArray *userFilterArr;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSFetchedResultsController *listFetchResultController;
@end

@implementation BroadCast_MemberListViewController
@synthesize currnetGroup;

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self setupFetchedController];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    self.navigationController.navigationBarHidden = YES;
   

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
   
}
#pragma mark- tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if (tableView != tableview_memberLst)
    {
        return self.users.count;
    }
 
    return self.listFetchResultController.fetchedObjects.count;
    
}
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

        if (tableView != tableview_memberLst)
        {
            static NSString *listTBID = @"LIST_TB_CELLID";
            
            
            UserListCell *tbCell = [tableView dequeueReusableCellWithIdentifier:listTBID];
            
            if (tbCell == nil)
            {
                tbCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListCell" owner:self options:nil] lastObject];
                
                tbCell.userIMGV.layer.cornerRadius = 30;
                
                tbCell.userIMGV.layer.masksToBounds = YES;
            }
            
            
            NSManagedObject *user = [self.users objectAtIndex:indexPath.row];
            
            
            if ([user isKindOfClass:[XMPPUserCoreDataStorageObject class]])
            {
                
                
                tbCell.userNameLB.text = [(NSManagedObject *)user valueForKey:@"nickname"];
                
                
                NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[(NSManagedObject *)user valueForKey:@"jidStr"]]];
                
                
                if (imgData)
                {
                    tbCell.userIMGV.image = [UIImage imageWithData:imgData];
                }
            }
            
            
            tbCell.accessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
            
            
            return tbCell;
        }

    static NSString* cell_Indentifier_ContactListCell=@"ContactListCell";
    
    GroupMemberCell*  cell=(GroupMemberCell *) [tableView dequeueReusableCellWithIdentifier:cell_Indentifier_ContactListCell];
    
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupMemberCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
         
    }
   

    {
           
            cell.userNameL.text = [(BroadCastMembers *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] valueForKey:@"streamId"];
            
             XMPPUserCoreDataStorageObject *user =[AppDel fetchUserForJIDString:cell.userNameL.text ];
       
            
            VCard *vCard = [AppDel fetchVCard:[XMPPJID jidWithString:cell.userNameL.text ]  ];
           if (vCard.name != nil)
           {
               if (![vCard.designation isEqualToString:@""])
               {
                   cell.userNameL.text = [NSString stringWithFormat:@"%@, %@", vCard.name, vCard.designation];
               }
               
               else
               {
                   cell.userNameL.text = [NSString stringWithFormat:@"%@", vCard.name];
               }
               
               
      
               objc_setAssociatedObject(cell.crossBtn , &str_titleKeyForCell,(BroadCastMembers *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

               
              
           }
           
           
           cell.userImg.image =user.photo;
           if( cell.userImg.image==nil)
           {
               cell.userImg.image=[UIImage imageNamed:@"Profile"];
               
               
           }
        
        
        cell.crossBtn.hidden = NO;
        
        [cell.crossBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.adminL.hidden=YES;
        
        }
    
    return cell;
    
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (tableView != tableview_memberLst)
    {
        
        
        
          XMPPUserCoreDataStorageObject *user = (XMPPUserCoreDataStorageObject*)[self.users objectAtIndex:indexPath.row];
        
        [AppDel showSpinnerWithText:@"Adding member in  group ..."];
        NSDictionary *dict_add_members = [NSDictionary dictionaryWithObjectsAndKeys:
                                          
                                          @"add_member", @"method",
                                          user.jidStr, @"member_jid",
                                          [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                          
                                         currnetGroup.groupId , @"group_id",
                                          nil];

        
        [[WebHelper sharedHelper]servicesWebHelperWith:dict_add_members successBlock:^(BOOL succeeded, NSDictionary *response)
         {[AppDel hideSpinner];
             
             
             if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
             {
             
                 if(user)
                 {
                     [self.currnetGroup addMembersObject:[BroadCastMembers initWithStreamId:user.jidStr]];
                 }
                 [[AppDel managedObjectContext_roster] save:nil];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[AppDel managedObjectContext_roster] save:nil];
                    [self setupFetchedController];
                     [tableview_memberLst reloadData];
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
             [AppDel hideSpinner];
         }];
        
        
        
           [self.searchDisplayController setActive:NO animated:YES];
 
    }
}



#pragma mark - Scroll  Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (scrollView== tableview_memberLst)
        [searchbarTxtfld resignFirstResponder];
    
    
}

#pragma mark - searchBar delegate 



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [tableview_memberLst reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(nickname beginswith[cd] %@  ) AND NOT ( jidStr IN %@ )", searchString, [[currnetGroup.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"broadcastGroups CONTAINS  %@",currnetGroup]] valueForKey:@"streamId"]];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    request.predicate = predicate;
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES]];
    
    
    self.users = [[[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil] mutableCopy];
    
    
    return TRUE;
}


- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{

       [self setupFetchedController];
    [tableview_memberLst reloadData];
    
    [self.view layoutIfNeeded];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}


#pragma mark - helper function


- (void)deleteAction:(UIButton *)sender
{

    
     BroadCastMembers * member = objc_getAssociatedObject(sender, &str_titleKeyForCell);
    
    [AppDel showSpinnerWithText:@"deleting member in  group ..."];
    
    NSDictionary *dict_delete_member = [NSDictionary dictionaryWithObjectsAndKeys:
                                      
                                      @"delete_member", @"method",
                                     member.streamId, @"member_jid",
                                      [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                      
                                      currnetGroup.groupId , @"group_id",
                                      nil];
    
    
    [[WebHelper sharedHelper]servicesWebHelperWith:dict_delete_member successBlock:^(BOOL succeeded, NSDictionary *response)
     {[AppDel hideSpinner];
         
         
         if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
         {
             
             [currnetGroup removeMembersObject:member];
             NSError *er = nil;
             [[AppDel managedObjectContext_roster] deleteObject:member];
             
             if([[AppDel managedObjectContext_roster]  hasChanges])
                 [[AppDel managedObjectContext_roster] save:&er];
             [self setupFetchedController];
             [tableview_memberLst reloadData];
             
             
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

- (void) setupFetchedController
{
    NSError *er;
    

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMembers"];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"broadcastGroups CONTAINS  %@",currnetGroup ];

   fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"streamId" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    self.listFetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];

    
    
    if (! [self.listFetchResultController performFetch:&er])
    {
        NSLog(@"Error while fetching from DB: %@", er.description);
    }
}

- (void)searchTableView
{
    [self filterContentForSearchText:[searchbarTxtfld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}
- (void)filterContentForSearchText:(NSString *)searchText
{
    [self.userFilterArr removeAllObjects];
    
    

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(nickname beginswith[cd] %@ or jidStr beginswith[cd]  %@  ) AND NOT ( jidStr IN %@ )", searchText, searchText, [[self.currnetGroup.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member' OR role='owner'"]] valueForKey:@"memberJidStr"]];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    request.predicate = predicate;
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES]];
    
   self.userFilterArr= [[[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil] mutableCopy];
    
    
    
    
//    
    
    [tableview_memberLst reloadData];
}

@end
