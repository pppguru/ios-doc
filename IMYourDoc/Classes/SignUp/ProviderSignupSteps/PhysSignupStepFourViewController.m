//
//  PhysSignupStepFourViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "HospitalSearchViewController.h"
#import "PhysSignupStepTwoViewController.h"
#import "PhysSignupStepOneViewController.h"
#import "PhysSignupStepFourViewController.h"
#import "PhysSignupStepThreeViewController.h"
#import "ServiceAgreementTwoViewController.h"


@interface PhysSignupStepFourViewController () <HospitalSearchViewControllerDelegate>


@end


@implementation PhysSignupStepFourViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        if (![self.userInfo objectForKey:@"practiceType"])
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  @"fetch_practice_type", @"method",
                                  
                                  nil];
            
            
            [AppDel showSpinnerWithText:@"Fetching Practice List..."];
            
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://www.imyourdoc.com/joomla/service.php"]];
            
            [request setRequestMethod:@"POST"];
            
            [request addRequestHeader:@"Connection" value:@"close"];
            
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            
            NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            
            
            [request setPostBody:[postData mutableCopy]];
            
            [request setValidatesSecureCertificate:NO];
            
            [request setDelegate:self];
            
            [request startAsynchronous];
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
    
    
    practiceTF.text = [self.userInfo objectForKey:@"practice_type"];
    
    jobTitleTF.text = [self.userInfo objectForKey:@"job_title"];
    
    desigTF.text = [self.userInfo objectForKey:@"designation_title"];
    
    
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
    [self.userInfo setObject:(practiceTF.text.length > 0 ? practiceTF.text : @"") forKey:@"practice_type"];
    
    [self.userInfo setObject:(jobTitleTF.text.length > 0 ? jobTitleTF.text : @"") forKey:@"job_title"];
    
    [self.userInfo setObject:(desigTF.text.length > 0 ? desigTF.text : @"") forKey:@"designation_title"];
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{
    if ([self validateData])
    {
        ServiceAgreementTwoViewController *service2VC = [[ServiceAgreementTwoViewController alloc] initWithNibName:@"ServiceAgreementTwoViewController" bundle:nil];
        
        service2VC.registrationType = self.registrationType;
        
        service2VC.userInfo = self.userInfo;
        
        [self.navigationController pushViewController:service2VC animated:YES];
    }
}


- (IBAction)selectPrimaryHospital
{
    fetchingHospital = YES;
    
    
    HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


- (IBAction)selectSecondaryHospital
{
    fetchingHospital = YES;
    
    
    HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeMultiple;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


#pragma mark - Request

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [AppDel hideSpinnerAfterDelayWithText:@"Some error occurred" andImageName:@"warning.png"];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
    
    
    if ([[response objectForKey:@"err-code"] intValue] == 0)    // Success
    {
        self.practiceType = [NSMutableArray arrayWithArray:[response objectForKey:@"practice_type"]];
        
        self.jobTitle = [NSMutableArray arrayWithArray:[response objectForKey:@"job_title"]];
        
        self.designation = [NSMutableArray arrayWithArray:[response objectForKey:@"designation"]];
        
        
        [self.userInfo setObject:self.practiceType forKey:@"practiceType"];
        
        [self.userInfo setObject:self.jobTitle forKey:@"jobTitle"];
        
        [self.userInfo setObject:self.designation forKey:@"designation"];
    }
    
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
   // [self.view endEditing:YES];
    
    
    if (textField == practiceTF || (([practiceTF.text exactLength] == 0)))
    {
        [jobTitleTF becomeFirstResponder];
    }

    
    else if (textField == jobTitleTF)
    {
        [desigTF becomeFirstResponder];
    }
    
    else if (textField == desigTF )
    {
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
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, keyBRect.size.height / 1.4 , 0);
    
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
    
    if (jobTitleTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + jobTitleV.frame.origin.y + jobTitleV.frame.size.height + 250.0 ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (desigTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + desigV.frame.origin.y + desigV.frame.size.height + 250.0;
        
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
        return [NSMutableArray arrayWithObjects:self.hospital, nil];
    }
    
    
    if (self.secondryHosp == nil)
    {
        self.secondryHosp = [NSMutableArray array];
    }
    
    
    return self.secondryHosp;
}



- (BOOL)validateData
{
    [UIView animateWithDuration:.25 animations:^{
        
        self.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
    }];
    
    
    if ([practiceTF.text exactLength] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to enter your practice type." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }


    
    

    
    [self.userInfo setObject:practiceTF.text forKey:@"practice_type"];
    
    [self.userInfo setObject:jobTitleTF.text forKey:@"job_title"];
    
    [self.userInfo setObject:desigTF.text forKey:@"designation_title"];
    

    
    return YES;
}


@end

