//
//  SignupStepThreeViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "IMConstants.h"
#import "HospitalSearchViewController.h"
#import "SignupStepThreeViewController.h"
#import "ServiceAgreementOneViewController.h"
#import "ServiceAgreementTwoViewController.h"


@interface SignupStepThreeViewController () <HospitalSearchViewControllerDelegate>


@end


@implementation SignupStepThreeViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    

    
    if (self.registrationType == RegistrationTypeStaff || self.registrationType == RegistrationTypePhysician)
    {
        if (![self.userInfo objectForKey:@"practiceType"]|![self.userInfo objectForKey:@"jobTitle"]|![self.userInfo objectForKey:@"designation"]|![[self.userInfo objectForKey:@"practiceType"] count]==0|![[self.userInfo objectForKey:@"jobTitle"]count ]==0|![[self.userInfo objectForKey:@"designation"]count ]==0)
        {
          
            
            
            NSDictionary *dict ;
            
            dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"practiceTypes_jobTitle_designationList", nil] forKeys:[NSArray arrayWithObjects:@"method", nil]];
            
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            
            [[WebHelper sharedHelper] sendRequest:dict tag:S_PracticeTypes_jobTitle_designationList delegate:self];
            
        }
        
        else
        {
            self.practiceType = [self.userInfo objectForKey:@"practiceType"];
            
            self.jobTitle = [self.userInfo objectForKey:@"jobTitle"];
            
            self.designation = [self.userInfo objectForKey:@"designation"];
        }
        
    }


    

    
    [practiceTF addTarget:self.autoCompTV action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [jobTitleTF addTarget:self.autoJobCompTV action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [desigTF addTarget:self.autoDesigCompTV action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setRequiredFont2];

    
    [self.view endEditing:YES];
    
    
    
    if (!fetchingHospital)
    {
        if (self.registrationType == RegistrationTypeStaff || self.registrationType == RegistrationTypePhysician)
        {
            hospitalNameV.hidden = practiceV.hidden = NO;
            
            self.secondryHosp = [self.userInfo objectForKey:@"sec_hospital"];
            
            practiceTF.text = [self.userInfo objectForKey:@"practice_type"];
            
            jobTitleTF.text = [self.userInfo objectForKey:@"job_title"];
            
            desigTF.text = [self.userInfo objectForKey:@"designation_title"];
            
            
            
            if ([[self.userInfo objectForKey:@"hosp"] isKindOfClass:[NSDictionary class]])
            {
                self.hospital = [self.userInfo objectForKey:@"hosp"];
                
                
                hospitalNameTF.text = [self.hospital objectForKey:@"name"];
            }
            
            NSArray *names = [self.secondryHosp valueForKey:@"name"];
            
            secondaryHospTF.text = [names componentsJoinedByString:@","];

        }
        
        else
        {
            hospitalNameV.hidden = practiceV.hidden  = secHospitalV.hidden = YES;
            
            
        }
    }
    
    
 
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    fetchingHospital = NO;
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
    if (self.registrationType == RegistrationTypePatient)
    {
    }
    
    else
    {
        
        
        [self.userInfo setObject:(practiceTF.text.length > 0 ? practiceTF.text : @"") forKey:@"practice_type"];
        
        [self.userInfo setObject:(jobTitleTF.text.length > 0 ? jobTitleTF.text : @"") forKey:@"job_title"];
        
        [self.userInfo setObject:(desigTF.text.length > 0 ? desigTF.text : @"") forKey:@"designation_title"];
        
        [self.userInfo setObject:([[self.hospital objectForKey:@"hosp_id"] length] > 0 ? [self.hospital objectForKey:@"hosp_id"] : @"") forKey:@"hosp_id"];
        
        [self.userInfo setObject:([[self.hospital allKeys] count] > 0 ? self.hospital : @"") forKey:@"hosp"];
        
        
        if (self.secondryHosp)
        {
            [self.userInfo setObject:self.secondryHosp forKey:@"sec_hospital"];
        }
        
        
        NSArray *sec_ids = [self.secondryHosp valueForKey:@"hosp_id"];
        
        
        NSString *sec_hosps = [sec_ids componentsJoinedByString:@","];
        
        
        if (sec_hosps)
        {
            [self.userInfo setObject:sec_hosps forKey:@"sec_hosp_ids"];
        }
     }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{    
    if ([practiceTF.text exactLength] == 0  && (self.registrationType == RegistrationTypeStaff || self.registrationType == RegistrationTypePhysician))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter your Practice Type." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        return;
    }
    
    if ([[self.hospital allKeys] count] == 0 && (self.registrationType == RegistrationTypeStaff || self.registrationType == RegistrationTypePhysician))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter your Primary Affiliation." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        return;
    }
    
    
    
    [self.userInfo setObject:(practiceTF.text.length > 0 ? practiceTF.text : @"") forKey:@"practice_type"];
    
    [self.userInfo setObject:(jobTitleTF.text.length > 0 ? jobTitleTF.text : @"") forKey:@"job_title"];
    
    [self.userInfo setObject:(desigTF.text.length > 0 ? desigTF.text : @"") forKey:@"designation_title"];
    
    [self.userInfo setObject:[self.hospital objectForKey:@"hosp_id"] forKey:@"hosp_id"];
    
    [self.userInfo setObject:self.hospital  forKey:@"hosp"];
    
    
    if (self.secondryHosp)
    {
        [self.userInfo setObject:self.secondryHosp forKey:@"sec_hospital"];
    }
    
    
    NSArray *sec_ids = [self.secondryHosp valueForKey:@"hosp_id"];
    
    
    NSString *sec_hosps = [sec_ids componentsJoinedByString:@","];
    
    
    if (sec_hosps)
    {
        [self.userInfo setObject:sec_hosps forKey:@"sec_hosp_ids"];
    }
    

    
    [self.view endEditing:YES];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, 0);
    
    
    
    ServiceAgreementTwoViewController *service2VC = [[ServiceAgreementTwoViewController alloc] initWithNibName:@"ServiceAgreementTwoViewController" bundle:nil];
    
    service2VC.registrationType = self.registrationType;
    
    service2VC.userInfo = self.userInfo;
    
    [self.navigationController pushViewController:service2VC animated:YES];
    
}


- (IBAction)selectPrimaryHospital
{
    fetchingHospital = YES;
    
    [self.view endEditing:YES];
    
    HospitalSearchViewController  *hospVC=[[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


- (IBAction)selectSecondaryHospital
{
    fetchingHospital = YES;
    
    
    HospitalSearchViewController  *hospVC=[[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeMultiple;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


#pragma mark - Request

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_PracticeTypes_jobTitle_designationList)
    {
        
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            self.practiceType = [NSMutableArray arrayWithArray:[response objectForKey:@"practice_typeslist"]];
            
            self.jobTitle = [NSMutableArray arrayWithArray:[response objectForKey:@"job_title_list"]];
            
            self.designation = [NSMutableArray arrayWithArray:[response objectForKey:@"designation_list"]];
            
            
            
            [self.userInfo setObject:self.practiceType forKey:@"practiceType"];
            
            [self.userInfo setObject:self.jobTitle forKey:@"jobTitle"];
            
            [self.userInfo setObject:self.designation forKey:@"designation"];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)   // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}
- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == practiceTF)
    {
        [self.autoCompTV hideOptionsView];

        
        [self.view endEditing:YES];
        
        fetchingHospital = YES;
        
        
        HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
        
        hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
        
        hospVC.delegate = self;
        
        [self.navigationController pushViewController:hospVC animated:YES];
    }

    else if (textField == jobTitleTF)
    {
        

        [self.autoJobCompTV hideOptionsView];
            
        [desigTF becomeFirstResponder];
    }
    
    else if (textField == desigTF)
    {
        [self.autoDesigCompTV hideOptionsView];
        
        [desigTF resignFirstResponder];
    }
    

    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    NSDictionary *info = [noti userInfo];
    
    CGRect keyBRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, keyBRect.size.height , 0);
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    
    float tfOffset ;
    
    
    if (practiceTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + practiceV.frame.origin.y + practiceV.frame.size.height + 250.0 ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y) ;
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (hospitalNameTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + hospitalNameV.frame.origin.y + hospitalNameV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (secondaryHospTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + secHospitalV.frame.origin.y + secHospitalV.frame.size.height ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (jobTitleTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + jobV.frame.origin.y + jobV.frame.size.height + 250.0 ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (desigTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + designationV.frame.origin.y + designationV.frame.size.height + 250.0  ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, 0);
}


#pragma mark - KeyBoard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(pinTFNumberPad)],
                           
                           nil];
    
    
    pincodeTF.inputAccessoryView = numberToolbar;
    
    
    UIToolbar *numberToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar2.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(phoneTFNumberPad)],
                            
                            nil];
    
    
    phoneTF.inputAccessoryView = numberToolbar2;
    
    
    UIToolbar *numberToolbar3 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar3.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(zipTFNumberPad)],
                            
                            nil];
    
    
    zipcodeTF.inputAccessoryView = numberToolbar3;
}


- (void)pinTFNumberPad
{
    if (([pincodeTF.text exactLength] ==4) || ([pincodeTF.text exactLength] == 0))
    {
        [pincodeTF resignFirstResponder];
        
        [phoneTF becomeFirstResponder];
    }
    
    else
    {
        [pincodeTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)phoneTFNumberPad
{
    if (([phoneTF.text exactLength] >= 10) || ([phoneTF.text exactLength] == 0))
    {
        [phoneTF resignFirstResponder];
        
        [zipcodeTF becomeFirstResponder];
    }
    
    else
    {
        [phoneTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)zipTFNumberPad
{
    [zipcodeTF resignFirstResponder];
    
    
    [self.view endEditing:YES];
    
    
    if (self.registrationType == RegistrationTypeStaff || self.registrationType == RegistrationTypePhysician)
    {
        fetchingHospital = YES;
        
        
        HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
        
        hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
        
        hospVC.delegate = self;
        
        [self.navigationController pushViewController:hospVC animated:YES];
    }
    
    
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - HospitalManagement

- (NSMutableArray *)selectedHospitals:(HospitalSearchViewController *)controller
{
    if (controller.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        return [NSMutableArray arrayWithObjects:self.hospital, nil];
    }
    
    
    if (self.secondryHosp == nil)
    {
        self.secondryHosp = [NSMutableArray array];
    }
    
    
    return self.secondryHosp;
}


- (void)HospitalController:(HospitalSearchViewController *)controller selectedHosptials:(NSMutableArray *)selectedHosps
{
    if (controller.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        self.hospital = [selectedHosps lastObject];
        
        
        hospitalNameTF.text = [self.hospital objectForKey:@"name"];
    }
    
    else
    {
        self.secondryHosp = selectedHosps;
        
        
        NSArray *names = [self.secondryHosp valueForKey:@"name"];
        
        
        secondaryHospTF.text = [names componentsJoinedByString:@","];

        
        [jobTitleTF becomeFirstResponder];
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




#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [pincodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [zipcodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [hospitalNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        hospitalNameTF.minimumFontSize = 13.00;
        
        [practiceTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [desigTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [jobTitleTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [secondaryHospTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [pincodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [zipcodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [hospitalNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        hospitalNameTF.minimumFontSize = 13.00;
        
        [practiceTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [desigTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [jobTitleTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];

        [secondaryHospTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
    }
}




@end

