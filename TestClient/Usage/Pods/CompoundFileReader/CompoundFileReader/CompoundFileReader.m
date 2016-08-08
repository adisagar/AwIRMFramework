/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  CompoundFileReader.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/21/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "CompoundFileReader.h"
#import "Header.h"
#import "StreamHandle.h"
#import "StreamReader.h"
#import "Sector.h"
#import "DirectoryEntry.h"
#import "CFileReaderError.h"
#import "PropertyTag.h"
#import "Message.h"
#import "Stream.h"
#import "Storage.h"
#import "StorageStreamParser.h"

@interface CompoundFileReader ()

@property (nonatomic, strong) Message *message;

@end

@implementation CompoundFileReader

#pragma mark - Public Methods

- (void)dealloc
{
    _message = nil;
    [[StorageStreamParser sharedInstance] closeFile];
}

- (id)initWithFilePath:(NSString *)filePath
{
    if (filePath && (self = [super init])) {
        [[StorageStreamParser sharedInstance] setFilePath:filePath];
        return self;
    }
    return nil;
}

- (BOOL)readFile:(NSError *__autoreleasing*)error
{
    if ([[StorageStreamParser sharedInstance] readFile:error]) {
        _message = [[Message alloc] initWithRootStorage:[StorageStreamParser sharedInstance].rootStorage];
        
        return YES;
    }
    return NO;
}

- (NSString *)htmlToLoadData
{
    NSMutableString *messageHTMLString = [NSMutableString string];
    
    [messageHTMLString appendFormat:@"<table style=\"font-family:Times New Roman; font-size:15px;\">"];
    
    //From
    if (self.message.from.length > 0) {
        [messageHTMLString appendString:[self encodedLabel:@"From" andValue:self.message.from]];
    }
    
    //Sent On
    if (self.message.sentDateTime) {
        NSString *sentDateTime = [NSDateFormatter localizedStringFromDate:self.message.sentDateTime
                                                                dateStyle:NSDateFormatterFullStyle
                                                                timeStyle:NSDateFormatterMediumStyle];
        [messageHTMLString appendString:[self encodedLabel:@"Sent On" andValue:sentDateTime]];
    }
    
    //To
    if (self.message.to.length > 0) {
        [messageHTMLString appendString:[self encodedLabel:@"To" andValue:self.message.to]];
    }
    
    //CC
    if (self.message.cc.length > 0) {
        [messageHTMLString appendString:[self encodedLabel:@"CC" andValue:self.message.cc]];
    }
    
    //BCC
    if (self.message.bcc.length > 0) {
        [messageHTMLString appendString:[self encodedLabel:@"BCC" andValue:self.message.bcc]];
    }
    
    //Subject
    if (self.message.subject.length > 0) {
        [messageHTMLString appendString:[self encodedLabel:@"Subject" andValue:self.message.subject]];
    }
    
    if (self.message.type == MessageTypeAppointment) {
        
        //Meeting Location...
        if (self.message.meetingLocation) {
            [messageHTMLString appendString:[self encodedLabel:@"Meeting Location" andValue:self.message.meetingLocation]];
        }
        
        //Meeting Start Time
        if (self.message.meetingStartDateTime) {
            NSString *meetingStartTimeStr = [NSDateFormatter localizedStringFromDate:self.message.meetingStartDateTime
                                                                           dateStyle:NSDateFormatterFullStyle
                                                                           timeStyle:NSDateFormatterMediumStyle];
            [messageHTMLString appendString:[self encodedLabel:@"Meeting Start Time" andValue:meetingStartTimeStr]];
        }
        
        //Meeting End Time
        if (self.message.meetingEndDateTime) {
            NSString *meetingEndTimeStr = [NSDateFormatter localizedStringFromDate:self.message.meetingEndDateTime
                                                                         dateStyle:NSDateFormatterFullStyle
                                                                         timeStyle:NSDateFormatterMediumStyle];
            [messageHTMLString appendString:[self encodedLabel:@"Meeting End Time" andValue:meetingEndTimeStr]];
        }
    }
    
    [messageHTMLString appendFormat:@"</table><br/>"];
    
    messageHTMLString = [self injectHeader:messageHTMLString withBody:self.message.htmlBody];
    
    messageHTMLString = (NSMutableString *)[messageHTMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return messageHTMLString;
}

- (NSString *)encodedLabel:(NSString *)label andValue:(NSString *)value
{
    return [NSString stringWithFormat:@"<tr style=\"font-size:15px; vertical-align: top;\"><td style=\"font-weight:bold; white-space:nowrap;\">%@:</td><td>%@</td></tr>", label, value];
}

- (NSMutableString *)injectHeader:(NSString *)header withBody:(NSString *)body
{
    __block NSMutableString *temp = [[body uppercaseString] mutableCopy];
    
    NSInteger beginIndex = [temp rangeOfString:@"<BODY"].location;
    
    temp = nil, temp = [body mutableCopy];
    
    if (beginIndex >= 0) {
        beginIndex = [temp rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(beginIndex, temp.length - beginIndex)].location;
        [temp insertString:header atIndex:(beginIndex + 1)];
    } else {
        temp = [[header stringByAppendingString:body] mutableCopy];
    }
    
    return temp;
}

- (BOOL)hasAttachments
{
    return self.message.hasAttachments;
}

- (NSArray *)attachments
{
    return self.message.attachments;
}

@end