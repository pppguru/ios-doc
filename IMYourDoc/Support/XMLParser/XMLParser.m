   //
    //  XMLParser.m
    //  XMLParserTutorial
    //
    //  Created by Kent Franks on 5/6/11.
    //  Copyright 2011 TheAppCodeBlog. All rights reserved.
    //

#import "XMLParser.h"

@implementation XMLParser
@synthesize delegate ,parseData;
@synthesize imYourDocParserState;
@synthesize resourceDict;

-(id) loadXMLByURL:(NSString *)xmlString
{
	parseData			= [[NSMutableArray alloc] init];
    NSData	*data   = [[NSData alloc] initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    parser			= [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	[parser parse];
	return self;
}

//-(BOOL) loadXMLForRoom:(NSString *)xmlString
//{
//	parseData			= [[NSMutableArray alloc] init];
//    NSData	*data   = [[NSData alloc] initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
//    parser			= [[NSXMLParser alloc] initWithData:data];
//	parser.delegate = self;
//	[parser parse];
//	return [parser parse];
//}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementname isEqualToString:@"SessionDetails"] ) 
	{
        resourceDict = [[NSMutableDictionary alloc] init];
	}
    else if ( imYourDocParserState == 3 && [elementname isEqualToString:@"PhysicianProfile"])
    {
        resourceDict = [[NSMutableDictionary alloc] init];
    }
    else if (imYourDocParserState == 4 && [elementname isEqualToString:@"PatientProfile"])
    {
        resourceDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementname isEqualToString:@"Physician"])
    {
        resourceDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementname isEqualToString:@"DeviceRegistered"])
    {
        resourceDict = [[NSMutableDictionary alloc] init];
    } 
}


    //<PhysicianDetails><Physician><FirstName>test1</FirstName><LastName>test1</LastName><UserName>test1</UserName><PracticeType>Allergy  Immunology</PracticeType><PIC>DOC00108</PIC><PhoneNo>11</PhoneNo><Email>amit.sharma@advantal.net</Email></Physician>

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if (currentNodeContent == nil) {
			//NSLog(@"Koi Valuew Nahi hai Than :- ");
        NSString *tempString = @"";
        currentNodeContent = [NSMutableString stringWithString:tempString];
			//NSLog(@":%@:",currentNodeContent);
        
    }       
        if ([elementname isEqualToString:@"StaffUserName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"StaffUserName"];
        }
        else if ([elementname isEqualToString:@"StaffPic"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"StaffPic"];
        } 
        else if ([elementname isEqualToString:@"StaffFname"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"StaffFname"];
        } 
        else if ([elementname isEqualToString:@"StaffLname"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"StaffLname"];
        } 
        else if ([elementname isEqualToString:@"StaffEmail"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"StaffEmail"];
        } 
        else if ([elementname isEqualToString:@"StaffPhone"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"StaffPhone"];
        }
        else if ([elementname isEqualToString:@"DeviceStatus"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"DeviceStatus"];
        }
        else if ([elementname isEqualToString:@"DeviceId"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"DeviceId"];
        }
        else if ([elementname isEqualToString:@"DeviceName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"DeviceName"];
        }
        else if ([elementname isEqualToString:@"FirstName"])
        {
            
            [self.resourceDict setObject:currentNodeContent forKey:@"FirstName"];
        }
        else if ([elementname isEqualToString:@"LastName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"LastName"];
        }
        else if ([elementname isEqualToString:@"PIC"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PIC"];
        }
        else if ([elementname isEqualToString:@"PhoneNo"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhoneNo"];
        }
        else if ([elementname isEqualToString:@"Email"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"mail"];
        }
        
        else if ([elementname isEqualToString:@"PatientUserName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PatientUserName"];
        }
        else if ([elementname isEqualToString:@"UserName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"UserName"];
        }
        else if ([elementname isEqualToString:@"Fname"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Fname"];
        }
        else if ([elementname isEqualToString:@"Lname"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Lname"];
        }
        else if ([elementname isEqualToString:@"PracticeName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PracticeName"];
        }
        else if ([elementname isEqualToString:@"PracticeType"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PracticeType"];
        }
        else if ([elementname isEqualToString:@"Address"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Address"];
        }
        else if ([elementname isEqualToString:@"City"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"City"];
        }
        else if ([elementname isEqualToString:@"State"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"State"];
        }
        else if ([elementname isEqualToString:@"Zip"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Zip"];
        }
        
        else if ([elementname isEqualToString:@"Phone"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Phone"];
        }
        else if ([elementname isEqualToString:@"Assistant"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Assistant"];
        }
        else if ([elementname isEqualToString:@"AssistantEmail"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"AssistantEmail"];
        }
        else if ([elementname isEqualToString:@"PhysicianProfile"] && imYourDocParserState != 3)
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianProfile"];
        }
        else if ([elementname isEqualToString:@"PhysicianUserName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianUserName"];
        }
        else if ([elementname isEqualToString:@"PhysicianPic"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianPic"];
        }
        else if ([elementname isEqualToString:@"PhysicianFname"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianFname"];
            
        }
        else if ([elementname isEqualToString:@"PhysicianLname"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianLname"];
            
        }
        else if ([elementname isEqualToString:@"PhysicianEmail"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianEmail"];
            
        }
        else if ([elementname isEqualToString:@"PhysicianPracticeName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianPracticeName"];
            
        }
        
        else if ([elementname isEqualToString:@"PhysicianPracticeType"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianPracticeType"];
            
        }
        
        else if ([elementname isEqualToString:@"PhysicianAssistant"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianAssistant"];
            
        }
        
        else if ([elementname isEqualToString:@"PhysicianAssistantEmail"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PhysicianAssistantEmail"];
            
        }
        
        else if ([elementname isEqualToString:@"AvailableHoursFrom"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"AvailableHoursFrom"];
            
        }
        
        else if ([elementname isEqualToString:@"AvailableHoursTo"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"AvailableHoursTo"];   
            
        }
        
        else if ([elementname isEqualToString:@"TotalPurches"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"TotalPurches"];
            
        }
        
        else if ([elementname isEqualToString:@"RemainingSession"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"RemainingSession"];
            
        }
        
        else if ([elementname isEqualToString:@"PurchaseDate"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PurchaseDate"];
            
        }
        
        else if ([elementname isEqualToString:@"PurchaseTime"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PurchaseTime"];
            
        }
        else if ([elementname isEqualToString:@"SessionExpDate"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"SessionExpDate"];
            
        }
        else if ([elementname isEqualToString:@"SessionStatus"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"SessionStatus"];
            
        }
        else if ([elementname isEqualToString:@"LoginStatus"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"LoginStatus"];
            
        }
        else if ([elementname isEqualToString:@"PatientEmail"])
        {
            
            [self.resourceDict setObject:currentNodeContent forKey:@"PatientEmail"];
            
        }
        else if ([elementname isEqualToString:@"PatientFullName"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"PatientFullName"];
        }
        
        else if ([elementname isEqualToString:@"Assistant"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Assistant"];
                //self.resourceProfileList.physicianAssistantEmail = currentNodeContent;
            
        }
        else if ([elementname isEqualToString:@"AssistantEmail"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"AssistantEmail"];
                //self.resourceProfileList.physicianAssistantEmail = currentNodeContent;
            
        }
		else if ([elementname isEqualToString:@"Phone_no"])
        {
            [self.resourceDict setObject:currentNodeContent forKey:@"Phone_no"];
                //self.resourceProfileList.physicianAssistantEmail = currentNodeContent;
            
        }
        
        else if ([elementname isEqualToString:@"SessionDetails"])
        {
            [parseData addObject:self.resourceDict];
            [currentNodeContent release];
            currentNodeContent = nil;
        }
        else if ( imYourDocParserState == 3 && [elementname isEqualToString:@"PhysicianProfile"])
        {
            [parseData addObject:self.resourceDict];
            [currentNodeContent release];
            currentNodeContent = nil;
        }
        else if (imYourDocParserState == 4 && [elementname isEqualToString:@"PatientProfile"])
        {
            [parseData addObject:self.resourceDict];
            [currentNodeContent release];
            currentNodeContent = nil;
        }
        else if ([elementname isEqualToString:@"Physician"])
        {
            [parseData addObject:self.resourceDict];
            [currentNodeContent release];
            currentNodeContent = nil;
        }
        else if ([elementname isEqualToString:@"DeviceRegistered"])
        {
            [parseData addObject:self.resourceDict];
            [currentNodeContent release];
            currentNodeContent = nil;
        }
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	currentNodeContent = (NSMutableString *) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSDictionary *dict;
    
    if (imYourDocParserState ==5)
    {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:parseData,@"ParseData", nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:parseData forKey:@"searchPhysicianData"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [delegate processCompleted:dict];
    }
    
    else if (imYourDocParserState == 6)
    {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:parseData,@"BlockDevices", nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:parseData forKey:@"BlockDevices"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [delegate processCompleted:dict];
    }
    
//    else if (imYourDocParserState == 7)
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:parseData forKey:@"RoomArray"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        [delegate processCompletedWithArray:parseData];
//    }
    else
    {
        dict = [NSDictionary dictionaryWithDictionary:[parseData objectAtIndex:0]];
        [delegate processCompleted:dict];
    }     
}



//- (void) dealloc
//{
//	[parser release];
//	[super dealloc];
//}

@end
