//
//  AttachmentViewController.m
//  IMYourDoc
//
//  Created by Harminder on 09/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "AttachmentWebViewController.h"


@interface AttachmentWebViewController ()<UIScrollViewDelegate>


@end


@implementation AttachmentWebViewController
@synthesize webview_attachement;


#pragma mark - View LifeCycle

- (void)viewDidLoad
{  [AppDel hideSpinner];
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if (self.url)
    {
    
        //Changed the encoding module into UTF8 - Made By Ronald [10/26 Ronald]
        [webview_attachement loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }
     webview_attachement.delegate=self;
    
     webview_attachement.scalesPageToFit=YES;
    
    [webview_attachement.scrollView flashScrollIndicators];
    
    webview_attachement.scrollView.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    
  
    
    
}




#pragma mark - WebView delegate 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
     [AppDel showSpinnerWithText:@"Loading..."];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
 
        [AppDel hideSpinner];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
        [AppDel hideSpinner];
}

@end

