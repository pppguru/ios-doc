#import <Foundation/Foundation.h>
#import "XMPPMessage.h"


@interface XMPPMessage (XEP_0085)

- (NSString *)chatState;

- (BOOL)hasChatState;

- (BOOL)hasActiveChatState;
- (BOOL)hasComposingChatState;
- (BOOL)hasPausedChatState;
- (BOOL)hasInactiveChatState;
- (BOOL)hasGoneChatState;

- (BOOL)hasDeliveredChatState;
- (BOOL)hasDisPlayedChatState;


- (void)addActiveChatState;
- (void)addComposingChatState;
- (void)addPausedChatState;
- (void)addInactiveChatState;
- (void)addGoneChatState;

@end
