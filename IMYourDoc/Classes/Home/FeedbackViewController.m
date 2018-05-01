//
//  FeedbackViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "FeedbackViewController.h"
#import "BroadCastGroup+ClassMethod.h"
#import "AppDelegate+ClassMethods.h"


@interface FeedbackViewController ()
{
    BOOL boolService_feedbackRetry, bool_sumbmitTap;
    
}

@end


@implementation FeedbackViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    

    
    


}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    
    [self setRequiredFont1];
    
    [self txtViewLayerAttribute];
	
    
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


    feedbackTVHeight = feedbackTxtView.frame.size.height;
	
	
    editingDoneImgIcon.hidden = YES;
	
	
    editingDoneBtn.enabled = NO;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDone) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter ]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
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


- (IBAction)editingDone
{
	[self.view endEditing:YES];
    
  
}


- (IBAction)websiteTap
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://imyourdoc.com/index.php?option=com_forme&Itemid=88"]];
}


- (IBAction)contactTap
{
    //(800) 40980781 (800) 409 8078
    NSString *phoneNumber = @"+18004098078";
 if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", phoneNumber]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", phoneNumber]]];
    }
 else
 {
     [[[UIAlertView alloc] initWithTitle:nil message:@"Call facility is not available on your device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
 }
}


- (IBAction)submitFeedback
{
   feedbackTxtView.text = [feedbackTxtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self.view endEditing:YES];
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        return;
    }
    
    
    if (feedbackTxtView.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"We didn't see any feedback? Please let us know what you think!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        return;
    }
    
    [feedbackTxtView resignFirstResponder];

    bool_sumbmitTap = YES;
    
    [self submitFeedbackMethod];
    
 }



- (void)submitFeedbackMethod
{
    if (boolService_feedbackRetry && !bool_sumbmitTap)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        boolService_feedbackRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Processing..."];
        
        boolService_feedbackRetry = YES;
        
        bool_sumbmitTap = NO;
    }
    
    
    NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                @"feedback", @"method",
                                
                                [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                
                                feedbackTxtView.text, @"comment",
                                
                                nil];
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_Feedback delegate:self];
}



- (IBAction)termsAndConditionsTap
{
    [self.view endEditing:YES];
    
    TermsAndConditionsViewController *termsVC = [[TermsAndConditionsViewController alloc] initWithNibName:@"TermsAndConditionsViewController" bundle:nil];
    
    [self.navigationController pushViewController:termsVC animated:YES];
}


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - TextView

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [TVScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    
    [textView resignFirstResponder];
	
	
    return YES;
}


#pragma mark - Keyboard

- (void) keyboardWillShow: (NSNotification *) noti
{
    [TVScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    if ([feedbackTxtView isFirstResponder])
    {
        editingDoneImgIcon.hidden = NO;
        
        [TVScroll setContentOffset:CGPointMake(0, (pleaseL.frame.origin.y - 5.0)) animated:YES];

        editingDoneBtn.enabled = YES;
        
        
        CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
        
        
        if ((keyBFrame.origin.y) < (28 + feedbackTxtView.frame.origin.y + feedbackTxtView.frame.size.height - pleaseL.frame.origin.y))
        {
            CGFloat TVHeightCovered = (28 + feedbackTxtView.frame.origin.y + feedbackTxtView.frame.size.height - pleaseL.frame.origin.y) - keyBFrame.origin.y ;
            
            
            feedbackTVHeightConstraint.constant -= TVHeightCovered;
        }
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    if ([feedbackTxtView resignFirstResponder])
    {
        editingDoneImgIcon.hidden = YES;
        
        
        editingDoneBtn.enabled = NO;
        
        
        [TVScroll setContentOffset:CGPointMake(0, 0) animated:YES];
        
        
        feedbackTVHeightConstraint.constant = 0.0 * feedbackTVHeight;
    }
}


#pragma mark - Void

- (void) txtViewLayerAttribute
{
    feedbackTxtView.layer.borderWidth = 1.0f;
    
    feedbackTxtView.layer.borderColor = [[UIColor colorWithRed:175.0/ 250.0 green:177.0/ 250.0 blue:180.0/ 250.0 alpha:1.0] CGColor];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (!feedbackTVAllSet)
        {
            feedbackTVHeightConstraintIpad.constant -= (0.1) * (feedBackContainer.frame.size.height);
            
            [feedBackContainer layoutIfNeeded];
            
            feedbackTVAllSet = YES;
        }
    }
    else
    {
        feedbackTVHeightConstraintIpad.constant = (0.0) * (feedBackContainer.frame.size.height);
        
        [feedBackContainer layoutIfNeeded];
        
        feedbackTVAllSet = NO;
    }
}


- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [webLinkBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [phnBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [termsBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        
        [detail1 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [detail2 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [detail3 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [detail4 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [detail5 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [feedbackTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        
        if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
        {
            if (!feedbackTVAllSet)
            {
                feedbackTVHeightConstraintIpad.constant -= (0.1) * (feedBackContainer.frame.size.height);
                
                [feedBackContainer layoutIfNeeded];
                
                feedbackTVAllSet = YES;
            }
            
        }
        else
        {
            feedbackTVHeightConstraintIpad.constant = (0.0) * (feedBackContainer.frame.size.height);
            
            [feedBackContainer layoutIfNeeded];
            
            feedbackTVAllSet = NO;
        }
    }
    else
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [webLinkBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:15.00]];
        
        [phnBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:15.00]];
        
        [termsBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:15.00]];
        
        
        [detail1 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [detail2 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [detail3 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [detail4 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [detail5 setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [feedbackTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
    }
}



#pragma mark - ASIRequestDelegate


- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    

    if ([WebHelper sharedHelper].tag == S_Feedback)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIDX) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } otherButtonTitles:@"OK", nil];
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
            
            return;
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 300)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            return;
            
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    
    if (boolService_feedbackRetry)
    {
         [self performSelector:@selector(submitFeedbackMethod) withObject:nil afterDelay:.9];
    }
    else
    {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
         {
             
             if (btnIDX==0)
             {
                 boolService_feedbackRetry=YES;
                 
                 [self submitFeedback];
             }
             if (btnIDX==1)
             {
                 boolService_feedbackRetry=NO;
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }
             
         } otherButtonTitles:@"Retry" ,@"Try Later", nil];
    }
}




@end

