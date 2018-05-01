//
//  STBubbleTableViewCell.h
//  STBubbleTableViewCellDemo
//
//  Created by Cedric Vandendriessche on 24/08/13.
//  Copyright 2013 FreshCreations. All rights reserved.
//




#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "TTTAttributedLabel.h"


@protocol STBubbleTableViewCellDataSource, STBubbleTableViewCellDelegate;


extern const CGFloat STBubbleWidthOffset; // Extra width added to bubble
extern const CGFloat STBubbleImageSize; // The size of the image


typedef NS_ENUM(NSUInteger, AuthorType) {
	STBubbleTableViewCellAuthorTypeSelf = 0,
	STBubbleTableViewCellAuthorTypeOther
};


typedef NS_ENUM(NSUInteger, BubbleColor) {
	STBubbleTableViewCellBubbleColorGreen = 0,
	STBubbleTableViewCellBubbleColorGray = 1,
	STBubbleTableViewCellBubbleColorAqua = 2, // Default value of selectedBubbleColor
	STBubbleTableViewCellBubbleColorBrown = 3,
	STBubbleTableViewCellBubbleColorGraphite = 4,
	STBubbleTableViewCellBubbleColorOrange = 5,
	STBubbleTableViewCellBubbleColorPink = 6,
	STBubbleTableViewCellBubbleColorPurple = 7,
    STBubbleTableViewCellBubbleColorRed = 8,
	STBubbleTableViewCellBubbleColorYellow = 9
};


@interface STBubbleTableViewCell : UITableViewCell<TTTAttributedLabelDelegate>


@property (nonatomic, strong) ChatMessage *message;

@property (nonatomic, strong) OfflineMessages *offline;

@property (nonatomic, assign) AuthorType authorType;

@property (nonatomic, assign) BubbleColor bubbleColor;

@property (nonatomic, assign) BubbleColor selectedBubbleColor;


@property (nonatomic, assign) BOOL canCopyContents; // Defaults to YES

@property (nonatomic, assign) BOOL selectionAdjustsColor; // Defaults to YES


@property (nonatomic, weak) id <STBubbleTableViewCellDelegate> delegate;

@property (nonatomic, weak) id <STBubbleTableViewCellDataSource> dataSource;


@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) UIImageView *bubbleView;

@property unsigned long long  recivedsize;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lbl_messageContent;

@property (weak, nonatomic) IBOutlet UILabel *timeLB;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UILabel *userNameLB;

@property (weak, nonatomic) IBOutlet UILabel *messageStatLB;

@property (weak, nonatomic) IBOutlet UIImageView *attachmentImage;

@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageWidth;



@end


@protocol STBubbleTableViewCellDataSource <NSObject>


@optional


- (CGFloat)minInsetForCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end


@protocol STBubbleTableViewCellDelegate <NSObject>


@optional

- (void)tappedInfoOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)tappedImageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)tappedForwardOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tappedDetailOfMessageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tappedResendOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end

