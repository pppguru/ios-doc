//
//  GetRosterGrounp.h
//  IMYourDoc
//
//  Created by macbook on 28/08/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol GetRosterGrounpDelegate;


@interface GetRosterGrounp : NSObject
{
	NSInteger screenIndex;
    
	NSMutableData *responseData;
    
	NSURLConnection *gpConnection;
}


@property (nonatomic) NSInteger screenIndex;

@property (nonatomic, assign) id <GetRosterGrounpDelegate> delegate;

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSURLConnection *gpConnection;


- (void) cancelDownload;

- (void) getRosterByGroupNameAPI;


@end


@protocol GetRosterGrounpDelegate 


- (void)imYourDocRosterGrouping:(BOOL)isRosterFinished withscreen:(NSInteger)responseForScreen;


@end

