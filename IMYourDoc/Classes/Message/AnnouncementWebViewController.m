//
//  AttachmentViewController.m
//  IMYourDoc
//
//  Created by Harminder on 09/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "AnnouncementWebViewController.h"


@interface AnnouncementWebViewController ()<UIScrollViewDelegate>


@end


@implementation AnnouncementWebViewController
@synthesize str_ann_id,str_title;

@synthesize webview_attachement,imageview_navigationbar,lbl_title;


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
  
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        if (str_ann_id.length>0)
        {
            
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:
                                @"getAnnouncement", @"method",
                                
                                [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                
                                str_ann_id, @"ann_id",
                                nil];
            
            [AppDel showSpinnerWithText:@"Requesting..."];
            [[WebHelper sharedHelper] setWebHelperDelegate:self];

            [[WebHelper sharedHelper]sendRequest:dict   tag:S_GetAnnouncement delegate:self];
            
        }
    }

}


- (void)viewWillAppear:(BOOL)animated
{
 
    [super viewWillAppear:animated];
    
}

#pragma mark - WebView delegate 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [AppDel hideSpinner];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [AppDel hideSpinner];
}

-(void)loadPageAfterResponseWithPagetitle:(NSString*)pagetitle titleBarColor:(NSString*)color url:(NSString*)urL
{
    lbl_title.text=pagetitle;
    [imageview_navigationbar  setBackgroundColor:
     [self getUIColorObjectFromHexString:color alpha:.9]];

    
    if (urL)
    {
        //Changed the encoding module into UTF8 - Made By Ronald [10/26 Ronald]
        [webview_attachement loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[urL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }
    webview_attachement.delegate=self;
    webview_attachement.scalesPageToFit=YES;
    [webview_attachement.scrollView flashScrollIndicators];
    webview_attachement.scrollView.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    

}


#pragma mark helper method 
- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    
    unsigned int hexint = [self intFromHexString:hexStr];
    
    
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    

    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
   
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
 
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{

    if ([WebHelper sharedHelper].tag == S_GetAnnouncement)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [self loadPageAfterResponseWithPagetitle:[response objectForKey:@"page_title"] titleBarColor:[response objectForKey:@"title_bar_color"] url:[response objectForKey:@"url"]];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            [AppDel hideSpinner];
            
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             {
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end

