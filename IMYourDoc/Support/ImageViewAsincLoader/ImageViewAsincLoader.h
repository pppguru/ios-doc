//
//  ImageViewAsincLoader.h
//  UIImageLoader
//
//  Created by Harminder on 23/01/13.
//  Copyright (c) 2013 Harminder. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface ImageViewAsincLoader : UIImageView<NSURLConnectionDelegate>
{
    long long contentSize;
    
    NSMutableData *imageData;
	
    UIActivityIndicatorView *progress;
}


@property (nonatomic, assign) BOOL cachedisabled;

@property (nonatomic, retain) NSURL *url;

@property (nonatomic, retain) NSURLConnection *connection;

@property (nonatomic, retain) NSBlockOperation * operation;


+ (void) clearQue;
+ (void) clearcache;

+ (void) pause: (id) key;
+ (void) resume: (id) key;

- (void) downloadFromURL: (NSURL *) url;


+ (UIImage *) cache: (NSURL *) url;


+ (NSMutableArray *) createQueforViewController: (id) key;


@end
