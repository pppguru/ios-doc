//
//  GroupListViewController.m
//  IMYourDoc
//
//  Created by OSX on 25/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupProfileViewController.h"
#import "ChatViewController.h"
@interface GroupListViewController ()<NSFetchedResultsControllerDelegate>

@end

@implementation GroupListViewController
@synthesize tableview_groupList,fetchController_GroupList;
@synthesize txt_search;


#pragma SDLC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-  TableviewCell


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController_GroupList sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        XMPPRoomObject *obj_XMPPRoomObject = [[self fetchController_GroupList] objectAtIndexPath:indexPath];
         cell.userNameLB.text=obj_XMPPRoomObject.name;
    
    
    // code for if group contain patient
    if ([obj_XMPPRoomObject isPatientRoom] == 0)
        cell.userIMGV.image = [UIImage imageNamed:@"group_profile"];
    else
    {
        cell.userNameLB.textColor = [UIColor colorWithRed:255/255.0 green:84.0/255.0 blue:57.0/255.0 alpha:1];
        
         cell.userIMGV.image = [UIImage imageNamed:@"red_group_profile"];
    }
    return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [txt_search resignFirstResponder];

    XMPPRoomObject *room  = [[self fetchController_GroupList] objectAtIndexPath:indexPath];
    
    //ChatViewController *messageVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
//    messageVC.forChat = YES;
//
//    
//    messageVC.isGroupChat = YES;
//    
//    messageVC.roomObj = room;
    
    
    XMPPRoomObject *alreadyJoined = [[[AppDel roomsArr] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", room.room_jidStr]] lastObject];
    
GroupProfileViewController *Obj_groupProfileViewController = [[GroupProfileViewController alloc] initWithNibName:@"GroupProfileViewController" bundle:nil];
       Obj_groupProfileViewController.roomObj = room;
    if (alreadyJoined)
    {
      //  messageVC.room = alreadyJoined.room;
           Obj_groupProfileViewController.xmppRoom = alreadyJoined.room;
        
    }
    
    else
    {
        /*if ([room.room_status isEqualToString:@"deleted"])
         {
         return;
         }*/
        
        
   //     messageVC.room = room.room;
        Obj_groupProfileViewController.xmppRoom = room.room;
        [room.room activate:[AppDel xmppStream]];
                
        [room.room addDelegate:AppDel delegateQueue:[AppDel xmppDelegateQueue] ];
        
        [room.room joinRoomUsingNickname:[[XMPPJID jidWithString:[AppDel myJID]] user] history:nil];
    }
          [self.navigationController pushViewController:Obj_groupProfileViewController animated:YES];
}

#pragma mark - Fetched Results

- (NSFetchedResultsController *)fetchController_GroupList
{
    if (fetchController_GroupList == nil)
    {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPRoomObject"];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        NSPredicate *predicate= [NSPredicate predicateWithFormat:@" ( streamJidStr   like[cd] %@)", [AppDel myJID] ];
        
        request.predicate=predicate;
        
        fetchController_GroupList = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[AppDel managedObjectContext_roster]
                                                                          sectionNameKeyPath:nil cacheName:nil];
        
        fetchController_GroupList.delegate = self;
        NSError *error = nil;
        
        
        if (![fetchController_GroupList performFetch:&error])
        {
            NSLog(@"....%@", error);
        }
    }
    return fetchController_GroupList;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    
    [tableview_groupList reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"%ld",(long)indexPath.row);
    NSLog(@"%ld",(long)indexPath.section);
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
}

#pragma mark - Text Field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    str_search=@"";
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
     [textField resignFirstResponder];
    
       NSPredicate *predicate= [NSPredicate predicateWithFormat:@" ( streamJidStr   like[cd] %@)", [AppDel myJID] ];
    
       self.fetchController_GroupList.fetchRequest.predicate=predicate;
    
    
    NSError *error1 = nil;
    
    
    if ([self.fetchController_GroupList performFetch:&error1])
    {
        [tableview_groupList reloadData];
    }
    else{
        NSLog(@"%@",error1.description);
    }
    
    
      return YES;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    str_search=@"";
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%lu  %lu  String  :   %@",(unsigned long)range.length,(unsigned long)range.location,string);
    
    if (textField==txt_search)
    {
        NSString *search = [textField.text stringByReplacingCharactersInRange:range withString:string];
        // textField.text=search;
        
        if (search.exactLength > 0)
        {

            NSPredicate *predicate= [NSPredicate predicateWithFormat:@"name contains[cd] %@ OR  members.memberJidStr contains[cd] %@ ",search,search];
            
            NSLog(@"%@",predicate);
            self.fetchController_GroupList.fetchRequest.predicate =predicate;
            self.fetchController_GroupList.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            NSError *error1 = nil;
    
            
            if ([self.fetchController_GroupList performFetch:&error1])
            {
                [tableview_groupList reloadData];
            }
            else{
                NSLog(@"%@",error1.description);
            }
            
            
            
            return YES;
        }
        
        else
        {
            
            
            self.fetchController_GroupList.fetchRequest.predicate=nil;
            
            self.fetchController_GroupList.fetchRequest.sortDescriptors =
                                                                    @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            NSPredicate *predicate= [NSPredicate predicateWithFormat:@" ( streamJidStr   like[cd] %@)", [AppDel myJID] ];
            
            self.fetchController_GroupList.fetchRequest.predicate=predicate;
            
            NSError *error = nil;
    
            if ([self.fetchController_GroupList performFetch:&error])
            {
                [tableview_groupList reloadData];
            }
            return YES;
            
        }
        return YES;
    }
 return NO;
    
}

@end
