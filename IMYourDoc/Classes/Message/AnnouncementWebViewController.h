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
#import "FontHeaderLabel.h"

@interface AnnouncementWebViewController : UIViewController<UIWebViewDelegate,WebHelperDelegate>
{
    IBOutlet ImageViewAsincLoader *attchementImage;
}
@property (strong, nonatomic) IBOutlet FontHeaderLabel *lbl_title;

@property (strong, nonatomic) IBOutlet UIImageView *imageview_navigationbar;

@property (strong, nonatomic) IBOutlet UIWebView *webview_attachement;

@property (nonatomic, strong) NSString *url;
@property(nonatomic,strong )NSString *str_ann_id;
@property(nonatomic,strong )NSString *str_title;
@end

