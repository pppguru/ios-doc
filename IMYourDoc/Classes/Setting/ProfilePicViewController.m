//
//  ProfilePicViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ProfilePicViewController.h"


@interface ProfilePicViewController ()


@end


@implementation ProfilePicViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    profileImgV.hidden = YES;
    
    
    if (self.isFileTransfer)
    {
        profileImgV.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    else
    {
        
        profileImgV.image=[AppDel image];
    
    }
    
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        takePhotoBtn.hidden = YES;
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
    
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
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont1];
    
    [self performSelector:@selector(setProfileImg) withObject:nil afterDelay:0.1f];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Void

- (void)setProfileImg
{
    CGRect profileRect = profileImgV.frame;
    
    
    if (profileRect.size.width > profileRect.size.height)
    {
        profileRect.size.width = profileRect.size.height;
    }
    
    else if (profileRect.size.height > profileRect.size.width)
    {
        profileRect.size.height = profileRect.size.width;
    }
    
    
    profileImgV.frame = profileRect;
    
    profileImgV.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, profileImgV.center.y);
    
    profileImgV.hidden = NO;
    
    profileImgV.layer.cornerRadius = profileImgV.bounds.size.width / 2;
    
    profileImgV.layer.masksToBounds = YES;
}


- (void)imageUploading:(UIImage *)img
{
    NSTimeInterval  today = ([[NSDate date] timeIntervalSince1970]*1000);
    
    
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    
    
    NSArray *absoluteTime = [intervalString componentsSeparatedByString:@"."];
    
    
    NSArray *toUserString = [self.toUserName componentsSeparatedByString:@"@"];
    
    
    if (self.toUserName == nil)
    {
        toUserString = [[[[AppDel xmppStream] myJID] bare] componentsSeparatedByString:@"@"];
    }
    
    
    NSArray *fromUserString = [[[[AppDel xmppStream] myJID] bare] componentsSeparatedByString:@"@"];
    
    
    NSString *fileName = [NSString stringWithFormat:@"%@-@^@^@-%@-@^@^@-%@.jpeg", [fromUserString objectAtIndex:0], [toUserString objectAtIndex:0], [absoluteTime objectAtIndex:0]];
    
    
    CGSize imgSize = [[UIScreen mainScreen]bounds].size;
    
    
    float hfactor =  profileImgV.image.size.width / imgSize.width;
    float vfactor = profileImgV.image.size.height / imgSize.height;
    
    float factor = fmax(hfactor, vfactor);
    
    float newWidth = profileImgV.image.size.width / factor;
    float newHeight = profileImgV.image.size.height / factor;
    
    float leftOffset = (imgSize.width - newWidth) / 2;
    float topOffset = (imgSize.height - newHeight) / 2;
    
    
    UIGraphicsBeginImageContext(imgSize);
    
    
    [profileImgV.image drawInRect:CGRectMake(leftOffset, topOffset,newWidth, newHeight)];
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    
    NSData *imageData = UIImageJPEGRepresentation(newImage, .5f);
    
    
    NSString *imagePath = [self documentsPathForFileName:fileName];
    
    
    [imageData writeToFile:imagePath atomically:YES];
    
    
    float hfactor1 =  profileImgV.image.size.width / 80;
    float vfactor1 = profileImgV.image.size.height / 80;
    
    float factor1 = fmax(hfactor1, vfactor1);
    
    float newWidth1 = profileImgV.image.size.width / factor1;
    float newHeight1 = profileImgV.image.size.height / factor1;
    
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth1 , newHeight1));
    
    
    [profileImgV.image drawInRect:CGRectMake(0, 0,newWidth1, newHeight1)];
    
    
    UIImage *newImage1 = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    
    if (self.jidArr == nil && self.toUserName != nil)
    {
        [AppDel sendFileTransFerNotification:self.toUserName withFileName:fileName withImage:newImage1];
    }
    
    else
    {
        for (XMPPUserCoreDataStorageObject * user in self.jidArr)
        {
            [AppDel sendFileTransFerNotification:[user.jid bare] withFileName:fileName withImage:newImage1];
        }
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        profileImgV.layer.cornerRadius = profileImgV.bounds.size.width / 2;
        
        profileImgV.layer.masksToBounds = YES;
    }
    else
    {
        profileImgV.layer.cornerRadius = profileImgV.bounds.size.width / 2;
        
        profileImgV.layer.masksToBounds = YES;
    }
}





#pragma mark - NSString

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    
    return [documentsPath stringByAppendingPathComponent:name];
}


#pragma mark - IBAction methods

- (IBAction)navBack
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)submitTap
{
    if (self.isFileTransfer)
    {
        if (profileImgV.image == nil)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"You haven't selected a picture yet!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        else
        {
            [self imageUploading:profileImgV.image];
        }
    }
    
    else
    {
        if (profileImgV.image)
        {
            NSData *imageData = UIImageJPEGRepresentation(profileImgV.image, 0.7f);
            
            
            NSString *strEncode = [Base64 encode:imageData];
            
            
            [AppDel setProfilePic:strEncode withImage:imageData];
            
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"You haven't selected a picture yet!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


- (IBAction)takePhotoMethod
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    
    
    UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, ((screenSize.height / 2) - (screenSize.width / 2) - 34), screenSize.width - 4, screenSize.width - 4)];
    
    [path2 setUsesEvenOddFillRule:YES];
    
    
    [circleLayer setPath:[path2 CGPath]];
    
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenSize.width, screenSize.height) cornerRadius:0];
    
    [path appendPath:path2];
    
    [path setUsesEvenOddFillRule:YES];
    
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    
    fillLayer.path = path.CGPath;
    
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    
    fillLayer.opacity = 0.8;
    
    
    [picker.view.layer addSublayer:fillLayer];
    
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (IBAction)selectPhotoMethod
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
    
    if (self.isFileTransfer)
    {
        picker.allowsEditing = NO;
    }
    
    else
    {
        picker.allowsEditing = YES;
    }
    
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark - Update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - Image Picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.isFileTransfer)
    {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        profileImgV.image = chosenImage;
    }
    
    else
    {
        profileImgV.image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count] == 3)
    {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1] subviews] objectAtIndex:0];
        
        
        plCropOverlay.hidden = YES;
        
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0f, ((screenSize.height / 2) - (screenSize.width / 2)), screenSize.width, screenSize.width)];
        
        [path2 setUsesEvenOddFillRule:YES];
        
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenSize.width, (screenSize.height - 72)) cornerRadius:0];
        
        [path appendPath:path2];
        
        [path setUsesEvenOddFillRule:YES];
        
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        
        fillLayer.path = path.CGPath;
        
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        
        fillLayer.opacity = 0.8;
        
        
        [viewController.view.layer addSublayer:fillLayer];
    }
}


#pragma mark - Set required font

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }
    
}


@end

