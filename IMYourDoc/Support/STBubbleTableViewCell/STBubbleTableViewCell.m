//
//  STBubbleTableViewCell.m
//  STBubbleTableViewCellDemo
//
//  Created by Cedric Vandendriessche on 24/08/13.
//  Copyright 2013 FreshCreations. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "STBubbleTableViewCell.h"

#import "AttachmentWebViewController.h"

#define  TAG_B 10998
#define  TAG_AttachmentImage 103788
#define  TAG_infoLB 1037828
#define  TAG_usernameLB 10373288
#define  TAG_AttachmentImageBtn 34103788
#define  TAG_lbl_messageContent 34307738
#define TAG_messageStatLB  9087877
#define TAG_timeLB 130099

const CGFloat STBubbleWidthOffset = 50.0f;
const CGFloat STBubbleImageSize = 30.0f;

@implementation STBubbleTableViewCell
@synthesize lbl_messageContent;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _bubbleView=(UIImageView *)[self viewWithTag:TAG_B];
    if(_bubbleView==nil)
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bubbleView.userInteractionEnabled = YES;
    _bubbleView.tag=TAG_B;
    
    [self.contentView addSubview:_bubbleView];
    [self.contentView sendSubviewToBack:_bubbleView];
    
    
    self.userImage.userInteractionEnabled = YES;
    self.userImage.layer.cornerRadius = 5.0;
    self.userImage.layer.masksToBounds = YES;
    
    
    // *******************Gesture**********************
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    
    [_bubbleView addGestureRecognizer:longPressRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.lbl_messageContent addGestureRecognizer:longPressRecognizer1];
    
    _selectedBubbleColor = STBubbleTableViewCellBubbleColorAqua;
    _canCopyContents = YES;
    _selectionAdjustsColor = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    
    [self.userImage addGestureRecognizer:tapRecognizer];
    
    [self.attachmentImage addGestureRecognizer:tapRecognizer];
    
    _bubbleView.tag=TAG_B;
    lbl_messageContent.tag=TAG_lbl_messageContent;
    _attachmentImage.tag=TAG_AttachmentImageBtn;
    _timeLB.tag=TAG_timeLB;
    _messageStatLB.tag=TAG_messageStatLB;
    _infoButton.tag=TAG_infoLB;
    _userNameLB.tag=TAG_usernameLB;
    
    lbl_messageContent.translatesAutoresizingMaskIntoConstraints = NO;
    lbl_messageContent.enabledTextCheckingTypes = NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber;
    lbl_messageContent.delegate = self;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.attachmentImage.image)
    {
        self.bubbleView.frame = CGRectMake(self.attachmentImage.frame.origin.x
                                           - 2, self.attachmentImage.frame.origin.y - 2, self.attachmentImage.frame.size.width + 4, self.attachmentImage.frame.size.height + 12);
    }
    else
    {
        self.bubbleView.frame = CGRectMake(self.lbl_messageContent.frame.origin.x
                                           - 2, self.lbl_messageContent.frame.origin.y - 2, self.lbl_messageContent.frame.size.width + 4, self.lbl_messageContent.frame.size.height + 20);
    }
}

- (UITableView *)tableView
{
    UIView *tableView = self.superview;
    
    
    while(tableView)
    {
        if ([tableView isKindOfClass:[UITableView class]])
        {
            return (UITableView *)tableView;
        }
    
        tableView = tableView.superview;
    }
    
    return nil;
}
- (void)setImageForBubbleColor:(BubbleColor)color
{
    self.bubbleView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"Bubble-%lu.png", (long)color]] resizableImageWithCapInsets:UIEdgeInsetsMake(12.0f, 15.0f, 16.0f, 18.0f) resizingMode:UIImageResizingModeStretch];
    self.bubbleView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.bubbleView.transform = CGAffineTransformIdentity;
    self.bubbleView.clipsToBounds = YES;
}
- (void)layoutSubviews
{
    [self updateFramesForAuthorType:self.authorType];
}

- (void)updateFramesForAuthorType:(AuthorType)type
{
    [self setImageForBubbleColor:self.bubbleColor];
    
    if (self.attachmentImage.image)
    {
        self.bubbleView.frame = CGRectMake(self.attachmentImage.frame.origin.x
                                           - 4, self.attachmentImage.frame.origin.y - 12, self.attachmentImage.frame.size.width + 8, self.attachmentImage.frame.size.height + 32);
    }
    else
    {
        self.bubbleView.frame = CGRectMake(self.lbl_messageContent.frame.origin.x
                                           - 6, self.lbl_messageContent.frame.origin.y - 24, self.lbl_messageContent.frame.size.width + 12, self.lbl_messageContent.frame.size.height + 40);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self retryBubbleView];
    });
}

- (void)retryBubbleView
{
    if (self.attachmentImage.image)
    {
        self.bubbleView.frame = CGRectMake(self.attachmentImage.frame.origin.x
                                           - 4, self.attachmentImage.frame.origin.y - 12, self.attachmentImage.frame.size.width + 8, self.attachmentImage.frame.size.height + 32);
    }
    else
    {
        self.bubbleView.frame = CGRectMake(self.lbl_messageContent.frame.origin.x
                                           - 6, self.lbl_messageContent.frame.origin.y - 12, self.lbl_messageContent.frame.size.width + 12, self.lbl_messageContent.frame.size.height + 26);
    }
}

- (UIColor*) randomColor{
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

/*
-(void)testingFeatures
{
    if(TARGET_IPHONE_SIMULATOR)
    {
        [self.userImage.layer setBorderColor:[UIColor blueColor].CGColor];
        [self.userImage.layer setBorderWidth:1.0f];
    }
    if(TARGET_IPHONE_SIMULATOR)
    {
        [self.lbl_messageContent.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.lbl_messageContent.layer setBorderWidth:1.0f];
    }
    if(TARGET_IPHONE_SIMULATOR)
    {
        [self.contentView.layer setBorderColor:[UIColor redColor].CGColor];
        [self.contentView.layer setBorderWidth:1.0f];
    }
    if(TARGET_IPHONE_SIMULATOR)
    {
        [_userNameLB.layer setBorderColor:[UIColor cyanColor].CGColor];
        [_userNameLB.layer setBorderWidth:1.0f];
    }
    if(TARGET_IPHONE_SIMULATOR)
    {
        [_messageStatLB.layer setBorderColor:[UIColor redColor].CGColor];
        [_messageStatLB.layer setBorderWidth:1.0f];
        _messageStatLB.backgroundColor=[UIColor yellowColor];
    }
    if(TARGET_IPHONE_SIMULATOR)
    {
        [_timeLB.layer setBorderColor:[UIColor yellowColor].CGColor];
        [_timeLB.layer setBorderWidth:1.0f];
    }
    if(TARGET_IPHONE_SIMULATOR)
    {
        [_bubbleView.layer setBorderColor:[UIColor brownColor].CGColor];
        [_bubbleView.layer setBorderWidth:1.0f];
    }
    if(TARGET_IPHONE_SIMULATOR)
    {
        [_attachmentImage.layer setBorderColor:[UIColor brownColor].CGColor];
        [_attachmentImage.layer setBorderWidth:1.0f];
        _attachmentImage.backgroundColor = [UIColor redColor];
    }
}
*/
 
#pragma mark - Setters

- (void)setAuthorType:(AuthorType)type
{
	_authorType = type;
	
    
    [self updateFramesForAuthorType:_authorType];
}


- (void)setBubbleColor:(BubbleColor)color
{
	_bubbleColor = color;
	
    
    [self setImageForBubbleColor:_bubbleColor];
}


#pragma mark - UIGestureRecognizer methods

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
	{
		if (self.canCopyContents)
		{
			UIMenuController *menuController = [UIMenuController sharedMenuController];
            
            
            NSMutableArray *menus = [NSMutableArray array];
            
            
            if (self.message.isOutbound && self.message.isRoomMessage)
            {
                [menus addObject:[[UIMenuItem alloc] initWithTitle:@"Read By" action:@selector(infoTap:)]];
            }
            
            
            [menus addObject:[[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forward:)]];
            
            
            if (self.message.isOutbound && ([self.message.chatState intValue] == ChatStateType_NotDelivered || [self.message.chatState intValue] <= ChatStateType_Sending )&&[self.message.requestStatus integerValue] != RequestStatusType_Failed)
            {
                [menus addObject:[[UIMenuItem alloc] initWithTitle:@"Resend" action:@selector(resend:)]];
            }
            
            
            if (self.message.isOutbound && [self.message.fileTypeChat boolValue] && [self.message.requestStatus integerValue] == RequestStatusType_Failed)
            {
                [menus addObject:[[UIMenuItem alloc] initWithTitle:@"Retry" action:@selector(retryTap:)]];
            }
          
            
            
            if(TARGET_IPHONE_SIMULATOR)
            {
                
                 [menus addObject:[[UIMenuItem alloc] initWithTitle:@"detailOfMessage" action:@selector(detailOfMessage:)]];
                
            }
            
            [menus addObject:[[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteTap:)]];
            
            [menuController setMenuItems:menus];
            
            
            [self becomeFirstResponder];
            
            
            [menuController setTargetRect:self.bubbleView.frame inView:self];
            
            [menuController setMenuVisible:YES animated:YES];
			
            
            if (self.selectionAdjustsColor)
            {
				[self setImageForBubbleColor:self.bubbleColor];
            }
			
            
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenuController:) name:UIMenuControllerWillHideMenuNotification object:nil];
		}
	}
}


- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view == self.userImage)
    {
        if ([self.delegate respondsToSelector:@selector(tappedImageOfCell:atIndexPath:)])
        {
            [self.delegate tappedImageOfCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
        }
    }
}


#pragma mark - UIMenuController methods

- (BOOL)canPerformAction:(SEL)selector withSender:(id)sender
{
    if (selector == @selector(forward:))
    {
        if(self.offline)
        {
            return NO;
        }
        if([self.message.fileTypeChat isEqualToNumber:[NSNumber numberWithBool:YES]])
        {
            if([self.message.requestStatus intValue] < RequestStatusType_uploaded)
            {
                return NO;
            }
        }
            
        return YES;
    }
    
    if(selector==@selector(infoTap:))
    {
        if(self.message==nil)
        {
            return NO;
        }
        return YES;
    }
    
    if (selector == @selector(retryTap:))
    {
        if(self.message==nil)
        {
            return NO;
        }
        return YES;
    }
    
    
    if (selector == @selector(resend:))
    {
        if(self.offline!=nil)
        {
            return YES;
        }
        
        if([self.message.requestStatus integerValue]== RequestStatusType_Failed)
            return NO;
        
        return YES;
    }
    
    
    if (selector == @selector(deleteTap:))
    {
        if(self.message==nil)
        {
            return NO;
        }
        return YES;
    }
    
    if(TARGET_IPHONE_SIMULATOR)
    {
        
        if (selector == @selector(detailOfMessage:))
        {
            if(self.message==nil)
            {
                return NO;
            }
            return YES;
        }
    }
    return NO;
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)infoTap:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tappedInfoOfCell:atIndexPath:)])
    {
        [self.delegate tappedInfoOfCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
    }
}

- (void)copy:(id)sender
{
	[[UIPasteboard generalPasteboard] setString:self.lbl_messageContent.text];
}


- (void)forward:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tappedForwardOfCell:atIndexPath:)])
    {
        [self.delegate tappedForwardOfCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
    }
}


- (void)resend:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tappedResendOfCell:atIndexPath:)])
    {
        [self.delegate tappedResendOfCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
    }
}


- (void)retryTap:(id)sender
{
    self.message.requestStatus = [NSNumber numberWithInt:RequestStatusType_isYetToBeUpload];
    
    
    [[AppDel managedObjectContext_roster] save:nil];
}


-(void)detailOfMessage:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(tappedDetailOfMessageOfCell:atIndexPath:)])
    {
        [self.delegate tappedDetailOfMessageOfCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
    }
    
 
}

- (void)deleteTap:(id)sender
{
    self.message.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
    
    
    [[AppDel managedObjectContext_roster] save:nil];
}


- (void)willHideMenuController:(NSNotification *)notification
{
	[self setImageForBubbleColor:self.bubbleColor];
	
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}

#pragma mark Delegate TTTAttributedLabel

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithAddress:(NSDictionary *)addressComponents{
    NSLog(@"%@",addressComponents);
    
}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
    
    if(phoneNumber.length>4)
    {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                                componentsJoinedByString:@""];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", phoneNumber]]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", phoneNumber]]];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Call facility is not available on your device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"This number is too short to make a call!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}
@end

