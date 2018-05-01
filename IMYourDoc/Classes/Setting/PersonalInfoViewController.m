//
//  PersonalInfoViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "PersonalInfoViewController.h"


@interface PersonalInfoViewController ()
{
      BOOL bool_editProfileRetry, bool_PersonalProfileRetry, bool_editFirstTime, bool_ProfileFirstTime;
}

@end


@implementation PersonalInfoViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    bool_ProfileFirstTime = YES;
    
    [self fetchPersonalProfile];
    
    [practiceTF addTarget:self.autoCompTV action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [jobTitleTF addTarget:self.autoJobCompTV action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [desigTF addTarget:self.autoDesigCompTV action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
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
    
    
    if (fetchingHosp)
    {
        [self allowEditing:YES];
        
        
        fetchingHosp = NO;
    }
    
    else
    {
        [self allowEditing:YES];
    }
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPREACHABILITY object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

- (void)saveInfo
{
    if ([AppDel appIsDisconnected]  && bool_editFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
  
    
        
        
        
        
        if ([privacySwitch isOn])
        {
            privacyFlag = @"1";
        }
        
        else
        {
            privacyFlag = @"0";
        }
        
        
        {
            
            if (!(firstNameTF.text.length>0))
            {
                     [[[UIAlertView alloc] initWithTitle:nil message:@"Enter First name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [firstNameTF becomeFirstResponder];
                return;
                
            }
            if (!(lastNameTF.text.length>0))
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Enter last name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [lastNameTF becomeFirstResponder];
                return;
                
            }
            if (!(secQuesTF.text.length>0))
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Enter Security question." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [secQuesTF becomeFirstResponder];
                return;
                
            }
            if (!(secAnsTF.text.length>0))
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Enter Security answer." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [secAnsTF becomeFirstResponder];
                return;
                
            }
            
            if (staffProfile||physicianProfile)
            {
                
                if (!(practiceTF.text.length>0))
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Enter Practice Type." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [practiceTF becomeFirstResponder];
                    return;
                    
                }
                
            }
            
            if (!(phoneTF.text.length>0))
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Enter Phone number ." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [phoneTF becomeFirstResponder];
                return;
                
            }
            if ([phoneTF.text exactLength] < 10)
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                
                return;
            }
            if (!(zipcodeTF.text.length>0))
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Enter Zip ." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [zipcodeTF becomeFirstResponder];
                return;
                
            }
            
            if (!([zipcodeTF.text exactLength] >= 5))
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                
                return ;
            }
            

            
            
         
        }
        

        if (bool_editProfileRetry && !bool_editFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            
            bool_editProfileRetry = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Saving Profile..."];
            
            bool_editProfileRetry = YES;
            
            bool_editFirstTime = NO;
        }

        
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];

        
        if (staffProfile)
        {
            NSArray *otherAffIDs = [self.otherAff valueForKey:@"hosp_id"];

            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  @"updateUserDetails", @"method",
                                  
                                  [firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"first_name",
                                  
                                  [lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"last_name",
                                  
                                  secQuesTF.text, @"security_question",
                                  
                                  secAnsTF.text, @"security_answer",
                                  
                                  jobTitleTF.text, @"job_title",
                                  
                                  desigTF.text, @"designation",
                                  
                                  zipcodeTF.text, @"zip",
                                  
                                  phoneTF.text, @"phone",
                                  
                                  privacyFlag, @"privacy_enabled",
                                  
                                  practiceTF.text, @"practice_type",
                                  
                                  (self.primaryAff ? [self.primaryAff objectForKey:@"hosp_id"] : @""), @"primary_hosp_id",
                                  
                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                  
                                  [otherAffIDs componentsJoinedByString:@","], @"other_hospitals",
                                  
                                  nil];
            
            [[WebHelper sharedHelper]sendRequest:dict tag:S_EditProfile delegate:self];
        }
        
        else if (patientProfile)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  @"updateUserDetails", @"method",
                                  
                                  [firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"first_name",
                                  
                                  [lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"last_name",
                                  
                                  secQuesTF.text, @"security_question",
                                  
                                  secAnsTF.text, @"security_answer",
                                  
                                  zipcodeTF.text, @"zip",
                                  
                                  phoneTF.text, @"phone",
                                  
                                  privacyFlag, @"privacy_enabled",
                                  
                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                  
                                  nil];
            
            
       
            
            [[WebHelper sharedHelper]sendRequest:dict tag:S_EditProfile delegate:self];
            
        }
        
        else if (physicianProfile)
        {
            NSArray *otherAffIDs = [self.otherAff valueForKey:@"hosp_id"];
            
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  @"updateUserDetails", @"method",
                                  
                                  [firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"first_name",
                                  
                                  [lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"last_name",
                                  
                                  secQuesTF.text, @"security_question",
                                  
                                  secAnsTF.text, @"security_answer",
                                  
                                  zipcodeTF.text, @"zip",
                                  
                                  desigTF.text, @"designation",
                                  
                                  jobTitleTF.text, @"job_title",
                                  
                                  phoneTF.text, @"phone",
                                  
                                  privacyFlag, @"privacy_enabled",
                                  
                                  practiceTF.text, @"practice_type",
                                  
                                  (self.primaryAff ? [self.primaryAff objectForKey:@"hosp_id"] : @""), @"primary_hosp_id",
                                  
                                  [otherAffIDs componentsJoinedByString:@","], @"other_hospitals",
                                  
                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                  
                                  nil];
            
            

            
            [[WebHelper sharedHelper]sendRequest:dict tag:S_EditProfile delegate:self];
            
        }
     }
}


- (void)fetchPersonalProfile
{
    if ([AppDel appIsDisconnected]  && bool_ProfileFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        if (bool_PersonalProfileRetry && !bool_ProfileFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            
            bool_PersonalProfileRetry = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Requesting..."];
            
            bool_PersonalProfileRetry = YES;
            
            bool_ProfileFirstTime = NO;
        }

        
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"getUserProfile", @"method", [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token", nil];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_PersonalInfo delegate:self];
        
         NSDictionary *dict2 = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"practiceTypes_jobTitle_designationList", nil] forKeys:[NSArray arrayWithObjects:@"method", nil]];
        
        
        [[WebHelper sharedHelper] sendRequest:dict2 tag:S_PracticeTypes_jobTitle_designationList delegate:self];
    }
}



- (void)fetchPersonalProfileStaff
{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        [AppDel showSpinnerWithText:@"Requesting..."];
        
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"get_my_profile", @"method", [AppData appData].XMPPmyJID, @"user_name", nil];
        
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://www.imyourdoc.com/joomla/service.php"]];
        
        request.tag = 3;
        
        request.delegate = self;
        
        [request setRequestMethod:@"POST"];
        
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        request.postBody = [[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil] mutableCopy];
        
        [request startAsynchronous];
    }
    
    
    
}





- (void)allowEditing:(BOOL)allow
{
    if (allow)
    {
        editingDone = YES;
        
        
        editIconImg.image = [UIImage imageNamed:@"Tick"];
        
        
        firstNameTF.userInteractionEnabled = lastNameTF.userInteractionEnabled = secQuesTF.userInteractionEnabled = secAnsTF.userInteractionEnabled = phoneTF.userInteractionEnabled = practiceTF.userInteractionEnabled  = zipcodeTF.userInteractionEnabled  = jobTitleTF.userInteractionEnabled = desigTF.userInteractionEnabled = YES;
        
        
        primaryAffBtn.enabled = otherAffBtn.enabled = YES;
    }
    
    else
    {
        editingDone = NO;
        
        
        editIconImg.image = [UIImage imageNamed:@"Edit"];
        
        
        firstNameTF.userInteractionEnabled = lastNameTF.userInteractionEnabled = secQuesTF.userInteractionEnabled = secAnsTF.userInteractionEnabled = phoneTF.userInteractionEnabled = practiceTF.userInteractionEnabled   = zipcodeTF.userInteractionEnabled = jobTitleTF.userInteractionEnabled = desigTF.userInteractionEnabled = NO;
        
        
        otherAffBtn.enabled = primaryAffBtn.enabled = NO;
    }
}


#pragma mark - IBAction

- (IBAction)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)editProfile
{
    bool_editFirstTime = YES;
    
    [self saveInfo];
    
    
    [self.view endEditing:YES];
    
    

    
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}


- (IBAction)selectSecondaryHospital
{
    fetchingHosp = YES;
    
    
    HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeMultiple;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


- (IBAction)selectPrimaryHospital
{
    fetchingHosp = YES;
    
    
    HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - Auto Completer

- (AutocompletionTableView *)autoCompTV
{
    if (!_autoCompTV)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [options setValue:[NSNumber numberWithBool:NO] forKey:ACOCaseSensitive];
        
        [options setValue:nil forKey:ACOUseSourceFont];
        
        
        _autoCompTV = [[AutocompletionTableView alloc] initWithTextField:practiceTF andFrame:[self.view convertRect:practiceTF.frame fromView:practiceTF.superview] inViewController:self withOptions:options];
        
        _autoCompTV.autoCompleteDelegate = self;
        
        _autoCompTV.layer.borderColor = [[UIColor grayColor] CGColor];
        
        _autoCompTV.layer.borderWidth = 2.0f;
        
        _autoCompTV.layer.cornerRadius = 12.0f;
        
        _autoCompTV.suggestionsDictionary = self.practiceType;
    }
    
    
    return _autoCompTV;
}


- (AutocompletionTableView *)autoJobCompTV
{
    if (!_autoJobCompTV)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [options setValue:[NSNumber numberWithBool:NO] forKey:ACOCaseSensitive];
        
        [options setValue:nil forKey:ACOUseSourceFont];
        
        
        _autoJobCompTV = [[AutocompletionTableView alloc] initWithTextField:jobTitleTF andFrame:[self.view convertRect:jobTitleTF.frame fromView:jobTitleTF.superview] inViewController:self withOptions:options];
        
        _autoJobCompTV.suggestionsDictionary = self.jobTitle;
        
        _autoJobCompTV.autoCompleteDelegate = self;
        
        _autoJobCompTV.layer.borderColor = [[UIColor grayColor] CGColor];
        
        _autoJobCompTV.layer.borderWidth = 2.0f;
        
        _autoJobCompTV.layer.cornerRadius = 12.0f;
        
    }
    
    
    return _autoJobCompTV;
}


- (AutocompletionTableView *)autoDesigCompTV
{
    if (!_autoDesigCompTV)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [options setValue:[NSNumber numberWithBool:NO] forKey:ACOCaseSensitive];
        
        [options setValue:nil forKey:ACOUseSourceFont];
        
        
        _autoDesigCompTV = [[AutocompletionTableView alloc] initWithTextField:desigTF andFrame:[self.view convertRect:desigTF.frame fromView:desigTF.superview] inViewController:self withOptions:options];
        
        _autoDesigCompTV.suggestionsDictionary = self.designation;
        
        _autoDesigCompTV.autoCompleteDelegate = self;
        
        _autoDesigCompTV.layer.borderColor = [[UIColor grayColor] CGColor];
        
        _autoDesigCompTV.layer.borderWidth = 2.0f;
        
        _autoDesigCompTV.layer.cornerRadius = 12.0f;
        
    }
    
    
    return _autoDesigCompTV;
}


- (NSArray *) autoCompletion:(AutocompletionTableView *) completer suggestionsFor:(NSString *) string
{
    if (practiceTF.isEditing)
    {
        return self.practiceType;
    }
    
    else if (jobTitleTF.isEditing)
    {
        return self.jobTitle;
    }
    
    else if (desigTF.isEditing)
    {
        return self.designation;
    }
    
    return nil;
}


- (void) autoCompletion:(AutocompletionTableView *) completer didSelectAutoCompleteSuggestionWithIndex:(NSInteger) index
{
    
}


#pragma mark - Hospital management

- (NSMutableArray *)selectedHospitals:(HospitalSearchViewController *)controller
{
    if (controller.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        return [NSMutableArray arrayWithObjects:self.primaryAff, nil];
    }
    
    
    if (self.otherAff == nil)
    {
        self.otherAff = [NSMutableArray array];
    }
    
    
    return self.otherAff;
}


- (void)HospitalController:(HospitalSearchViewController *)controller selectedHosptials:(NSMutableArray *)selectedHosps
{
    if (controller.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        self.primaryAff = [selectedHosps lastObject];
        
        
        primaryAffL.text = [self.primaryAff objectForKey:@"name"];
    }
    
    else
    {
        self.otherAff = selectedHosps;
        
        
        NSArray *names = [self.otherAff valueForKey:@"name"];
        
        
        otherAffL.text = [names componentsJoinedByString:@","];
    }
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    
    if (textField == firstNameTF)
    {
        [lastNameTF becomeFirstResponder];
    }
	
    else if (textField == lastNameTF)
    {
        [secQuesTF becomeFirstResponder];
    }
	
	else if (textField == secQuesTF)
    {
        [secAnsTF becomeFirstResponder];
    }
	
    else if (textField == secAnsTF)
    {
        if (patientProfile)
        {
            [phoneTF becomeFirstResponder];
        }
        
        else
        {
            [jobTitleTF becomeFirstResponder];
        }
    }
    
    else if (textField == jobTitleTF)
    {
        [desigTF becomeFirstResponder];
    }
    
	else if (textField == desigTF)
    {
        if (physicianProfile || staffProfile)
        {
            [practiceTF becomeFirstResponder];
        }
        
        else
        {
            [phoneTF becomeFirstResponder];
        }
    }
	
	else if (textField == practiceTF)
    {
        [phoneTF becomeFirstResponder];
    }
	
	else if (textField == phoneTF)
    {
        [zipcodeTF becomeFirstResponder];
    }
    
    else if (textField == zipcodeTF)
    {
        [zipcodeTF resignFirstResponder];
    }
    
    
    return YES;
}



#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    float kbOffset = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].origin.y;
    
    
    float tfOffset = 0 ;
    
    
    if (firstNameTF.isEditing)
    {
        tfOffset = [self.view convertRect:firstNameTF.frame fromView:firstNameTF.superview].origin.y + firstNameTF.frame.size.height;
    }
    
    else if (lastNameTF.isEditing)
    {
        tfOffset = [self.view convertRect:lastNameTF.frame fromView:lastNameTF.superview].origin.y + lastNameTF.frame.size.height;
    }
    
    else if (secQuesTF.isEditing)
    {
        tfOffset = [self.view convertRect:secQuesTF.frame fromView:secQuesTF.superview].origin.y + secQuesTF.frame.size.height;
    }
    
    else if (secAnsTF.isEditing)
    {
        tfOffset = [self.view convertRect:secAnsTF.frame fromView:secAnsTF.superview].origin.y + secAnsTF.frame.size.height;
    }
    
    else if (practiceTF.isEditing)
    {
        tfOffset = [self.view convertRect:practiceTF.frame fromView:practiceTF.superview].origin.y + practiceTF.frame.size.height + 100;
    }
    
    else if (jobTitleTF.isEditing)
    {
        tfOffset = [self.view convertRect:jobTitleTF.frame fromView:jobTitleTF.superview].origin.y + jobTitleTF.frame.size.height + 100;
    }

    else if (desigTF.isEditing)
    {
        tfOffset = [self.view convertRect:desigTF.frame fromView:desigTF.superview].origin.y + desigTF.frame.size.height + 100;
    }

    
    else if (phoneTF.isEditing)
    {
        tfOffset = [self.view convertRect:phoneTF.frame fromView:phoneTF.superview].origin.y + phoneTF.frame.size.height;
    }
    
    else if (zipcodeTF.isEditing)
    {
        tfOffset = [self.view convertRect:zipcodeTF.frame fromView:zipcodeTF.superview].origin.y + zipcodeTF.frame.size.height;
    }
    
    
    tfOffset += TFScroll.contentOffset.y;
    
    
    [TFScroll setContentOffset:CGPointMake(0, (((kbOffset - tfOffset) < 0) ? (tfOffset - kbOffset) : 0)) animated:NO];
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    TFScroll.contentOffset = CGPointMake(0, 0);
}


#pragma mark - KeyBoard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(phoneTFNumberPad)],
                           
                           nil];
    
    
    phoneTF.inputAccessoryView = numberToolbar;
    
    
    if (patientProfile)
    {
        UIToolbar *numberToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        numberToolbar2.items = [NSArray arrayWithObjects:
                                
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                
                                [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(zipTFNumberPad)],
                                
                                nil];
        
        
        zipcodeTF.inputAccessoryView = numberToolbar2;
    }
    
    else
    {
        UIToolbar *numberToolbar3 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        numberToolbar3.items = [NSArray arrayWithObjects:
                                
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                
                                [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(zipTFNumberPad)],
                                
                                nil];
        
        
        zipcodeTF.inputAccessoryView = numberToolbar3;
    }
}


- (void)phoneTFNumberPad
{    
    [zipcodeTF becomeFirstResponder];
}


- (void)zipTFNumberPad
{
    [zipcodeTF resignFirstResponder];
    
    
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    
    if (physicianProfile || staffProfile)
    {
        fetchingHosp = YES;
        
        
        [self.view endEditing:YES];
        
        
        HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
        
        hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
        
        hospVC.delegate = self;
        
        [self.navigationController pushViewController:hospVC animated:YES];
    }
}


#pragma mark - Request


- (void)didReceivedresponse:(NSDictionary *)response
{
    if ([WebHelper sharedHelper].tag == S_PracticeTypes_jobTitle_designationList)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            self.practiceType = [NSMutableArray arrayWithArray:[response objectForKey:@"practice_typeslist"]];
                self.designation = [NSMutableArray arrayWithArray:[response objectForKey:@"designation_list"]];
                self.jobTitle = [NSMutableArray arrayWithArray:[response objectForKey:@"job_title_list"]];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)   // Unable to proceed
        {
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {    [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
             
                 
             } otherButtonTitles:@"OK", nil];
        }
        
    }
    
    else if ([WebHelper sharedHelper].tag == S_EditProfile)
    {
        [AppDel hideSpinner];
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            [[NSUserDefaults standardUserDefaults] setObject:firstNameTF.text forKey:@"UserFullName"];
            [[NSUserDefaults standardUserDefaults] setObject:secAnsTF.text forKey:@"AnswerString"];
            [[NSUserDefaults standardUserDefaults] setObject:secQuesTF.text forKey:@"QuestionString"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
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
    
    else if ([WebHelper sharedHelper].tag == S_PersonalInfo )        {
        if ([[response objectForKey:@"err-code"] intValue] == 1)
        {
            if ([[response objectForKey:@"type"] isEqualToString:@"Patient"])
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    phoneVVerticalConst.constant =  240;
                }
                else
                {
                    phoneVVerticalConst.constant =  180;
                }
                
                
                
                primaryAffV.hidden = otherAffV.hidden = privacyV.hidden = practiceV.hidden = YES;
                
                
                [self.view layoutIfNeeded];
                
                
                patientProfile = YES;
                
                
                physicianProfile = staffProfile = NO;
            }
            
            else if ([[response objectForKey:@"type"] isEqualToString:@"Physician"])
            {
                phoneVVerticalConst.constant = 0;
                
                privacyVerticalConst.constant = 0;
                
                
                primaryAffV.hidden = otherAffV.hidden = privacyV.hidden = practiceV.hidden = NO;
                
                
                [self.view layoutIfNeeded];
                
                
                physicianProfile = YES;
                
                
                patientProfile = staffProfile = NO;
                
                primaryAffL.text = [[response  objectForKey:@"primary_hospital"] objectForKey:@"name"];
                
                self.primaryAff = [response  objectForKey:@"primary_hospital"];
                
                jobTitleTF.text =( [[response objectForKey:@"job_title"] isEqual:[NSNull null]] ? @"" :[response objectForKey:@"job_title"]);
                
                desigTF.text = ([[response objectForKey:@"designation"] isEqual:[NSNull null]] ? @"" : [response objectForKey:@"designation"] );

                
                if ([[response objectForKey:@"privacy_enabled"] intValue] == 0)
                {
                    privacySwitch.on = NO;
                }
                
                else
                {
                    privacySwitch.on = YES;
                }
            }
            
            else if ([[response objectForKey:@"type"] isEqualToString:@"Staff"])
            {
                phoneVVerticalConst.constant =  0;
                
                privacyVerticalConst.constant = 0;
                
                
                otherAffV.hidden = NO;
                
                
                [self.view layoutIfNeeded];
                
                
                staffProfile = YES;
                
                
                physicianProfile = patientProfile = privacyV.hidden = NO;
                
                
                primaryAffL.text = [[response  objectForKey:@"primary_hospital"] objectForKey:@"name"];
                
                self.primaryAff = [response  objectForKey:@"primary_hospital"];
                
                
                jobTitleTF.text = [response objectForKey:@"job_title"];
                
                desigTF.text = [response objectForKey:@"designation"];

                
                if ([[response objectForKey:@"privacy_enabled"] intValue] == 0)
                {
                    privacySwitch.on = NO;
                }
                
                else
                {
                    privacySwitch.on = YES;
                }
            }
            
            firstNameTF.text = [response objectForKey:@"first_name"];
            
            lastNameTF.text = [response objectForKey:@"last_name"];
            
            secQuesTF.text = [response objectForKey:@"secu_ques"];
            
            secAnsTF.text = [response objectForKey:@"secu_ans"];
            
            phoneTF.text = [response  objectForKey:@"phone"];
            
            zipcodeTF.text = [response objectForKey:@"zip"];
            
            practiceTF.text = [response  objectForKey:@"practice_type"];
            
            self.otherAff = [response  objectForKey:@"other_hospitals"];
            
            
            [[NSUserDefaults standardUserDefaults] setValue:[response  objectForKey:@"secu_ques"] forKey:@"QuestionString"];
            
            [[NSUserDefaults standardUserDefaults] setValue:[response objectForKey:@"secu_ans"] forKey:@"AnswerString"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            NSArray *names = [self.otherAff valueForKey:@"name"];
            
            otherAffL.text = [names componentsJoinedByString:@","];
            
            
            [self numberPadAccessory];
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            [AppDel signOutFromAppSilent];
         
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                
                 
             } otherButtonTitles:@"OK", nil];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        
         [AppDel hideSpinner];
    }
}



- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    
    
    if ([WebHelper sharedHelper].tag == S_EditProfile)
    {
        if (bool_editProfileRetry)
        {
            [self performSelector:@selector(saveInfo) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_editProfileRetry = YES;
                     
                     [self saveInfo];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_editProfileRetry=NO;
                     
                     [self.navigationController popViewControllerAnimated: YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_PersonalInfo )
    {
        if (bool_PersonalProfileRetry)
        {
            [self performSelector:@selector(fetchPersonalProfile) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_PersonalProfileRetry = YES;
                     
                     [self fetchPersonalProfile];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_PersonalProfileRetry=NO;
                     
                     [self.navigationController popViewControllerAnimated: YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }

        
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connectS_PersonalInfo to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}






#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}




#pragma mark - Set required font

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [fNameL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [lNameL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        [secQuesL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        [secAnsL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        [jobL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        [desgL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [practiceL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [phoneL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [zipL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [primaryL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [otherL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [privateL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        
        [firstNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [lastNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [secQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [secAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [jobTitleTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [desigTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [practiceTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [zipcodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [primaryAffL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [otherAffL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        
        
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [fNameL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [lNameL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [secQuesL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [secAnsL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [jobL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [desgL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [practiceL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [phoneL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [zipL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [primaryL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [otherL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [privateL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        
        
        [firstNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [lastNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [secQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [secAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [jobTitleTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [desigTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [practiceTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [zipcodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [primaryAffL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [otherAffL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];

    }
}



@end

