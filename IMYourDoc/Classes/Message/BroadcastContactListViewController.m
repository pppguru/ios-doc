//
//  BroadcastContactListViewController.m
//  IMYourDoc
//
//  Created by OSX on 17/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadcastContactListViewController.h"

//••••••••••• core data classes
#import "VCard.h"
#import "VCardAffilication.h"

@interface BroadcastContactListViewController ()
{
    NSMutableDictionary *dict_selectedState;
    BroadCastSelectAllHeaderView * headerview;
}
@property (nonatomic, strong) NSFetchedResultsController *listFetchResultController;
@end

@implementation BroadcastContactListViewController
@synthesize callBackBlock,editNameObject;

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
    dict_selectedState=[[NSMutableDictionary alloc]init];
    [self setupFetchedController];
   // [tableview_contctLst registerClass:[BroadCastSelectAllHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    [tableview_contctLst registerNib:[UINib nibWithNibName:@"BroadCastSelectAllHeaderView" bundle:nil]
  forHeaderFooterViewReuseIdentifier:@"Header"];
  
     headerview =  (BroadCastSelectAllHeaderView *)[tableview_contctLst dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    
    __block BroadcastContactListViewController *objBC = self;
    __block NSMutableDictionary *dict_selectedState_weak = dict_selectedState;
    __block UITableView *tbl_contacts_weak = tableview_contctLst;
    headerview.callBackBlockHeaderView = ^(BOOL state)
    {
        {
            objBC.listFetchResultController.fetchRequest.predicate=[NSPredicate predicateWithFormat:@"(subscription LIKE[c] %@) AND streamBareJidStr =%@",
                                                                   @"both",
                                                                   [AppDel myJID]];
            
            objBC.listFetchResultController.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            
            if ([objBC.listFetchResultController performFetch:nil])
            {
            }
        }
        
        [dict_selectedState_weak removeAllObjects];
        
        NSMutableArray * allObjects = [[objBC.listFetchResultController fetchedObjects] mutableCopy];
        
        
        for (  XMPPUserCoreDataStorageObject *user in allObjects)
        {
            
            [dict_selectedState_weak setObject:
             [NSNumber numberWithBool:state] forKey:[NSString stringWithFormat:@"%@",user.jid]];
            
        }
        
        
        [tbl_contacts_weak reloadData];
        
    };
    
    
    
   
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    editNameObject.txt_brdCstGrpName.text=@"";
    [editNameObject.txt_brdCstGrpName setValue:[UIColor whiteColor]
                    forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- tableview delegate
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listFetchResultController.fetchedObjects.count;
}
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
    return headerview;
    }
    
    
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cell_Indentifier_ContactListCell=@"ContactListCell";
    Broadcast_ContactListCell*  cell=(Broadcast_ContactListCell *) [tableView dequeueReusableCellWithIdentifier:cell_Indentifier_ContactListCell];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Broadcast_ContactListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    cell.lbl_name.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    {
         cell.lbl_name.text = [(NSManagedObject *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] valueForKey:@"nickname"];
        XMPPUserCoreDataStorageObject *user = (XMPPUserCoreDataStorageObject *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row];
         cell.userJId=user.jid;
        
        cell.callBackBlock=^(XMPPJID *obj_userJId,BOOL state)
        {
            [dict_selectedState setObject:
             [NSNumber numberWithBool:state] forKey:[NSString stringWithFormat:@"%@",obj_userJId]];
            if([[dict_selectedState valueForKey:[NSString stringWithFormat:@"%@",obj_userJId]] boolValue]==NO)
            {
                [dict_selectedState removeObjectForKey:[NSString stringWithFormat:@"%@",obj_userJId] ];
                
            }
            
        };
        cell.btn_select.selected= [dict_selectedState valueForKey:[NSString stringWithFormat:@"%@",user.jid]] ?[(NSNumber*)[dict_selectedState valueForKey:[NSString stringWithFormat:@"%@",user.jid]] boolValue]:NO;
  
        
     
        
        
        VCard *vCard = [AppDel fetchVCard:user.jid];
        if (vCard.name != nil)
        {
            if (![vCard.designation isEqualToString:@""])
            {
                cell.lbl_name.text = [NSString stringWithFormat:@"%@, %@", vCard.name, vCard.designation];
            }
            
            else
            {
                cell.lbl_name.text = [NSString stringWithFormat:@"%@", vCard.name];
            }
            
            
         
        }
        
        
        cell.image_user.image =user.photo;
        if( cell.image_user.image==nil)
        {
             cell.image_user.image=[UIImage imageNamed:@"Profile"];
            
            
        }
    }
   
    
    
    return cell;
    
}


#pragma mark - Scroll  Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (scrollView== tableview_contctLst)
    {
        [editNameObject.txt_brdCstGrpName resignFirstResponder];
         editNameObject.btn_edit.hidden=YES;
        [searchBar_Contact resignFirstResponder];
        
    }
    
}


# pragma mark - Scrollview 

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    
    if([editNameObject.txt_brdCstGrpName isFirstResponder])
    {
        [editNameObject.txt_brdCstGrpName resignFirstResponder];
        editNameObject.btn_edit.hidden=YES;
        [searchBar_Contact becomeFirstResponder];
        
    }
    
    
    
    return YES;
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}
                  - (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length>0)
    {
        
        self.listFetchResultController.fetchRequest.predicate=[NSPredicate predicateWithFormat:@"(subscription LIKE[c] %@) AND streamBareJidStr =%@ AND displayName contains[cd] %@",
                                                                @"both",
                                                                [AppDel myJID] ,searchText];
         self.listFetchResultController.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        
        if ([self.listFetchResultController performFetch:nil])
        {
            
            [tableview_contctLst reloadData];
            
            
            
        }
    }
    
    else{
        self.listFetchResultController.fetchRequest.predicate=[NSPredicate predicateWithFormat:@"(subscription LIKE[c] %@) AND streamBareJidStr =%@",
                                                               @"both",
                                                               [AppDel myJID]];
        
          self.listFetchResultController.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        if ([self.listFetchResultController performFetch:nil])
        {
            
            [tableview_contctLst reloadData];
            
            
            
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar_Contact resignFirstResponder];
    
}
#pragma mark- action
- (IBAction)action_createList:(id)sender
{
    

    [searchBar_Contact resignFirstResponder];
    
     [editNameObject.txt_brdCstGrpName resignFirstResponder];
       editNameObject.btn_edit.hidden=YES;
    
    if (editNameObject.txt_brdCstGrpName.text.length <= 0 )
    {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Please add Broadcast Group name " cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
         {
               ;
             [editNameObject.txt_brdCstGrpName becomeFirstResponder];
             editNameObject.btn_edit.hidden=NO;
             
         } otherButtonTitles:@"OK" , nil];
    }
    
    else
    {
        if ([dict_selectedState allKeys].count>0)
        {
           
            
            
            
            if ([AppDel appIsDisconnected])
            {
                [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
                
      
                
                return;
            }
            
            
            callBackBlock([[dict_selectedState allKeys] copy],editNameObject.txt_brdCstGrpName.text);
            [self.navigationController popViewControllerAnimated:NO];

        }
        else{
            
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Please select  Broadcast Group Member " cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
            
                 
                 
             } otherButtonTitles:@"OK" , nil];
        }
    }
    
 

    
    
}


#pragma mark - helper function

- (void) setupFetchedController
{
    NSError *er;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
   fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(subscription LIKE[c] %@) AND streamBareJidStr =%@",
                                  @"both",
                                  [AppDel myJID]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    self.listFetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
    
      
    
    if (! [self.listFetchResultController performFetch:&er])
    {
        NSLog(@"Error while fetching from DB: %@", er.description);
    }
}


@end
