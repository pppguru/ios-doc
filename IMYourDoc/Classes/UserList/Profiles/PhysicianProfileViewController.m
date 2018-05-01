


#import "ChatViewController.h"
#import "SearchViewController.h"
#import "PhysicianProfileViewController.h"



@interface PhysicianProfileViewController ()
{
    BOOL bool_PhyProfileRetry, bool_fetchFirstTime, bool_SendInvitation, bool_RemoveXmppUser, bool_InvitationFirstTime, bool_RemoveUserFirstTime;
}

@end


@implementation PhysicianProfileViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.profileDict = [[NSMutableDictionary alloc] init];    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
    profileImg.layer.cornerRadius = profileImg.frame.size.height / 2;
    
    profileImg.layer.masksToBounds = YES;
    

    
    if (self.profileDict)
    {
        
    }
    
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
    
    
    UITapGestureRecognizer *practiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPractice)];
    
    [practiceTap setNumberOfTapsRequired:1];
    
    [practiceLbl addGestureRecognizer:practiceTap];
    
    practiceLbl.userInteractionEnabled = YES;
    
    

    
    UITapGestureRecognizer *hospTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHospital)];
    
    [hospTap setNumberOfTapsRequired:1];
    
    [hospitalLbl addGestureRecognizer:hospTap];
    
    hospitalLbl.userInteractionEnabled = YES;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

    
    profileImg.layer.cornerRadius = profileImg.frame.size.height / 2;
    
    profileImg.layer.masksToBounds = YES;

    
    NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[self.toUserName stringByAppendingString:@"@imyourdoc.com"]]];
    
    if (imgData)
    {
        profileImg.image = [UIImage imageWithData:imgData];
    }
    
    else
    {
        [profileImg downloadFromURL:[NSURL URLWithString:[NSString stringWithFormat: URLBUILER(@"https://api.imyourdoc.com/profilepic.php?user_name=%@") , self.toUserName]]];
        
     
    }
    
    
    bool_fetchFirstTime = YES;
    
    [self fetchProfile];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    profileFetched = NO;
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Void

- (void)fetchProfile
{
    if ([AppDel appIsDisconnected] && bool_fetchFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
    profileFetched = YES;

    
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"getUserProfileOther", @"method",
                          
                          self.toUserName, @"to_user_name",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          nil];
    
    
    if (bool_PhyProfileRetry && !bool_fetchFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_PhyProfileRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Fetching..."];
        
        bool_PhyProfileRetry = YES;
        
        bool_fetchFirstTime = NO;
    }
    
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper]sendRequest:dict tag:S_GetPhyscianProfile delegate:self];
}


- (void)populateData
{
    if ([[self.profileDict valueForKey:@"designation"] isEqualToString: @""])
    {
        nameLbl.text = [self.profileDict valueForKey:@"name"];
    }
    
    else
    {
        nameLbl.text = [NSString stringWithFormat:@"%@, %@", [self.profileDict valueForKey:@"name" ], [self.profileDict valueForKey:@"designation"]];
    }
    
    
    userNameLbl.text = [NSString stringWithFormat:@"(%@)",[self.profileDict valueForKey:@"user_name"]] ;
    
    picNumLbl.text = [self.profileDict valueForKey:@"job_title"];
    
    practiceLbl.text = [self.profileDict valueForKey:@"practice_type"];
    
    hospitalLbl.text = [self.profileDict valueForKey:@"primary_hospital"];
    
    
    [mailBtn setTitle:[self.profileDict valueForKey:@"email"] forState:UIControlStateNormal];
    
    [phoneBtn setTitle:[self.profileDict valueForKey:@"phone"] forState:UIControlStateNormal];
    
    
    if ([[self.profileDict objectForKey:@"privacy_enabled"] intValue] == 1)
    {
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"UserType"] isEqualToString:@"Patient"])
        {
            mailBtn.hidden = phoneBtn.hidden = YES;
            
            verticalSpaceConstrain.constant = 10 - (mailBtn.frame.size.height + phoneBtn.frame.size.height);
            
            [self.view layoutIfNeeded];
        }
    }
    
    
    [self viewByMethod:([[[NSUserDefaults standardUserDefaults] valueForKey:@"UserType"] isEqualToString:@"Patient"] ? YES : NO)];
    
    [hospListTB reloadData];
}


- (void)viewByMethod:(BOOL)viewByPatient
{
    XMPPUserCoreDataStorageObject * user=[AppDel fetchUserForJIDString:[[NSString stringWithFormat:@"%@@imyourdoc.com", self.toUserName] lowercaseString]];
    
    if ([user.subscription isEqualToString:@"both"] || [user.subscription isEqualToString:@"from"] )
    {
        
            
            physicianBtn.hidden = YES;
            
            removeUserBtn.hidden = NO;
            
            
            hospTopConst.constant = - (physicianBtn.frame.size.height - 5.0);
            
            hospBottomConst.constant = 30;
            
            
            [self.view layoutSubviews];
    }
    else
    {
        if (viewByPatient)
        {
            mailBtn.hidden = phoneBtn.hidden = removeUserBtn.hidden = YES;
            
            physicianBtn.hidden = NO;
            
            verticalSpaceConstrain.constant = 10 - (mailBtn.frame.size.height + phoneBtn.frame.size.height);
            
            [physicianBtn setImage:[UIImage imageNamed:@"Send_add_req_btn"] forState:UIControlStateNormal];
            
            hospBottomConst.constant = 0;
            
            [self.view layoutIfNeeded];
        }
        
        else if ([[self.profileDict objectForKey:@"privacy_enabled"] intValue] == 1)
        {
            mailBtn.hidden = phoneBtn.hidden = removeUserBtn.hidden = YES;
            
            physicianBtn.hidden = NO;
            
            
            hospBottomConst.constant = 0;
            
            hospTopConst.constant = 15;
            
            verticalSpaceConstrain.constant = 10 - (mailBtn.frame.size.height + phoneBtn.frame.size.height);
            
            [physicianBtn setImage:[UIImage imageNamed:@"Add_me_btn"] forState:UIControlStateNormal];
        }
        else
        {
            mailBtn.hidden = phoneBtn.hidden = physicianBtn.hidden = NO;
            
            removeUserBtn.hidden = YES;
            
            verticalSpaceConstrain.constant = 5;
            
            [physicianBtn setImage:[UIImage imageNamed:@"Add_me_btn"] forState:UIControlStateNormal];
            
            hospBottomConst.constant = 0;
            
            [self.view layoutIfNeeded];
        }
    }
}


- (void)composeAction:(id)sender
{
    XMPPUserCoreDataStorageObject *user = [AppDel fetchUserForJIDString:[self.toUserName stringByAppendingString:@"@imyourdoc.com"]];
    
    
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    
    if (user)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFromPhysician"] intValue] == isPatient)
     
        {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
            NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@" uri=%@ and identityuri=%@", user.jid.bare, [AppDel myJID] ];
            
            
            [request setPredicate:predicate];
            
            request.sortDescriptors = @[sorter];
            
            
            NSUInteger count = [[AppDel managedObjectContext_roster] countForFetchRequest:request error:nil];
            
            
            if (count != NSNotFound && count > 0)
            {
                chatViewController.forChat = YES;
                
                 if([user.subscription isEqualToString:@"both"])
                chatViewController.user = user;
                
                chatViewController.jid = user.jid;
                
                
                [self.navigationController pushViewController:chatViewController animated:YES];
            }
            
            else
            {
                [AppDel showSpinnerWithText:@""];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    
                    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 
                                                 @"checkSubscription", @"method",
                                                 
                                                 [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                                 
                                                 user.jid.user, @"physician_name",
                                                 
                                                 nil];
                    
                    
                    ASIHTTPRequest *request1 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
                    
                    [request1 setRequestMethod:@"POST"];
                    
                    [request1 addRequestHeader:@"Connection" value:@"close"];
                    
                    [request1 addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                    
                    
                    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestDict options:0 error:nil];
                    
                    
                    [request1 setPostBody:[postData mutableCopy]];
                    
                    [request1 setValidatesSecureCertificate:NO];
                    
                    
                    __weak ASIHTTPRequest *req1 = request1;
                    
                    
                    [request1 setCompletionBlock:^{
                        
                        if ([req1 responseData])
                        {
                            NSDictionary *responsedict = [ NSJSONSerialization JSONObjectWithData:[req1 responseData] options:NSJSONReadingAllowFragments error:nil];
                            
                            
                            if ([[responsedict objectForKey:@"err-code"] intValue] == 1)
                            {
                                chatViewController.forChat = YES;
                                
                                 if([user.subscription isEqualToString:@"both"])
                                     chatViewController.user = user;
                                
                                chatViewController.jid = user.jid;
                                
                                
                                [AppDel hideSpinner];
                                
                                
                                [self.navigationController pushViewController:chatViewController animated:YES];
                            }
                            else if ([[responsedict objectForKey:@"err-code"] intValue] == 900)
                            {
                                
                            }
                            else if([[responsedict objectForKey:@"err-code"] intValue] == 700)
                            {
                                [[RDCallbackAlertView alloc] initWithTitle:nil message:[responsedict objectForKey:@"message"] cancelButtonTitle:@"OK" andCompletionHandler:^(int btnIDX) {
                                    
                    
                                    
                                    
                                } otherButtonTitles:@"Cancel", nil];
                            }
                            
                            else if ([[responsedict objectForKey:@"err-code"] intValue] == 600)    // Session expired
                            {
                                
                                [AppDel signOutFromAppSilent];
                                
                                
                                [[RDCallbackAlertView alloc] initWithTitle:nil message:[responsedict objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                                 
                                 {
                                     
                                     
                                 } otherButtonTitles:@"OK", nil];
                            }
                        }
                    }];
                    
                    
                    [request1 startAsynchronous];
                });
                
                
            }
        }
        
        else
        {
            chatViewController.forChat = YES;
            
             if([user.subscription isEqualToString:@"both"])
                 chatViewController.user = user;
            
            chatViewController.jid = user.jid;
            
            
            [AppDel hideSpinner];
            
            
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
    }
    
    else
    {
        chatViewController.forChat = NO;
        
        
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (profileFetched)
        {
            [self populateData];
        }
        else
        {
            bool_fetchFirstTime = YES;
            
            [self fetchProfile];
        }
    }
    else
    {
        if (profileFetched)
        {
            [self populateData];
        }
        else
        {
            bool_fetchFirstTime = YES;
            
            [self fetchProfile];
        }

    }
}


#pragma mark - IBAction

- (IBAction)mailTap
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setToRecipients:[NSArray arrayWithObject:[self.profileDict valueForKey:@"email"]]];
        
        [self presentViewController:mailComposer animated:YES completion:NULL];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"You need to setup an email account on your device in order to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (IBAction)backTap
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)phoneTap
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", [self.profileDict valueForKey:@"phone"]]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", [self.profileDict valueForKey:@"phone"]]]];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Call facility is not available on your device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (IBAction)physicianTap
{
    
    bool_InvitationFirstTime = YES;
    
    [self physicianTapMethod];
    

}

- (void)physicianTapMethod
{
    if ([AppDel appIsDisconnected] && bool_InvitationFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    
    if (self.fromSearch)
    {
        if (bool_SendInvitation && !bool_InvitationFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            
            bool_SendInvitation = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Processing..."];
            
            bool_SendInvitation = YES;
            
            bool_InvitationFirstTime = NO;
        }
        
        

        
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"sendInvitationV2", @"method",
                              
                              self.toUserName, @"to_user",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              
                              nil];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_SendInvitationV2 delegate:self];
    }

}


- (IBAction)removeUserTap
{
    bool_RemoveUserFirstTime = YES;
    
    [self removeUserTapMethod];
}


- (void)removeUserTapMethod
{
    if (bool_RemoveXmppUser && !bool_RemoveUserFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_RemoveXmppUser = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Processing..."];
        
        bool_RemoveXmppUser = YES;
        
        bool_RemoveUserFirstTime = NO;
    }
    
 
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"removeOpenFireUser", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          self.toUserName, @"user_name",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_RemoveXMPPUser delegate:self];
}


#pragma mark - TapGesture methods

- (void)tapOnPractice
{
    if ([practiceLbl.text exactLength] == 0)
    {
        return;
    }
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
    
    searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                @"search", @"method",
                                
                                @"Physician", @"user_type",
                                
                                practiceLbl.text, @"practice_type",
                                
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                
                                nil];
    
    
    [AppDel showSpinnerWithText:@"Searching..."];
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPhysician delegate:self];
}


- (void)tapOnHospital
{
    if ([[hospitalLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"N/A"])
    {
        return;
    }
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
    
    searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                @"search", @"method",
                                
                                @"Physician", @"user_type",
                                
                                practiceLbl.text, @"practice_type",
                                
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                  
                                [self.profileDict valueForKey:@"primary_hosp_id"], @"hosp_id",
                                
                                nil];
    
    
    [AppDel showSpinnerWithText:@"Searching..."];
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPhysician delegate:self];
    
}


#pragma mark - Update Connectivity

- (void)updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.profileDict objectForKey:@"other_hospitals"] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ht;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        ht = 60;
    }
    
    else
    {
        ht = 45;
    }
    
    return ht;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HospitalListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HospitalListCell"];
    
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HospitalListCell" owner:self options:nil] lastObject];
    }
    
    
    cell.hospNameL.text = [NSString stringWithFormat:@"%@, %@", [[[self.profileDict objectForKey:@"other_hospitals"] objectAtIndex:indexPath.row] valueForKey:@"name"], [[[self.profileDict objectForKey:@"other_hospitals"] objectAtIndex:indexPath.row] valueForKey:@"city"]];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
    
    searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                  
                  @"search", @"method",
                  
                  @"Physician", @"user_type",
                  
                  practiceLbl.text, @"practice_type",
                  
                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                  
                  [[[self.profileDict objectForKey:@"other_hospitals"] objectAtIndex:indexPath.row] valueForKey:@"hosp_id"], @"hosp_id",
                  
                  nil];
    
    
    [AppDel showSpinnerWithText:@"Searching..."];
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPhysician delegate:self];
    
}


#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent)
    {
        [[[UIAlertView alloc] initWithTitle:@"Sent" message:@"Email has been sent successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultSaved)
    {
        [[[UIAlertView alloc] initWithTitle:@"Saved" message:@"Mail has been saved successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultFailed)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Oops. Email didn't send. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultCancelled)
    {
       
    }
    
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_GetPhyscianProfile)
    {
        bool_PhyProfileRetry = YES;
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            self.profileDict = [response mutableCopy];
            
            
            [self populateData];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_SendInvitationV2)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
        /*
        if ([[response objectForKey:@"err-code"] intValue] == 900)    // Success
        {
          
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 if (btnIndex==0)
                 {
                     
                     
                     if ([AppDel appIsDisconnected])
                     {
                         [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
                         
                         return;
                     }
                     
                     
                     [AppDel showSpinnerWithText:@"Processing..."];
                     
                     
                     NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                           
                                           @"getPaymentKeyDetails", @"method",
                                           
                                           [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                           
                                           nil];
                     
                     [[WebHelper sharedHelper] setWebHelperDelegate:self];
                     
                     [[WebHelper sharedHelper] sendRequest:dict tag:S_GetPaymentKeyDetails delegate:self];
                  }
             } otherButtonTitles:@"YES",@"NO", nil];
        }
        
         */
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 404)    // User not found
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_RemoveXMPPUser)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             {
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_SearchPhysician)
    {
        if ([[response objectForKey: @"err-code"] intValue] == 1)
        {
            if ([[response objectForKey:@"users"] count])
            {
                SearchViewController *sVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                
                sVC.searchParam = [NSMutableDictionary dictionaryWithDictionary:searchDict];
                
                [sVC.searchParam setObject:[response objectForKey:@"has_more"] forKey:@"hasMore"];
                
                sVC.searchType = 1;
                
                sVC.searchArr = [[response objectForKey:@"users"] mutableCopy];
                
                [sVC.searchArr sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES]]];
                
                [self.navigationController pushViewController:sVC animated:YES];
            }
            
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"No User found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
        
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
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
    
    
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    
  if ([WebHelper sharedHelper].tag == S_GetPhyscianProfile)
    {
        if (bool_PhyProfileRetry)
        {            
            [self performSelector:@selector(fetchProfile) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_PhyProfileRetry = YES;
                     
                     [self fetchProfile];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_PhyProfileRetry=NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];

        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_SendInvitationV2)
    {
        if (bool_SendInvitation)
        {
            [self performSelector:@selector(physicianTapMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_SendInvitation = YES;
                     
                     [self fetchProfile];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_SendInvitation = NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }

    }
    
    else if ([WebHelper sharedHelper].tag == S_RemoveXMPPUser)
    {
        if (bool_RemoveXmppUser)
        {
            [self performSelector:@selector(removeUserTapMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_RemoveXmppUser = YES;
                     
                     [self fetchProfile];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_RemoveXmppUser=NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
        }
    }
    else
    {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}








#pragma mark - ASIHTTP

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
    
    
    if (request.tag == 1)       //Fetch Profile
    {
        if ([[responseDict objectForKey:@"err-code"] intValue] != 0)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Sorry. We had a server error. Please search this profile again, later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        else
        {
            self.profileDict = [[responseDict objectForKey:@"profile"] mutableCopy];
            
            
            [self populateData];
        }
    }
    
    else if (request.tag == 2)  //Send Invitation
    {
        if ([[responseDict objectForKey:@"err-code"] intValue] != 0)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[responseDict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[responseDict valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    }
    
    else if (request.tag == 3)  //Remove Request
    {
        if ([[responseDict objectForKey:@"err-code"] intValue] != 0)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[responseDict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[responseDict valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    }
    
    else if (request.tag == 4 || request.tag == 5)  //Practice Type tap     //Primary Affiliation tap
    {
        if ([[responseDict objectForKey:@"err-code"] intValue] != 0)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[responseDict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        else
        {
            if ([[responseDict objectForKey:@"users"] count])
            {
                SearchViewController *sVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                
                sVC.searchType = 1;
                
                sVC.searchArr = [[responseDict objectForKey:@"users"] mutableCopy];
                
                [sVC.searchArr sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"FirstName" ascending:YES]]];
                
                [self.navigationController pushViewController:sVC animated:YES];
            }
            
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"No user found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    if (request.tag == 1)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Sorry. We had a server error. Please search this profile again, later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    
    else if (request.tag == 2 || request.tag == 3 || request.tag == 4 || request.tag == 5)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"We were unable to process your request. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}


#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [primaryL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [nameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:28.00]];
        
        [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];

        [picNumLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [practiceLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [hospitalLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [mailBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [phoneBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [pracL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [secondaryL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [removeUserBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
    }
    else
    {
        [primaryL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:10.00]];
        
        [nameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:23.00]];
        
        [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:12.00]];
        
        [picNumLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:10.00]];
        
        [practiceLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [hospitalLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [mailBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:11.00]];
        
        [phoneBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:11.00]];

        [pracL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:10.00]];
        
        [secondaryL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:12.00]];
        
        [removeUserBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
    }
}



@end

