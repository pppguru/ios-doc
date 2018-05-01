//
//  ChatViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//



#import "UserSubView.h"
#import "UserListCell.h"
#import "OfflineContact.h"
#import "NSString+DDXML.h"
#import "CoreDataHelper.h"
#import "XMPPRoomObject.h"
#import "OfflineChatViewController.h"
#import "RDCallbackAlertView.h"
#import "ReadByViewController.h"
#import "AttachmentViewController.h"
#import "GroupMembersViewController.h"
#import "MessageForwardViewController.h"


@interface OfflineChatViewController ()
{
    UILabel *searchLB;
    
    BOOL add_members_taped;
    
    UIView *view_addContact;
    NSMutableArray *arr_records;
}


@end


@implementation OfflineChatViewController
@synthesize footerForSDCMain;

#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    [self loadPhoneContacts];
    
    [self addExistingAndPhoneContact];
    
   
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    self.jids = [NSMutableArray array];
    
    
    self.chatTB.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    
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
    
    CameraBtn.hidden = YES;
    
    SendButton.hidden = NO;
    

    
  
    footerForSDCMain=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.searchDisplayController.searchResultsTableView.tableFooterView.frame.size.width, 64)];
    footerForSDCMain.tag=1001;
    FontLabel * name=[[FontLabel alloc]initWithFrame:CGRectMake(40, 5, 250, 20)];
   
          name.text=@"Tap to add new Contact ";
       [footerForSDCMain addSubview:name];
    name.tag=1002;
    FontLabel * detailText=[[FontLabel alloc]initWithFrame:CGRectMake(40, 30, 250, 20)];
    [footerForSDCMain addSubview:detailText];
    detailText.text=@" no name ";
    detailText.tag=1003;
    
    self.searchDisplayController.searchResultsTableView.tableFooterView=footerForSDCMain;
    
    
    
    [footerForSDCMain addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
  
    
    
   [self setUpScrollView];
}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.secureDelegate = self;
    
    
    
    self.navigationController.navigationBarHidden = YES;
    
    msgTV.maxHeight = 80;
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
        editBtn.hidden  = NO;
        
        editBtnIcon.hidden=YES;
        
        [searchbar removeFromSuperview];
        
        
        [self.chatTB setTableHeaderView:nil];
        

    
        barTitleLbl.text = self.user.nickname;
        
        
        self.jids = [NSMutableArray arrayWithObject:self.user];
        
        
        if ([AppDel isFromPhysician] != isPatient)
        {
            [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
            
            
            self.navigationItem.rightBarButtonItem.title = @"Close";
        }
        
        
        [_chatTB reloadData];
        
    }

    else
    {
 
        barTitleLbl.text = @" New Conversation";
    }
    
    
    [self setTableView];
    
    
    if (self.forChat == YES)
    {
        [self viewForChat:YES];
    }
    
    else
    {
        [self viewForChat:NO];
    }
    
    
  
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void) viewWillDisappear:(BOOL)animated
{    
    if (self.user)
    {
       
    }
    

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    [msgTV resignFirstResponder];
    
    
    if (self.isGroupChat)
    {
//        dispatch_queue_t que1 = dispatch_get_main_queue();
//        
        
       
    }
    
  
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
}

#pragma mark- Add Contact
-(void)addContact:(id)sender
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Create a new contact. " message:@"Please add the detail ." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Save",nil];
    myAlertView.tag = 5;

    view_addContact=nil;
    view_addContact = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300,100)];
    UITextField *firstName = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 250, 20)];
    firstName.placeholder=@"Receiver's First Name";
    firstName.tag=1;
    firstName.delegate=self;
    
    firstName.returnKeyType=UIReturnKeyDone;
    firstName.keyboardType = UIKeyboardTypeDefault;
    firstName.clearButtonMode = UITextFieldViewModeAlways;
    [view_addContact addSubview:firstName];
    
    UITextField *lastName =  [[UITextField alloc]initWithFrame:CGRectMake(10, 30,250, 20)];
    lastName.placeholder=@"Receiver's Last Name";
    lastName.tag=2;
    lastName.delegate=self;

    lastName.returnKeyType=UIReturnKeyDone;
    lastName.clearButtonMode = UITextFieldViewModeAlways;
    lastName.keyboardType = UIKeyboardTypeDefault;
    [view_addContact addSubview:lastName];
    
    
    
    UITextField *email =  [[UITextField alloc]initWithFrame:CGRectMake(10, 60, 250, 20)];
    email.tag=3;
    email.returnKeyType=UIReturnKeyDone;
    email.clearButtonMode = UITextFieldViewModeAlways;
    email.placeholder=@"Email Id Or Phone number ";
    email.delegate=self;
    email.keyboardType = UIKeyboardTypeEmailAddress;
    [view_addContact addSubview:email];
    
    
    FontLabel *tempView=(FontLabel*)[self.searchDisplayController.searchResultsTableView.tableFooterView viewWithTag:1003];

    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:tempView.text];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    

    
    
    
    
    if (valid)
    {
         email.text=tempView.text;
    }
   else if ([self ValidateEmail:tempView.text ])
    {
        email.text=tempView.text;
    }
    
   else if ([tempView.text rangeOfString:@"@"].location == NSNotFound)
   {
        firstName.text=tempView.text;
   }
    else
    { email.text=tempView.text;
        
    }
    

    
    [myAlertView setValue:view_addContact forKey:@"accessoryView"];
    
    
   CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
   [myAlertView setTransform: moveUp];
    [myAlertView show];
    
}
-(void)addContactWithFirstName:(NSString*)firstName1 lastName:(NSString*)lastname1 emailID:(NSString*)email1
{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Create a new contact. " message:@"Please add the detail ." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Save",nil];
    
    
    myAlertView.tag = 5;

    view_addContact=nil;
    view_addContact = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300,100)];
    
    UITextField *firstName = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 250, 20)];
    firstName.placeholder=@" Receiver's First Name";
    firstName.tag=1;
    firstName.delegate=self;
    firstName.text=firstName1;
    firstName.returnKeyType=UIReturnKeyDone;
    firstName.keyboardType = UIKeyboardTypeDefault;
    firstName.clearButtonMode = UITextFieldViewModeAlways;
    [view_addContact addSubview:firstName];
    
    UITextField *lastName =  [[UITextField alloc]initWithFrame:CGRectMake(10, 30,250, 20)];
    lastName.placeholder=@"Receiver's Last Name";
    lastName.tag=2;
    lastName.delegate=self;
    lastName.text=lastname1;
    lastName.returnKeyType=UIReturnKeyDone;
    lastName.clearButtonMode = UITextFieldViewModeAlways;
    lastName.keyboardType = UIKeyboardTypeDefault;
    [view_addContact addSubview:lastName];
    
    
    UITextField *email =  [[UITextField alloc]initWithFrame:CGRectMake(10, 60, 250, 20)];
    email.tag=3;
    email.delegate=self;
    
    email.clearButtonMode = UITextFieldViewModeAlways;
    email.placeholder=@"Email Id Or Phone number";
    email.text=email1;
    email.keyboardType = UIKeyboardTypeEmailAddress;
    [view_addContact addSubview:email];
    

    
    
    
    [myAlertView setValue:view_addContact forKey:@"accessoryView"];
    
    
    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
    [myAlertView setTransform: moveUp];
    [myAlertView show];
    
    
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (alertView.tag==5) {
        if(alertView.cancelButtonIndex == buttonIndex)
        {
            UITextField *firstName=(UITextField*)[view_addContact viewWithTag:1];
            UITextField *lastName=(UITextField*)[view_addContact viewWithTag:2];
            UITextField *email=(UITextField*)[view_addContact viewWithTag:3];
           
            [firstName resignFirstResponder];
            [lastName resignFirstResponder];
            [email resignFirstResponder];
           
        }
        else{
            UITextField *firstName=(UITextField*)[view_addContact viewWithTag:1];
            UITextField *lastName=(UITextField*)[view_addContact viewWithTag:2];
            UITextField *email=(UITextField*)[view_addContact viewWithTag:3];
          
            
            [firstName resignFirstResponder];
            [lastName resignFirstResponder];
            [email resignFirstResponder];

            
            if (![self validateFirstName:firstName.text])
            {
                
                [self addContactWithFirstName: @"" lastName:lastName.text emailID:email.text ];
                
                [[[UIAlertView alloc]initWithTitle:nil message:@"Enter First Name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                return;
            }
            if (![self validateLastName:lastName.text ])
            {
                [self addContactWithFirstName: firstName.text lastName:@"" emailID:email.text ];
                [[[UIAlertView alloc]initWithTitle:nil message:@"Enter Last Name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                return;
            }
  
            if (email.text.length>0)
            {
                NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                if ([email.text rangeOfCharacterFromSet:notDigits].location == NSNotFound)
                {
            
                    if(![self validatePhoneNumber:email.text])
                    {
                        [self addContactWithFirstName: firstName.text lastName:lastName.text emailID:@"" ];
                        
                        [[[UIAlertView alloc]initWithTitle:nil message:@"Enter 10 digit  phone number. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                        return;
                    }
                    
                }
                else{
                    if (![self ValidateEmail:email.text ])
                    {
                        [self addContactWithFirstName: firstName.text lastName:lastName.text emailID:@"" ];
                        [[[UIAlertView alloc]initWithTitle:nil message:@"Enter correct email Id." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                        return;
                    }
                }
                
             
            }
           
            if((email.text.length>0||[self ValidateEmail:email.text ]))
            {
                NSLog(@"%@ %@ %@ ",firstName.text,lastName.text,email.text);
                
                
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   NSLog(@"here .....dispatch_async");
                                   
                                   
                                   NSString *firstNametxt = [firstName text];
                                   NSString *firstName_capitalized = [[[firstNametxt substringToIndex:1] uppercaseString] stringByAppendingString:[firstNametxt substringFromIndex:1]];
                                   
                                   
                                   NSString *lastNametxt = [lastName text];
                                   NSString *lastName_capitalized = [[[lastNametxt substringToIndex:1] uppercaseString] stringByAppendingString:[lastNametxt substringFromIndex:1]];

                                   
                                   
                                   
                                   NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                                   if ([email.text rangeOfCharacterFromSet:notDigits].location == NSNotFound)
                                   {
                                                 self.user=[AppDel fetchInsertExternamContact:[AppDel myJID] phoneNo: email.text email:nil firstName:firstName_capitalized lastName:lastName_capitalized];
                                   }
                                   else{
                                         self.user=[AppDel fetchInsertExternamContact:[AppDel myJID] phoneNo: nil email:email.text
                                                                            firstName:firstName_capitalized lastName:lastName_capitalized];
                                   }
                                   
                                 
                                   
                                   [self.searchDisplayController.searchBar setHidden:YES];
                                   
                                   [self.jids removeAllObjects];
                                   
                                   [self.jids addObject:self.user];
                                   
                                   NSLog(@"....%@",self.user);
                                   
                                   [self setUpScrollView];
                                   
                                
                                   
                                   [self.searchDisplayController setActive:NO animated:YES];
                                   
                                
                                   
                                   
                               });
                
                
            }
            else{
                [self addContactWithFirstName: firstName.text lastName:lastName.text emailID:@"" ];
                
                [[[UIAlertView alloc]initWithTitle:nil message:@"Enter email id or phone number. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
            }
            
        }
    }
    
    
    
    
    
    
    
    
}
-(BOOL)validateFirstName:(NSString*)firstName
{
    
    if(firstName.length>0)
        return YES;
    return NO;
}

-(BOOL)validateLastName:(NSString*)lastName
{
    if(lastName.length>0)
        return YES;
    return NO;
}
-(BOOL)validatePhoneNumber:(NSString*)phone
{
    
    NSString *numberRegEx = @"[0-9]{10}";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    if ([numberTest evaluateWithObject:phone] == YES)
        return TRUE;
    else
        return FALSE;
    return YES;
}


-(BOOL)ValidateEmail:(NSString*)email
{
    
    BOOL stricterFilter = NO;
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
    return YES;
    
}
#pragma mark - NSFetchRequest

- (NSFetchedResultsController *)chatController
{
    if (_chatController)
    {
        return _chatController;
    }
    
    
    if (self.jids.count == 1)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OfflineMessages"];
        
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"sentDate" ascending:YES];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in %@", self.user.message];
        
        
        [request setPredicate:predicate];
        
        request.sortDescriptors = @[sorter];
        
        
        _chatController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
        
        _chatController.delegate = self;
        
        NSError * error=nil;
        if ([_chatController performFetch:&error])
        {
              NSLog(@"......%@",error);
            
            return _chatController;
        }
          NSLog(@"......%@",error);
    }
    
    
    
    return nil;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.chatTB  beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (![self isViewLoaded])
    {
        return;
    }
    
   	
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            
            [self.chatTB insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
            
        case NSFetchedResultsChangeDelete:
            
            [self.chatTB deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
            
        case NSFetchedResultsChangeUpdate:
            
            [self.chatTB reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            break;
            
            
        case NSFetchedResultsChangeMove:
            
            [self.chatTB deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.chatTB insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![self isViewLoaded])
    {
        return;
    }
    
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            
            [self.chatTB insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
            
        case NSFetchedResultsChangeDelete:
            
            [self.chatTB deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.chatTB endUpdates];
    
    
    [self performSelector:@selector(setTableView) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
}


#pragma mark - Void

- (void)setTableView
{
    if ([[self.chatController sections] count] > 0)
    {
        if (self.chatTB.contentSize.height > self.chatTB.frame.size.height)
        {
            [self.chatTB setContentOffset:CGPointMake(0, self.chatTB.contentSize.height - self.chatTB.frame.size.height)];
        }
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
    
    
    for (OfflineContact *user in self.jids)
    {
        UserSubView *userSubView = [[[NSBundle mainBundle] loadNibNamed:@"UserSubView" owner:self options:nil] lastObject];
        
        userSubView.user = user;
        
        userSubView.nameLB.text = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
        
        userSubView.profileImage.image = [UIImage imageNamed:@"Profile"];
       
        
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
    barTitleLbl.text =@"New Conversation";
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
        
        
        [self.view layoutIfNeeded];
    }
    
    else
    {
        subViewContainer.hidden = NO;
        
        TBVerticalSpaceConstraint.constant = 0;
        
        
        [self addSubview:searchSubView toSuperView:subViewContainer];
        
        
        [self.view layoutIfNeeded];
    }
}


- (void)search:(NSString *)searchTxt
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nickname beginswith[cd] %@ or jidStr beginswith[cd]  %@ or displayName beginswith[cd]  %@ or displayName contains[cd]  %@", searchTxt, searchTxt, searchTxt, [NSString stringWithFormat:@" %@", searchTxt]];
    
    
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
    if ([[AppDel xmppStream] isConnected] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please wait. Connecting to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        return;
    }
    
    
    if ([msgTV.text exactLength] == 0)
    {
        return;
    }
    
    
    [self sendMessage:msgTV.text];
    
    
    msgTV.text = @"";

    
    SendButton.hidden = NO;
}


- (IBAction)cameraTap
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Pick a source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    
    sheet.tag = TAG_CAMERA_ACTIONSHEET;
    
    [sheet showInView:self.view];
}


- (IBAction)editModeTap
{
    
 
}


- (IBAction)editChoiceTap:(IMYourDocButton *)sender
{
    NSLog(@"%ld",(long)sender.tag);
    
    if (sender.tag == 101)              // for Address book
 {
       self.searchDisplayController.searchBar.hidden = NO;
       
       self.searchDisplayController.searchBar.text = @"";
       
       [self.searchDisplayController.searchBar becomeFirstResponder];
        
     
    }
    if (sender.tag == 0)              // for Search Bar  "Add Tap"
    {
        
        
        self.searchDisplayController.searchBar.hidden = NO;
        
        self.searchDisplayController.searchBar.text = @"";
        
        [self.searchDisplayController.searchBar becomeFirstResponder];
        
        
 
        
        
    }
    
    else if (sender.tag == 1)         // for Admin "Add Recipient"
    {
      
    }
    
    else if (sender.tag == 2)         // for Admin  "Close Conversation"
    {
        
    }
    
    else if (sender.tag == 3)         // for Admin  "Show Members"
    {
        
    }
    
    else if (sender.tag == 4)         // for Admin  "Delete Group"
    {
       
    }
    
    else if (sender.tag == 5)         // for Non-Admin   "Close Conversation"
    {
       
    }
    
    else if (sender.tag == 6)         // for Non-Admin   "Show Members"
    {
      
    }
    
    else if (sender.tag == 7)         // for Non-Admin   "Leave Group"
    {
        
    }
    
    else if (sender.tag == 8)         //   for Single-User   "Close Conversation"
    {
        [self.view endEditing:YES];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Do you want to close this conversation for this user?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
    }
    
    else if (sender.tag == 9)         // for Single-User   "Add-Recipient"
    {
        
    }
}


- (IBAction)titleChanged
{
    
    
    }


- (IBAction)tapOnTitle
{
    
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
            sendBtnBottomSpaceConstraint.constant = cameraBtnBottomSpaceConstraint.constant = TVBottomSpaceConstraint.constant = (keyBFrame.size.height - 40);
        }
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    
        sendBtnBottomSpaceConstraint.constant = cameraBtnBottomSpaceConstraint.constant = TVBottomSpaceConstraint.constant = 5;
}


#pragma mark - Text Field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
     [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    
    return YES;
}


#pragma mark - Text View

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   
  
    {
        CameraBtn.hidden = YES;
        
        SendButton.hidden = NO;
        
        
    }
    
    
    return YES;
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   
    
   if (([self.jids count] == 1) && (self.user == nil))
    {
        self.user = [self.jids lastObject];
        
       
        self.forChat = YES;
        
        
        [self viewWillAppear:YES];
    }
    
    
    if (textView == msgTV)
    {
        verticalHeightConst.constant = 45;
        
        subViewContainer.hidden = YES;

        TBVerticalSpaceConstraint.constant = -45;
    }
    
    
    return YES;
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
        
        
        id user = [self.searchUsers objectAtIndex:indexPath.row];


        if([user isKindOfClass:[NSDictionary class]])
        {

            NSDictionary *dict;
            dict=user;
            
            NSString *fir_name=@"";
            NSString *last_name=@"";
            NSString *middle_name=@"";
            NSString *email=@"";
            NSString *phone=@"";
            if ( [dict valueForKey:@"kABPersonFirstNameProperty"])fir_name =[dict valueForKey:@"kABPersonFirstNameProperty"];
            if ( [dict valueForKey:@"kABPersonMiddleNameProperty"])middle_name =[dict valueForKey:@"kABPersonMiddleNameProperty"];
            if ( [dict valueForKey:@"kABPersonLastNameProperty"])last_name =[dict valueForKey:@"kABPersonLastNameProperty"];
            if ( [dict valueForKey:@"kABPersonEmailProperty"])email =[dict valueForKey:@"kABPersonEmailProperty"];
            if ( [dict valueForKey:@"kABPersonPhone"])phone =[dict valueForKey:@"kABPersonPhone"];
            
            tbCell.roleLB.hidden=NO;
            
            tbCell.userIMGV.image = [UIImage imageNamed:@"profile"];
            
            tbCell.userNameLB.text =[NSString stringWithFormat:@"%@ %@ %@ ",fir_name,middle_name, last_name];
            
            if ([dict valueForKey:@"kABPersonEmailProperty"]) {
                   tbCell.roleLB.text=[NSString stringWithFormat:@"Email ID: %@  ",email];
            }
            else if ([dict valueForKey:@"kABPersonPhone"]){
                tbCell.roleLB.text=[NSString stringWithFormat:@"Phone no:   %@",phone];
            }
            else{
                 tbCell.roleLB.text=@"";
            }
            
            
        }
        
        
        return tbCell;
    }
    
    else
    {
        static NSString *cellID = @"ChatCell";
        
       
        STBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        
        if (cell == nil)
        {
            cell = [[STBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        
        cell.delegate = self;
        
        cell.dataSource = self;
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.imageView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        cell.imageView.layer.cornerRadius = 15;
        cell.infoButton.hidden = YES;
        cell.imageView.layer.masksToBounds = YES;
        
        OfflineMessages *message=[[self chatController]objectAtIndexPath:indexPath];
        
            cell.bubbleColor = STBubbleTableViewCellBubbleColorGreen;
            
            cell.authorType = STBubbleTableViewCellAuthorTypeSelf;
        
            cell.imageView.image =[AppDel image];
        
        if (!cell.imageView.image)
        {
            cell.imageView.image = [UIImage imageNamed:@"profile"];
        }
        
            cell.lbl_messageContent.text=  message.messageContent;
            cell.offline =message;
            cell.messageStatLB.text= message.messageStatus;
            cell.userNameLB.text =message.contact.nickname;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd hh:mm a"];
            cell.timeLB.text = [formatter stringFromDate:message.sentDate];
        
        
        if(message && ![message.messageStatus isEqualToString:@"Read"])
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:
                                                   @"getMessageStatus",@"method",
                                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"] ,@"login_token",
                                                   message.messageID,@"message_id",
                                                   nil];
                               
                               
                               [[WebHelper sharedHelper] setWebHelperDelegate:self];
                               
                               [[WebHelper sharedHelper] sendRequest:dict tag:S_GetMessageStatus delegate:self];
                               
                               
                           });
        }
       
        
    
        
        return cell;
    }
    
    
}

#pragma mark -

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchDisplayController.searchResultsTableView == tableView)
    {
        return 65;
    }
    
    else
    {
        
        //Code to manage the height of the cell will be here
        
        OfflineMessages *message = [[self chatController] objectAtIndexPath:indexPath];
        
     
        
        
        CGSize size = [message.messageContent boundingRectWithSize:CGSizeMake(self.chatTB.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - STBubbleImageSize - 8.0f - STBubbleWidthOffset, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"CentraleSansRndLight" size:17.0f]}
                                                    context:nil].size;
        
        
        if (size.height + 15.0f < STBubbleImageSize + 17.0f)
        {
            return STBubbleImageSize + 54.0f;
        }
        
        
        size.height = size.height + 50;
        
        
        return size.height + 15.0f;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%@",tableView);
    
    
    if (self.chatTB != tableView)
    {
  
        NSLog(@"%@",[self.searchUsers objectAtIndex:indexPath.row]);
        
        
        
         [self.searchDisplayController setActive:NO];
     [self.searchDisplayController.searchBar setHidden:YES];
        
        NSLog(@"here .....");
        
        dispatch_async(dispatch_get_main_queue(), ^{
              NSLog(@"here .....dispatch_async");
            
            
            NSDictionary *userDict;
            userDict=[self.searchUsers objectAtIndex:indexPath.row];
            self.user=[AppDel fetchInsertExternamContact:
                        [AppDel myJID]
                        phoneNo: [userDict objectForKey:@"kABPersonPhone"]
                        email:[userDict objectForKey:@"kABPersonEmailProperty"]
                        firstName:[userDict objectForKey:@"kABPersonFirstNameProperty"]
                        lastName:[userDict objectForKey:@"kABPersonLastNameProperty"]];
            
            [self.jids removeAllObjects];
            
            [self.jids addObject:self.user];
          
          NSLog(@"....%@",self.user);
            
            [self setUpScrollView];
        });
     

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


- (void)tappedImageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)tappedForwardOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   
}


- (void)tappedResendOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)tappedInfoOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    
    
    
    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSArray *jids = [searchString componentsSeparatedByString:@","];
    
    
    NSString *str = [jids lastObject];
    
    
    if (str)
    {
        [self search:str];
        [self searchContact:str];
        [self  searchExternalContactWithText:str ];
        
        FontLabel *tempView=(FontLabel*)[self.searchDisplayController.searchResultsTableView.tableFooterView viewWithTag:1003];
        tempView.text=str;
        searchLB.text = str;
    }
    
    
    return YES;
}


-(void)searchContact:(NSString*)searchTxt
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nickname beginswith[cd] %@ or jidStr beginswith[cd]  %@ or displayName beginswith[cd]  %@ or displayName contains[cd]  %@", searchTxt, searchTxt, searchTxt, [NSString stringWithFormat:@" %@", searchTxt]];
    
    
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

#pragma mark - AddressBook delegate 

-(void)addExistingAndPhoneContact{
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil); // create address book reference object
    NSArray* abContactArray = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    arr_records =[[NSMutableArray alloc]init];
    
    // get address book contact array
    NSInteger totalContacts =[abContactArray count];
    
    for(NSUInteger loop= 0 ; loop < totalContacts; loop++)
    {
        ABRecordRef record = (__bridge ABRecordRef)[abContactArray objectAtIndex:loop]; // get address book record
        
        NSString *fir_name=(__bridge NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
        NSString *last_name=(__bridge NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
        NSString *middle_name=(__bridge NSString *)ABRecordCopyValue(record, kABPersonMiddleNameProperty);
        ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(record, kABPersonPhoneProperty);
        ABMutableMultiValueRef emails = ABRecordCopyValue(record, kABPersonEmailProperty);
        
        
        
        if (ABMultiValueGetCount(phones) > 0  )
        {
            for (int i=0; i < ABMultiValueGetCount(phones); i++)
            {
                
                NSMutableDictionary *dict_record=[NSMutableDictionary new];
              ;
                if ( fir_name) [dict_record setObject:fir_name forKey:@"kABPersonFirstNameProperty"];
                if ( last_name) [dict_record setObject:last_name forKey:@"kABPersonLastNameProperty"];
                if ( middle_name) [dict_record setObject:middle_name forKey:@"kABPersonMiddleNameProperty"];
                NSString *condensedPhoneno = [[(__bridge  NSString*)ABMultiValueCopyValueAtIndex(phones, i) componentsSeparatedByCharactersInSet:
                                               [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"]
                                                invertedSet]]
                                              componentsJoinedByString:@""];
                [dict_record setObject:condensedPhoneno forKey:@"kABPersonPhone"];
                [arr_records addObject:dict_record];
            }
        }
        if ( ABMultiValueGetCount(emails) > 0 )
        {
            for (CFIndex j = 0; j < ABMultiValueGetCount(emails); j++)
            {
                
                NSMutableDictionary *dict_record=[NSMutableDictionary new];
           
                if ( fir_name) [dict_record setObject:fir_name forKey:@"kABPersonFirstNameProperty"];
                if ( last_name) [dict_record setObject:last_name forKey:@"kABPersonLastNameProperty"];
                if ( middle_name) [dict_record setObject:middle_name forKey:@"kABPersonMiddleNameProperty"];
                
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(emails, j);
                [dict_record setObject:(__bridge NSString *)emailRef forKey: [NSString stringWithFormat:@"kABPersonEmailProperty" ]];
                CFRelease(emailRef);
                [arr_records addObject:dict_record];
                
            }
        }
        
        
        
        
    }
    
    NSManagedObjectContext *managedObjectContext = [AppDel managedObjectContext_roster];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"OfflineContact"];
    NSMutableArray *orderList;
    orderList =[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (orderList>0)
    {
        for (OfflineContact * contact in orderList)
        {
            
            NSMutableDictionary *dict_record=[NSMutableDictionary new];
            
            if ( contact.firstName) [dict_record setObject:contact.firstName forKey:@"kABPersonFirstNameProperty"];
            if ( contact.lastName) [dict_record setObject:contact.lastName forKey:@"kABPersonLastNameProperty"];

            if ( ![contact.phoneNo isEqualToString:@""]) [dict_record setObject:contact.phoneNo forKey:@"kABPersonPhone"];
            if ( ![contact.emailID isEqualToString:@""]) [dict_record setObject:contact.emailID forKey:@"kABPersonEmailProperty"];
            if (![arr_records containsObject:dict_record])
            {
                [arr_records addObject:dict_record];
            }
            
        }
    
    }
    
    
    NSSortDescriptor *firstnameDescriptor =[[NSSortDescriptor alloc]initWithKey:@"kABPersonFirstNameProperty" ascending:YES];
     NSSortDescriptor *lastnameDescriptor =[[NSSortDescriptor alloc]initWithKey:@"kABPersonLastNameProperty" ascending:YES];
    NSArray *sortDescriptors=@[firstnameDescriptor,lastnameDescriptor];
    
   arr_records=[[[arr_records copy] sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];

    
}
-(void)searchExternalContactWithText:(NSString*)string
{
    

    
    
        
    
    NSPredicate * myPredicate = [NSPredicate predicateWithFormat:@"kABPersonFirstNameProperty CONTAINS[cd]  %@ OR  kABPersonLastNameProperty CONTAINS[cd]  %@ OR   kABPersonMiddleNameProperty CONTAINS[cd]  %@ OR   kABPersonEmailProperty CONTAINS[cd]  %@ OR   kABPersonPhone CONTAINS[cd]  %@   ",string ,string,string,string,string];
    NSArray * filteredArray = [arr_records filteredArrayUsingPredicate:myPredicate];
    
    
    
 
    

    

    self.searchUsers = [filteredArray copy];
    [self.searchDisplayController.searchResultsTableView reloadData];


}


-(void)loadPhoneContacts{
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusDenied) {
      
        return;
    }
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (error) {
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        if (addressBook) CFRelease(addressBook);
        return;
    }
    
    if (status == kABAuthorizationStatusNotDetermined) {
        
        // present the user the UI that requests permission to contacts ...
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
            }
            
            if (granted) {
                // if they gave you permission, then just carry on
                
                      } else {
                // however, if they didn't give you permission, handle it gracefully, for example...
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
                    
                    [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }
            
            if (addressBook) CFRelease(addressBook);
        });
        
    } else if (status == kABAuthorizationStatusAuthorized) {
        if (addressBook) CFRelease(addressBook);
    }
}



- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {


    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    
    view.personViewDelegate = self;
    view.displayedPerson = person;
    view.editing=NO;
    
    view.displayedProperties = [NSArray arrayWithObjects:
                                [NSNumber numberWithInt:kABPersonPhoneProperty],
                                [NSNumber numberWithInt:kABPersonEmailProperty],
                                nil];
 
    
    
    self.navigationController.navigationBarHidden = NO;
    
    [ self.navigationController pushViewController:view animated:YES];

}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    NSLog(@"dsds");
}
- (BOOL)personViewController:(ABPersonViewController *)personViewController
shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifierForValue
{
    
    if(property == kABPersonEmailProperty||property == kABPersonPhoneProperty)
    {
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        CFStringRef phone = ABMultiValueCopyValueAtIndex(multi, identifierForValue);
        
        NSString *fir_name=(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *last_name=(__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *middle_name=(__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        NSMutableDictionary *dict_record=[NSMutableDictionary new];
 
        if ( fir_name) [dict_record setObject:fir_name forKey:@"kABPersonFirstNameProperty"];
        if ( last_name) [dict_record setObject:last_name forKey:@"kABPersonLastNameProperty"];
        if ( middle_name) [dict_record setObject:middle_name forKey:@"kABPersonMiddleNameProperty"];
        NSLog(@"%@",fir_name);
        if(property == kABPersonPhoneProperty)
        {
       
           [ dict_record setObject: (__bridge NSString *)phone forKey:@"kABPersonPhone"];
            
       
            
            NSString *condensedPhoneno = [[ (__bridge NSString *)phone  componentsSeparatedByCharactersInSet:
                                           [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"]
                                            invertedSet]]
                                          componentsJoinedByString:@""];
            [dict_record setObject:condensedPhoneno forKey:@"kABPersonPhone"];
            
            
        }
        if(property == kABPersonEmailProperty)
        {
            [dict_record setObject: (__bridge NSString *)phone forKey:@"kABPersonEmailProperty"];
        }
        

       
        NSLog(@"phone %@",dict_record);
        CFRelease(phone);
        
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"here .....dispatch_async");
            
            
            
            self.user=[AppDel fetchInsertExternamContact:[AppDel myJID] phoneNo: [dict_record objectForKey:@"kABPersonPhone"] email:[dict_record objectForKey:@"kABPersonEmailProperty"] firstName:[dict_record objectForKey:@"kABPersonFirstNameProperty"] lastName:[dict_record objectForKey:@"kABPersonLastNameProperty"]];
            
            [self.jids removeAllObjects];
            
            [self.jids addObject:self.user];
            
            NSLog(@"....%@",self.user);
            
            [self setUpScrollView];
        });
        
        

        
        [self.navigationController popViewControllerAnimated:YES];
        
        
        return YES;
    }
    
    
    
    return YES;
}

#pragma mark - Active Download...

- (void)startIconDownload:(NSInteger)indexPath withImagePath:(NSString *)path
{
    
}


- (void)appImageDidLoad:(NSString *)URLString forIndex:(NSInteger)index withPath:(NSString *)path
{
    
}

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
        
        
   
		          if ([AppDel appIsDisconnected])
            {
                [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
            }
        
            else
            {
                
                NSDictionary *dict ;
        

                NSLog(@"%@",self.user);
                
                
                if (self.user&&msgContent)
                {
                    
                    NSString* str_message_identity;
                    str_message_identity= [[AppDel xmppStream] generateUUID];
                    
                    
                    dict =[[NSDictionary alloc]initWithObjectsAndKeys:
                           @"send_message_non_app_user",@"method",
                           [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"] ,@"login_token",
                           self.user.firstName,@"first_name",
                           self.user.lastName,@"last_name",
                           self.user.phoneNo,@"phone_no",
                            self.user.emailID,@"email",
                            str_message_identity,@"message_identity",
                           msgContent,@"message",
                           nil];
           
                    
                    [[WebHelper sharedHelper] setWebHelperDelegate:self];
                    
                    [[WebHelper sharedHelper] sendRequest:dict tag:S_OfflineChat delegate:self];
                    
                    
                    
                    OfflineMessages * message=[NSEntityDescription insertNewObjectForEntityForName:@"OfflineMessages" inManagedObjectContext:[AppDel managedObjectContext_roster]];
   
                    self.user.messageCount=[NSNumber numberWithInt:[self.user.messageCount intValue]+1];
                    message.messageContent=msgContent;
                    message.message_identity=str_message_identity;
                    message.sentDate=[NSDate date];
                    self.user.lastupdate=[NSDate date];
                    message.messageStatus=@"sent";
                    [self.user addMessageObject:message];
                    message.contact=self.user;
                    [[AppDel managedObjectContext_roster] save:nil];
                    
                    self.chatController=nil;
                    [self.chatTB reloadData];
                    
                    
                    
                    
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Please select the user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }

                
      
            }
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
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
 
        CameraBtn.hidden = YES;
        
        SendButton.hidden = NO;
    
        
   
}
#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_OfflineChat)
    {
        //NSDictionary * requesxt=[[WebHelper sharedHelper] request];
        
        
        

  
        OfflineMessages *message=[[[self.chatController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"message_identity=%@",[response objectForKey:@"message_identity"]]] lastObject];
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Session expired
        {
            
            

    
            NSLog(@"......%@",response);
            message.messageID= [NSString stringWithFormat:@"%@",[response objectForKey:@"message_id"]];
          message.messageStatus=@"Delivered";
             [[AppDel managedObjectContext_roster] save:nil];
            

        }
        else if ([[response objectForKey:@"err-code"] intValue] == 300)            {
            message.messageStatus=@"error";
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            message.messageStatus=@"error";
                [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
             
                 
             } otherButtonTitles:@"OK", nil];
        }
    }
    else if ([WebHelper sharedHelper].tag == S_GetMessageStatus)
    {
        NSLog(@"%@",[response description]);
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Session expired
        {
        
            OfflineMessages *message=[[[self.chatController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"messageID=%@",[response objectForKey:@"message_id"]]] lastObject];
            
           
            if (![[response objectForKey:@"status"] isEqualToString:message.messageStatus])
            {
                 message.messageStatus=[response objectForKey:@"status"];
                     [[AppDel managedObjectContext_roster] save:nil];
            }
           
       
            
       
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    //
        {
         
         
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
           
                [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
             
                 
             } otherButtonTitles:@"OK", nil];
        }
    }
}



- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end

