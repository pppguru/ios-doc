//
//  AttachmentViewController.h
//  IMYourDoc
//
//  Created by Harminder on 09/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ImageViewAsincLoader.h"


@interface AttachmentWebViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet ImageViewAsincLoader *attchementImage;
}


@property (strong, nonatomic) IBOutlet UIWebView *webview_attachement;

@property (nonatomic, strong) NSString *url;


@end

