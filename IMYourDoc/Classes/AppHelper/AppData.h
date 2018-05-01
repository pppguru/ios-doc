//
//  AppData.h
//  IMYourDoc
//
//  Created by Ronald Wang on 11/13/16.
//  Copyright © 2016 IMYourDoc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AppData : NSObject

+ (AppData *)appData;

/* -------------- User Information ----------------- */

- (NSString *)username;
- (void)setUsername:(NSString *)username;

- (NSString *)firstname;
- (void)setFirstname:(NSString *)firstname;

- (NSString *)lastname;
- (void)setLastname:(NSString *)lastname;

- (NSString *)userAccessToken;
- (void)setUserAccessToken:(NSString*)userAccessToken;

- (NSString*)XMPPmyJID;
- (void)setXMPPmyJID:(NSString*)strJID;

/* -------------- XMPP Server Connection ----------------- */

+ (void)connectXMPPServer;

/* -------------- User PIN ----------------- */

- (void)setUserPIN:(NSString *)userPIN;
- (NSString *)userPIN;

/* -------------- User Login Credentials ----------------- */

- (NSString*)getMyJID;
- (NSString*)XMPPmyJIDPassword;
- (void)setXMPPmyJIDPassword:(NSString*)strPW;

/* -------------- User Info Management ----------------- */

+ (void)fetchUserInfoFromLoginResponse:(NSDictionary*)response;

/* -------------- Local Notification ----------------- */

- (void)showLocalNotification:(NSString*)message withBadgeNumber:(int)badgeNum;

+ (void)sendLocalNotificationForNotInternetConnection;
+ (void)sendLocalNotificationForNotConnected;
+ (void)sendLocalNotificationForConnecting;
+ (void)sendLocalNotificationForSecurelyConnected;

/* -------------- Auth Token Management --------------- */

- (void)addAuthTokenIntoHeaderOfAPIManager:(NSString*)authToken withHeaderName:(NSString*)headerName;

/* -------------- Fetch the information from server ----------------- */

- (BOOL)isAllInboxMessagesFetched;

- (BOOL)isAllLoginInfoFetched;

- (void)fetchInformationAfterLogin:(UINavigationController*)navController;

- (void)fetchMessageThreadsWithConversationIDName:(NSString*)jConversationID
                                andFirstMessageID:(NSString*)strFirstMessageID
                                      isOneORRoom:(BOOL)isOneORRoom
                                          success:(void (^)(BOOL))success
                                          failure:(void (^)(NSError *error))failure;

/* -------------- App Version Management ----------------- */
- (BOOL)isNewAppVersion;
- (void)saveCurrentAppVersion;
- (NSString*)appVersion;
- (void)setAppVersion:(NSString*)strAppVersion;

/* -------------- Clear Login Session ----------------- */

- (void)clearPreviousLoginSession;


/* -------------- API Reference ----------------- */

- (NSString *)getBaseUrl;
- (BOOL)wifiAvaiable;

/* -------------- Alert ----------------- */
+ (void)showAlertWithTitle:(NSString*)strTitle andMessage:(NSString*)strMsg inVC:(UIViewController*)containerVC;

/* -------------- TextField Validation ----------------- */

+ (BOOL)isFieldEmpty:(UITextField *)field;
+ (BOOL)isFieldEmail:(UITextField *)field;

/* -------------- UI navigation ----------------- */
+ (void)logOut;

+ (void)loginWithResponseJSON:(NSDictionary*)strResponse withNavController:(UINavigationController*)navCurrent;
+ (void)goToAccountConfig:(UINavigationController*)navController;
+ (void)loginActionWithRequiredConfig:(NSInteger)requiredConfigFlag andRegisterDevice:(NSInteger)registerDeviceFlag andNavVC:(UINavigationController*)navController;

@end
