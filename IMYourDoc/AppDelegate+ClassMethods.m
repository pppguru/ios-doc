

#import "AppDelegate+ClassMethods.h"
#include <execinfo.h>
@implementation AppDelegate (ClassMethods)


-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"LogFileImyourDoc.csv"];
    
    
    
}    
   


-(void)writeLogInFileWithClassFunctionLine:(NSString*)pretyFunction  operation:(NSString*)opration Content:(NSString*)content parameter:(NSString*)parameters
{
    // grab a specific queue on first request and then use it all the time to avoid concurrency issues when writing to log file
    if( !loggingQueue)
        loggingQueue = dispatch_queue_create("com.imyourdoc.logQueue", NULL);

    
  dispatch_async(loggingQueue,^
                   {
                       
                       {
                           
                           unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[self dataFilePath] error:nil] fileSize];
                           
                           
                           
                           
                           if(fileSize>10485760)
                               
                           {
                               [[NSFileManager defaultManager] removeItemAtPath:[AppDel dataFilePath] error:nil];
                               
                               
                           }
                           
                           if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]])
                               
                           {
                               [[NSFileManager defaultManager] createFileAtPath: [self dataFilePath] contents:nil attributes:nil];
                               
                               NSString *writeString =[NSString stringWithFormat:@"\nclass_Method_Line ,Operation, Time , Content ,parameter \n"];
                               
                               
                               
                               NSFileHandle *handle;
                               handle = [NSFileHandle fileHandleForWritingAtPath: [self dataFilePath] ];
                               //say to handle where's the file fo write
                               [handle truncateFileAtOffset:[handle seekToEndOfFile]];
                               //position handle cursor to the end of file
                               
                               
                               [handle writeData:[[NSString stringWithFormat:@"DevName : %@ DOsVr: %@ ,AppVer: %@ BMode : %@, last Size of file,%llu, %@",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemVersion],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],APP_TARGET,fileSize,[self transformedValue:fileSize ] ] dataUsingEncoding:NSUTF8StringEncoding]];
                               
                               [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
                               
                           }
                           
                           
                           
                           // className , MethodName ,Opration, Time , Content
                           NSString *writeString =[NSString stringWithFormat:@"\n  %@ ,%@ ,%@ ,%@ ,%@ ",pretyFunction,opration,[NSDate date],content,parameters];
                           NSFileHandle *handle;
                           handle = [NSFileHandle fileHandleForWritingAtPath: [self dataFilePath] ];
                           //say to handle where's the file fo write
                           [handle truncateFileAtOffset:[handle seekToEndOfFile]];
                           //position handle cursor to the end of file
                           [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
                           
//                           NSLog(@"AppLog: %@", writeString);
                           }
                   } );
    
 
}



- (id)transformedValue:( unsigned long long)value
{
    
    unsigned long long convertedValue = value ;
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes",@"KB",@"MB",@"GB",@"TB"];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%f %@",(double)convertedValue, tokens[multiplyFactor]];
}



void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
    
        void *addr[7];
        int nframes = backtrace(addr, sizeof(addr)/sizeof(*addr));
        if (nframes > 1) {
            char **syms = backtrace_symbols(addr, nframes);
            NSLog(@"%s: caller: %s", __func__, syms[1]);
            
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",syms[2],__LINE__] operation:[NSString stringWithFormat:@"%s  ••• CRASH•••",syms[3]] Content:[NSString stringWithFormat:@"%@",[exception callStackSymbols]] parameter:@"For Testing"];
            
            
            free(syms);
        } else {
            NSLog(@"%s: *** Failed to generate backtrace.", __func__);
        }
    
    
    
    
    
    
}


#pragma mark - MBProgressHUD

- (void)hideSpinner
{
    [spinner hide:YES];
}

-(void)hideSpinnerafterDelay:(NSTimeInterval)time{
    
    [spinner hide:YES afterDelay:time];
}

- (void)setSpinnerText:(NSString *)text
{
    [spinner setLabelText:text];
}


- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (spinner != nil)
    {
        [spinner removeFromSuperview];
        
        spinner.delegate = nil;
        
        spinner = nil;
    }
}


- (void)showSpinnerWithText:(NSString *)text
{
    
    spinner=(MBProgressHUD *)[self.window viewWithTag:987456321];
    
    if(spinner==nil)
    {
        spinner = [[MBProgressHUD alloc] initWithView:self.window];
    }
    
    spinner.labelFont = [UIFont fontWithName:@"CentraleSansRndLight" size:16];
    
    spinner.mode = MBProgressHUDModeIndeterminate;
    
    spinner.tag=987456321;
    
    spinner.animationType = MBProgressHUDAnimationZoom;
    
    spinner.frame = [[UIScreen mainScreen] bounds];
    
    spinner.dimBackground = YES;
    
    spinner.labelText = text;
    
    spinner.delegate = self;
    
    [spinner show:YES];
    
    [self.window addSubview:spinner];
}


- (void)hideSpinnerAfterDelayWithText:(NSString *)text andImageName:(NSString *)imageName
{
    spinner.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    
    spinner.mode = MBProgressHUDModeCustomView;
    
    spinner.labelText = text;
    
    [spinner hide:YES afterDelay:1];
}




@end
