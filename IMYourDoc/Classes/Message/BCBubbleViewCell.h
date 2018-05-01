//
//  BCBubbleViewCell.h
//  IMYourDoc
//
//  Created by vijayveer on 18/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "TTTAttributedLabel.h"

@class BroadCastMessageSender;
@class BCBubbleViewCell;


@protocol BCBubbleTableViewCellDataSource, BCBubbleTableViewCellDelegate;

extern const CGFloat BCBubbleWidthOffset; // Extra width added to bubble
extern const CGFloat BCBubbleImageSize;   // The size of the image


typedef NS_ENUM(NSUInteger, BCAuthorType) {
    BCBubbleTableViewCellAuthorTypeSelf = 0,
    BCBubbleTableViewCellAuthorTypeOther
};


typedef NS_ENUM(NSUInteger, BCBubbleColor) {
    BCBubbleTableViewCellBubbleColorGreen = 0,
    BCBubbleTableViewCellBubbleColorGray = 1,
    BCBubbleTableViewCellBubbleColorAqua = 2, // Default value of selectedBubbleColor
    BCBubbleTableViewCellBubbleColorBrown = 3,
    BCBubbleTableViewCellBubbleColorGraphite = 4,
    BCBubbleTableViewCellBubbleColorOrange = 5,
    BCBubbleTableViewCellBubbleColorPink = 6,
    BCBubbleTableViewCellBubbleColorPurple = 7,
    BCBubbleTableViewCellBubbleColorRed = 8,
    BCBubbleTableViewCellBubbleColorYellow = 9
};


@interface BCBubbleViewCell : UITableViewCell<TTTAttributedLabelDelegate>



@property (nonatomic, strong)  BroadCastMessageSender *message;



@property (nonatomic, assign) BCAuthorType authorType;


@property (nonatomic, assign) BCBubbleColor bubbleColor;

@property (nonatomic, assign) BCBubbleColor selectedBubbleColor;



@property (nonatomic, strong) UILabel *timeLB, *lbl_readBy, *lbl_dileveredTo,*lbl_status;

@property (nonatomic, strong) TTTAttributedLabel *lbl_messageContent;

@property (nonatomic, strong) TTTAttributedLabel *lbl_SubjectContent;


@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) UIButton *infoButton;

@property (nonatomic, strong) UIImageView *attachmentImage;


@property (nonatomic, assign) BOOL canCopyContents; // Defaults to YES

@property (nonatomic, assign) BOOL selectionAdjustsColor; // Defaults to YES


@property (nonatomic, weak) id <BCBubbleTableViewCellDelegate> delegate;

@property (nonatomic, weak) id <BCBubbleTableViewCellDataSource> dataSource;





@property unsigned long long  recivedsize;


@property (nonatomic, strong, readonly) UIImageView *bubbleView;

-(void)resetFramesWhenCellIsNotNil;

+(CGFloat )heightOfCellWithsubject:(NSString*)subject message:(NSString*)message;
-(void)didDelieved:(BOOL)boold;

@end



@protocol BCBubbleTableViewCellDataSource <NSObject>


@optional


- (CGFloat)minInsetForCell:(BCBubbleViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, copy) CGFloat (^callBackMinInsetForCell)(BCBubbleViewCell *cell,NSIndexPath *indexPath);
@end



@protocol BCBubbleTableViewCellDelegate <NSObject>


@optional

- (void)tappedInfoOfCell:(BCBubbleViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, copy) void (^callBackTappedInfoOfCell)(BCBubbleViewCell *cell,NSIndexPath *indexPath);

- (void)tappedImageOfCell:(BCBubbleViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, copy) void (^callBackTappedImageOfCell)(BCBubbleViewCell *cell,NSIndexPath *indexPath);

- (void)tappedForwardOfCell:(BCBubbleViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) void (^callBackTappedForwardOfCell)(BCBubbleViewCell *cell,NSIndexPath *indexPath);

- (void)tappedResendOfCell:(BCBubbleViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) void (^callBackTappedResendOfCell)(BCBubbleViewCell *cell,NSIndexPath *indexPath);



@end

