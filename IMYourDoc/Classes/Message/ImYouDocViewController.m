//
//  ImYouDocViewController.m
//  IMYourDoc
//
//  Created by OSX on 15/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"

@interface ImYouDocViewController ()
{
    UIVisualEffectView *effectView;
    UIVisualEffectView *vibrantView;
}
@end

@implementation ImYouDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
      // Do any additional setup after loading the view.
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self basicfunctionalityOfSDLCinbase];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - life cycle basic functionality
-(void)basicfunctionalityOfSDLCinbase
{
    
    //code update the status of the xmpp connection
    if ([AppDel isConnected])
    {
        secure_lbl.text = @"Securely Connected";
        
        secure_image.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else if([AppDel isConnecting])
    {
        secure_lbl.text = @"Connecting";
        
        secure_image.image = [UIImage imageNamed:@"secure_icon"];
    }
    else if([AppDel isAuthenticating])
    {
        secure_lbl.text = @"Authenticating";
        
        secure_image.image = [UIImage imageNamed:@"secure_icon"];
    }
    else
    {
        secure_lbl.text = @"Not Connected";
        
        secure_image.image = [UIImage imageNamed:@"unsecure_icon"];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
}
#pragma mark - NotificationCenter

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secure_lbl.text = [dict objectForKey:@"status"];
    
    
    [secure_image setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}

#pragma mark - Potential PHI behind should be obscured behind PIN dialog and in multitasking views.



- (void)hide:(id)object
{
    // create blur effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // create vibrancy effect
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
    
    // add blur to an effect view
     effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
     effectView.frame = self.view.frame;
    
    // add vibrancy to yet another effect view
    vibrantView = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
    vibrantView.frame = self.view.frame;
    
    
    // add both effect views to the image view
    [self.view addSubview:effectView];
    [self.view addSubview:vibrantView];
    
}

- (void)show:(id)object
{
    [effectView removeFromSuperview];
    [vibrantView removeFromSuperview];
    
}



@end
