//
//  ImageViewAsincLoader.m
//  UIImageLoader
//
//  Created by Harminder on 23/01/13.
//  Copyright (c) 2013 Harminder. All rights reserved.
//


#import "NSData+Base64.h"
#import "ImageViewAsincLoader.h"


@interface ImageViewAsincLoader()


@end


@implementation ImageViewAsincLoader


@synthesize cachedisabled;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self)
    {
        
    }
	
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
	if (self)
    {
        
    }
	
    return self;
}


+ (NSMutableDictionary *) cache
{
    static NSMutableDictionary *cache = nil;
    
	if (cache == nil)
        cache = [NSMutableDictionary dictionary];
    
    return cache;
}


+ (void) clearcache
{
    [[self cache] removeAllObjects];
}


+ (UIImage *) cache: (NSURL *) url;
{
    NSString *filepath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSData *data = [NSData dataWithBytes:[[url absoluteString] UTF8String] length:[[url absoluteString] length]];
    
    filepath = [filepath stringByAppendingPathComponent:[[NSString stringWithFormat:@"%@.jpg", [data base64EncodedString]] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filepath]];
        
        return image;
    }
	
    return nil;
}


- (void) setCache: (UIImage *) image url: (NSURL *) url
{
   if (image)
   {
       NSString *filepath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
       
	   
	   NSData *data = [NSData dataWithBytes:[[url absoluteString] UTF8String] length:[[url absoluteString] length]];
	   
	   filepath = [filepath stringByAppendingPathComponent:[[NSString stringWithFormat:@"%@.jpg",[data  base64EncodedString]] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
	   
	   NSData *imaged = UIImageJPEGRepresentation(image,1);
       
       NSError * error = nil;
       
	   [imaged writeToFile:filepath options:NSDataWritingAtomic error:&error] ;
       
       NSLog(@"%@", error);
   }
}


- (void) setFrame: (CGRect) frame
{
    [super setFrame:frame];
    
    if (progress)
    {
        progress.frame = self.bounds;
    }
}


- (void) addProgress
{
    if (progress == nil)
        progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    progress.frame = self.bounds;
   
    [self addSubview:progress];
    
    [self bringSubviewToFront:progress];
    
    [progress startAnimating];
}


- (void) downloadFromURL: (NSURL *) url
{
    self.url = url;
    
    if (!self.cachedisabled)
    {
        UIImage *img = [ImageViewAsincLoader cache:url];
        
        if (img)
        {
            self.image = img;
			
            return;
        }
    }
	
    else
    {
        if ([[[ImageViewAsincLoader cache] allKeys] containsObject:url])
        {
			self.image = [[ImageViewAsincLoader cache] objectForKey:url];
            
			return;
        }
    }
    
    if (self.connection)
    {
        [self.connection cancel];
    }
	
    
    imageData = [[NSMutableData alloc] init];
    
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:300];
    
    
    [self addProgress];
    
    
    progress.hidden = NO;
    
    
	self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	
    
	[[ImageViewAsincLoader createQueforViewController:nil] addObject:self.connection];
	
    
	return;
}


+ (void) pause: (id) key
{
    for (NSURLConnection *connection in [self createQueforViewController:key])
    {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
			[connection cancel];
		
		});
	}
	
    [[self cache] removeAllObjects];
}


+ (void) resume: (id) key
{
    [[self loaderQue] cancelAllOperations];
    
    [[self nocachedque] cancelAllOperations];
    
    [self createQueforViewController:key] ;
}


- (void) removeFromSuperview
{
    if (self.connection)
    {
        [self.connection cancel];
    
        self.connection = nil;
    }
    
    [super removeFromSuperview];
}


+ (void) clearQue
{
	[[ImageViewAsincLoader loaderQue] cancelAllOperations];
}


+ (NSMutableArray *) createQueforViewController: (id) key
{
	static NSMutableArray *array = nil;
    
    if (array == nil)
    {
        array = [NSMutableArray array];
    }
	
    return array;
}


+ (NSOperationQueue *) loaderQue
{
    static NSOperationQueue *que = nil;
	
    if (que == nil)
        que = [[NSOperationQueue alloc] init];
    
    que.maxConcurrentOperationCount = 20;
   
    return que;
}


+ (NSOperationQueue *) nocachedque
{
    static NSOperationQueue *que = nil;
	
    if (que == nil)
        que = [[NSOperationQueue alloc] init];
	
	que.maxConcurrentOperationCount = 50;
    
    return que;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[ImageViewAsincLoader createQueforViewController:nil] removeObject:connection];
    
    [progress stopAnimating];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [imageData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
    
    if ([self.url isEqual:connection.currentRequest.URL])
        self.image = [UIImage imageWithData:imageData];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[ImageViewAsincLoader createQueforViewController:nil] removeObject:connection];
    
	if ([self.url isEqual:connection.currentRequest.URL])
		self.image = [UIImage imageWithData:imageData];
   
    if (!self.cachedisabled)
        [self setCache:[UIImage imageWithData:imageData] url:connection.currentRequest.URL];
    
	else
		[[ImageViewAsincLoader cache] setObject:[UIImage imageWithData:imageData] forKey:connection.currentRequest.URL];

    imageData = nil;
    
	[progress stopAnimating];
	
	progress.hidden = YES;
}


@end
