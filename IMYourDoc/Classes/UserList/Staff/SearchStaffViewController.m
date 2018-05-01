//
//  SearchStaffViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "SearchViewController.h"
#import "SearchStaffViewController.h"
#import "HospitalSearchViewController.h"


@interface SearchStaffViewController () <HospitalSearchViewControllerDelegate>
{
    BOOL  bool_SearchStaffRetry, bool_SearchStaffFirstTime;
}

@end


@implementation SearchStaffViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    
    
    [providerIdTF addTarget:self.autoCompTV action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        
        
        [AppDel showSpinnerWithText:@"Fetching Practice List..."];
        
        NSDictionary *dict  = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"practiceTypes_jobTitle_designationList", nil] forKeys:[NSArray arrayWithObjects:@"method", nil]];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_PracticeTypes_jobTitle_designationList delegate:self];
    }
    
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [self setRequiredFont2];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    
    [self numberPadAccessory];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPREACHABILITY object:nil];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - IBAction

- (IBAction)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)hospitalTap
{
    fetchingHospital = YES;
    
    
    HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
    
    hospVC.fromSearch = YES;
    
    hospVC.delegate = self;
    
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


- (IBAction)searchStaff
{
    [self.view endEditing:YES];
    
    
    if (txt_userName.text.length == 0  && staffNameTF.text.length == 0 && hospitalTF.text.length == 0 && providerIdTF.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"To find the person you are looking for, one field is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return;
    }
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
    bool_SearchStaffFirstTime = YES;
    
    [self searchStaffMethod];
}


- (void)searchStaffMethod
{
    if (bool_SearchStaffRetry && !bool_SearchStaffFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_SearchStaffRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Searching..."];
        
        bool_SearchStaffRetry = YES;
        
        bool_SearchStaffFirstTime = NO;
    }
    
    //[AppDel showSpinnerWithText:@"Searching..."];
    
    NSString *hospID = ((![self.hospital valueForKey:@"hosp_id"]) ? @"" : [self.hospital valueForKey:@"hosp_id"]);
    
    NSString *proID = ([providerIdTF.text exactLength] == 0 ? @"" : providerIdTF.text);
    
    NSString *staffName = ([staffNameTF.text exactLength] == 0 ? @"" : [staffNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    
    
    
    NSString *userName = ([txt_userName.text exactLength] == 0 ? @"" : [txt_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    
    
    searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                  
                  @"search", @"method",
                  
                  @"Staff", @"user_type",
                  
                  staffName, @"name",
                  
                  userName, @"username",
                  
                  hospID, @"hosp_id",
                  
                  proID, @"practice_type",
                  
                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                  
                  [NSNumber numberWithInt:0], @"start",
                  
                  nil];
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchStaff delegate:self];
}


#pragma mark - Update Connectivity

- (void)updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    
     if (textField == staffNameTF)
    {
        [staffNameTF resignFirstResponder];
        
        
        fetchingHospital = YES;
        
        
        HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
        
        
        hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
        
        hospVC.delegate = self;
        
        
        [self.navigationController pushViewController:hospVC animated:YES];

        
        //[hospitalTF becomeFirstResponder];
    }
    
    else if (textField == hospitalTF)
    {
        [hospitalTF resignFirstResponder];
        
        
        [providerIdTF becomeFirstResponder];
    }
    
    else if (textField == providerIdTF)
    {
        [providerIdTF resignFirstResponder];
        
        [txt_userName becomeFirstResponder];
    }
    else if (textField == txt_userName)
    {
        [txt_userName resignFirstResponder];
        
        
        
    }
    
    return YES;
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    
    if (staffNameTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (TFScroll.frame.origin.y + staffNameV.frame.origin.y + staffNameV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (TFScroll.frame.origin.y + staffNameV.frame.origin.y + staffNameV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
    
    else if (hospitalTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (TFScroll.frame.origin.y + hospitalV.frame.origin.y + hospitalV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (TFScroll.frame.origin.y + hospitalV.frame.origin.y + hospitalV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
    
    else if (providerIdTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (TFScroll.frame.origin.y + providerV.frame.origin.y + providerV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, TFScroll.frame.origin.y + providerV.frame.origin.y + providerV.frame.size.height + 50 + 30 - keyBFrame.origin.y);
        }
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma  mark - Keyboard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(pinTFNumberPad)],
                           
                           nil];
    
    
    //providerIdTF.inputAccessoryView = numberToolbar;
}


- (void)pinTFNumberPad
{
    [providerIdTF resignFirstResponder];
    
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - Hospital Management

- (NSMutableArray *)selectedHospitals:(HospitalSearchViewController *)controller
{
    return [NSMutableArray arrayWithObjects:self.hospital, nil];
}


- (void)HospitalController:(HospitalSearchViewController *)controller selectedHosptials:(NSMutableArray *)selectedHosps
{
    if (controller.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        self.hospital = [selectedHosps lastObject];
        
        
        hospitalTF.text = [self.hospital objectForKey:@"name"];
        
        
        [providerIdTF becomeFirstResponder];
    }
}


#pragma mark - Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    if ([WebHelper sharedHelper].tag == S_SearchStaff)    // Search Staff
    {
        if([[response objectForKey:@"err-code"] isEqualToString:@"1"])
        {
            [AppDel hideSpinner];
            
            if ([[response objectForKey:@"users"] count])
            {
                SearchViewController *sVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                
                sVC.searchParam = [NSMutableDictionary dictionaryWithDictionary:searchDict];
                
                [sVC.searchParam setObject:[response objectForKey:@"has_more"] forKey:@"hasMore"];
                
                [sVC.searchParam setObject:((![self.hospital valueForKey:@"hosp_id"]) ? @"" : [self.hospital valueForKey:@"hosp_id"])forKey:@"hospID"];

                [sVC.searchParam setObject:([providerIdTF.text exactLength] == 0 ? @"" : providerIdTF.text) forKey:@"practiceType"];

                [sVC.searchParam setObject:([staffNameTF.text exactLength] == 0 ? @"" : [staffNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) forKey:@"staffName"];

                
                sVC.searchType = 2;
                
                sVC.searchArr = [[response objectForKey:@"users"] mutableCopy];
                
                [sVC.searchArr sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES]]];
                
                [self.navigationController pushViewController:sVC animated:YES];
            }
            
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"No User found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
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
        
    }
    
    else
        if ([WebHelper sharedHelper].tag == S_PracticeTypes_jobTitle_designationList)    // Practice List
        {
            if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
            {
                
                self.arr_practiceType = [NSMutableArray arrayWithArray:[response objectForKey:@"practice_typeslist"]];
            }
            
            else if ([[response objectForKey:@"err-code"] intValue] == 300)   // Unable to proceed
            {
                [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    
    if ([WebHelper sharedHelper].tag == S_SearchStaff)    // Search Staff
    {
        if (bool_SearchStaffRetry)
        {
            [self performSelector:@selector(searchStaffMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_SearchStaffRetry = YES;
                     
                     [self searchStaffMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_SearchStaffRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Set Required Font

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [anyOneL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [staffNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [txt_userName setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [hospitalTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [providerIdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [anyOneL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:11.00]];
        
        [staffNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
         [txt_userName setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [hospitalTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [providerIdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }
}

#pragma mark - Auto Completer

- (AutocompletionTableView *)autoCompTV
{
    if (!_autoCompTV)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [options setValue:[NSNumber numberWithBool:NO] forKey:ACOCaseSensitive];
        
        [options setValue:nil forKey:ACOUseSourceFont];
        
        
        _autoCompTV = [[AutocompletionTableView alloc] initWithTextField:providerIdTF andFrame:[self.view convertRect:providerIdTF.frame fromView:providerIdTF.superview] inViewController:self withOptions:options];
        
        _autoCompTV.autoCompleteDelegate = self;
        
        _autoCompTV.layer.borderColor = [[UIColor grayColor] CGColor];
        
        _autoCompTV.layer.borderWidth = 2.0f;
        
        _autoCompTV.layer.cornerRadius = 12.0f;
        
        _autoCompTV.suggestionsDictionary = self.arr_practiceType;
    }
    
    
    return _autoCompTV;
}


- (NSArray *) autoCompletion:(AutocompletionTableView *) completer suggestionsFor:(NSString *) string
{
    return self.arr_practiceType;
}


- (void) autoCompletion:(AutocompletionTableView *) completer didSelectAutoCompleteSuggestionWithIndex:(NSInteger) index
{
    
}



@end

