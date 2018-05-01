//
//  XMLParser.h
//  XMLParserTutorial
//
//  Created by Kent Franks on 5/6/11.
//  Copyright 2011 TheAppCodeBlog. All rights reserved.
//

    // imYourDocParserState = 1 KPhysicianFullProfileForPatientView .. From New Conversation

    // imYourDocParserState = 2 KPatientFullProfileForPhysicianView .. Manage Patient List in Physician View when select roster

    // imYourDocParserState = 5  FOR search Physicin...

    // imYourDocParserState = 6 FOR Getting Block Devices..




#import <Foundation/Foundation.h>

@protocol XmlParserProtocolDelegate;

@interface XMLParser : NSObject <NSXMLParserDelegate>
{
    id<XmlParserProtocolDelegate> _delegate;
	NSMutableString	*currentNodeContent;
	NSMutableArray	*parseData;
	NSXMLParser		*parser;
    NSMutableDictionary *resourceDict;
    NSInteger parseForIMYourDoc;
}

@property (nonatomic, retain) NSMutableArray	*parseData;
@property (nonatomic,retain) NSMutableDictionary *resourceDict;
@property (retain,nonatomic) id<XmlParserProtocolDelegate> delegate;
@property (assign,nonatomic) NSInteger imYourDocParserState;



-(id)loadXMLByURL:(NSString *)urlString;
//-(BOOL) loadXMLForRoom:(NSString *)xmlString;
@end

@protocol XmlParserProtocolDelegate <NSObject>
//-(void)processCompletedWithArray:(NSMutableArray *)parsredArray;
-(void)processCompleted:(NSDictionary *)object;
-(void)processHasErrors;

@end
