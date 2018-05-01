

#import "AppDelegate.h"

@interface AppDelegate (ClassMethods)

-(void)writeLogInFileWithClassFunctionLine:(NSString*)pretyFunction  operation:(NSString*)opration Content:(NSString*)content parameter:(NSString*)parameters;
-(NSString *)dataFilePath ;
void uncaughtExceptionHandler(NSException *exception) ;


@end
