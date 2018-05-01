//
//  UserAffiliationViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 02/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "UserAffiliationViewController.h"


@interface UserAffiliationViewController ()

- (IBAction)action_back:(id)sender;

@end


@implementation UserAffiliationViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
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
    
    
    [self numberPadAccessory];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont2];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Void

- (void)goBackWithHosp:(NSDictionary *)dict
{
    if ([self.delegate respondsToSelector:@selector(AffliationController:addedHosptial:)])
    {
        [self.delegate AffliationController:self addedHosptial:dict];
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - IBAction
- (IBAction)action_back:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(AffliationController:addedHosptial:)])
    {
        [self.delegate AffliationController:self addedHosptial:nil];
    }
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addTap
{
    if (([hospitalTF.text exactLength] == 0) || ([cityTF.text exactLength] == 0) || ([phoneTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return;
    }
    
    
    if ([phoneTF.text exactLength] < 10)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    
                                    @"addNetwork", @"method",
                                    
                                    [hospitalTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"hospital_name",
                                    
                                    [cityTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"city",
                                    
                                    [phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"phone_no",
                                    
                                    nil];
        
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_AddNetwork delegate:self];

        

    }
}


#pragma mark - Update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    
    if (textField == hospitalTF)
    {
        [cityTF becomeFirstResponder];
    }
    
    else if (textField == cityTF)
    {
        [phoneTF becomeFirstResponder];
    }
    
    else if (textField == phoneTF)
    {
        [phoneTF resignFirstResponder];
    }
    
    
    return YES;
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    float kbOffset = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].origin.y;
    
    
    float tfOffset = 0 ;
    
    
    if (hospitalTF.isEditing)
    {
        tfOffset = [self.view convertRect:hospitalTF.frame fromView:hospitalTF.superview].origin.y + hospitalTF.frame.size.height;
    }
    
    else if (cityTF.isEditing)
    {
        tfOffset = [self.view convertRect:cityTF.frame fromView:cityTF.superview].origin.y + cityTF.frame.size.height;
    }
    
    else if (phoneTF.isEditing)
    {
        tfOffset = [self.view convertRect:phoneTF.frame fromView:phoneTF.superview].origin.y + phoneTF.frame.size.height;
    }
    
    
    tfOffset += TFScroll.contentOffset.y;
    
    
    [TFScroll setContentOffset:CGPointMake(0, (((kbOffset - tfOffset) < 0) ? (tfOffset - kbOffset) : 0)) animated:YES];
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - KeyBoard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(phoneTFNumberPad)],
                            
                            nil];
    
    
    phoneTF.inputAccessoryView = numberToolbar;
}


- (void)phoneTFNumberPad
{
    [phoneTF resignFirstResponder];
    
    
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}



#pragma mark - Request


- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_AddNetwork)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [self performSelectorOnMainThread:@selector(goBackWithHosp:) withObject:[response objectForKey:@"hosp_details"] waitUntilDone:YES];
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
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}



#pragma mark - ASIHTTP

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
    
    
    if ([[responseDict objectForKey:@"err-code"] intValue] != 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"We were unable to process your request. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return;
    }
    
    
    if (request.tag == 1)
    {
        [self performSelectorOnMainThread:@selector(goBackWithHosp:) withObject:[responseDict objectForKey:@"hospital"] waitUntilDone:NO];
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    if (request.tag == 1)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"We were unable to process your request. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}




#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        
        [cityTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        
        [cityTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];

        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];

        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];

    }
}


@end

