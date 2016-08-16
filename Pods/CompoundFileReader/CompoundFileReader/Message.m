/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Message.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/18/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Message.h"
#import "Attachment.h"
#import "Mapper.h"
#import "MappedObject.h"
#import "MapiPropertyParser.h"
#import "RTFDecompressor.h"
#import "DomDocument.h"

@interface Message ()

@property (nonatomic, strong) Storage *rootStorage;
@property (nonatomic, strong) MapiPropertyParser *mapiPropertyParser;
@property (nonatomic, copy) NSString *rtfBody;

@end

@implementation Message

- (void)dealloc
{
    _rootStorage = nil;
    _from = nil;
    _to = nil;
    _cc = nil;
    _bcc = nil;
    _subject = nil;
    _sentDateTime = nil;
    _htmlBody = nil;
    _meetingLocation = nil;
    _attachments = nil;
    _mapiPropertyParser = nil;
}

- (id)initWithRootStorage:(Storage *)rootStorage
{
    if (self = [super init]) {
        _rootStorage = rootStorage;
        _type = MessageTypeUnknown;
        _mapiPropertyParser = [[MapiPropertyParser alloc] initWithStorage:rootStorage];
    }
    return self;
}

- (MessageType)type
{
    if (_type == MessageTypeUnknown) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagMessageType] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([propertyValue isEqualToString:@"IPM.Note"]) {
            _type = MessageTypeNote;
        } else if ([propertyValue isEqualToString:@"IPM.Schedule.Meeting.Request"] || [propertyValue isEqualToString:@"IPM.Appointment"]) {
            _type = MessageTypeAppointment;
        } else if ([propertyValue isEqualToString:@"IPM.Activity"]) {
            _type = MessageTypeActivity;
        } else if ([propertyValue isEqualToString:@"IPM.Contact"]) {
            _type = MessageTypeContact;
        } else if ([propertyValue isEqualToString:@"IPM.Post"]) {
            _type = MessageTypePost;
        } else if ([propertyValue isEqualToString:@"IPM.Task"]) {
            _type = MessageTypeTask;
        }
    }
    return _type;
}

- (NSString *)from
{
    if (!_from) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagSenderName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _from = propertyValue;
    }
    return _from;
}

- (NSString *)to
{
    if (!_to) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagDisplayTo] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _to = propertyValue;
    }
    return _to;
}

- (NSString *)cc
{
    if (!_cc) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagDisplayCC] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _cc = propertyValue;
    }
    return _cc;
}

- (NSString *)bcc
{
    if (!_bcc) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagDisplayBCC] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _bcc = propertyValue;
    }
    return _bcc;
}

- (NSString *)subject
{
    if (!_subject) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagSubject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _subject = propertyValue;
    }
    return _subject;
}

- (NSDate *)sentDateTime
{
    if (!_sentDateTime) {
        NSDate *propertyValue = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagProviderSubmitTime];
        if (!propertyValue) {
            propertyValue = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagClientSubmitTime];
        }
        _sentDateTime = propertyValue;
    }
    return _sentDateTime;
}

- (NSString *)htmlBody
{
    if (!_htmlBody) {
        id propertyValue = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagMessageBodyHTML];
        if ([propertyValue isKindOfClass:[NSString class]]) {
            _htmlBody = [propertyValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        if (!_htmlBody) {
            NSString *bodyRTF = self.rtfBody;
            
            if (bodyRTF) {
                DomDocument *rtfDocument = [[DomDocument alloc] init];
                [rtfDocument loadRTFText:bodyRTF];
                // Obtain html content if possible
                if (rtfDocument.htmlContent) {
                    _htmlBody = [self embedInlineAttachmentsIntoHtml:rtfDocument.htmlContent];
                }
                rtfDocument = nil;
            }
            if (!_htmlBody) {
                _htmlBody = @"<html><head></head><body></body></html>";
            }
        }
    }
    return _htmlBody;
}

- (NSString *)rtfBody
{
    NSData *rtfData = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagMessageBodyRTF];
    if (!rtfData || rtfData.length == 0) {
        return nil;
    }
    RTFDecompressor *rtfDecompressor = [[RTFDecompressor alloc] init];
    rtfData = [rtfDecompressor decompressRTFData:rtfData];
    NSString *rtfBody = [[NSString alloc] initWithData:rtfData encoding:NSASCIIStringEncoding];
    rtfDecompressor = nil;
    return rtfBody;
}

- (NSString *)meetingLocation
{
    if (!_meetingLocation) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagMeetingLocation] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _meetingLocation = propertyValue;
    }
    return _meetingLocation;
}

- (BOOL)hasAttachments
{
    _hasAttachments = NO;
    if (self.attachments.count > 0) {
        _hasAttachments = YES;
    }
    return _hasAttachments;
}

- (NSMutableArray *)attachments
{
    if (!_attachments) {
        NSPredicate *attachPredicate = [NSPredicate predicateWithFormat:@"storageName LIKE %@", [CFileReaderPropertyTagAttachment stringByAppendingString:@"*"]];
        NSArray *filteredArray = [[[self.rootStorage storages] allObjects] filteredArrayUsingPredicate:attachPredicate];
        if (filteredArray.count > 0) {
            NSMutableArray *tempAttachments = [NSMutableArray array];
            for (Storage *attachmentStorage in filteredArray) {
                [tempAttachments addObject:[[Attachment alloc] initWithStorage:attachmentStorage]];
            }
            _attachments = tempAttachments;
        }
    }
    return _attachments;
}

- (NSDate *)meetingStartDateTime
{
    if (self.type == MessageTypeAppointment) {
        if (!_meetingStartDateTime) {
            NSDate *propertyValue = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagMeetingStartTime];
            _meetingStartDateTime = propertyValue;
        }
    } else {
        _meetingStartDateTime = nil;
    }
    return _meetingStartDateTime;
}

- (NSDate *)meetingEndDateTime
{
    if (self.type == MessageTypeAppointment) {
        if (!_meetingEndDateTime) {
            NSDate *propertyValue = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagMeetingEndTime];
            _meetingEndDateTime = propertyValue;
        }
    } else {
        _meetingEndDateTime = nil;
    }
    return _meetingEndDateTime;
}

- (NSString *)embedInlineAttachmentsIntoHtml:(NSString *)htmlString
{
    NSString *resultStr = htmlString;
    NSString *imgStartTag = @"<img";
    NSString *srcTag = @"src=\"cid:";
    NSInteger foundIndex = 0;
    foundIndex = [htmlString rangeOfString:imgStartTag options:NSCaseInsensitiveSearch range:NSMakeRange(foundIndex, htmlString.length - foundIndex)].location;
    
    if (self.hasAttachments) {
        
        while (foundIndex != NSNotFound) {
            
            NSString *contentID = [htmlString substringFromIndex:foundIndex];
            NSInteger contentIDLocation = [contentID rangeOfString:srcTag].location;
            if (contentIDLocation != NSNotFound) {
                contentID = [contentID substringFromIndex:([contentID rangeOfString:srcTag].location + srcTag.length)];
                contentID = [contentID substringToIndex:[contentID rangeOfString:[NSString stringWithFormat:@"\""]].location];
                
                NSArray *array = [self.attachments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contentID == %@", contentID]];
                
                if (array.count > 0) {
                    
                    Attachment *attachment = [array objectAtIndex:0];
                    
                    NSString *base64EncodedData = nil;
                    
                    if ([attachment.fileData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                        base64EncodedData = [attachment.fileData base64EncodedStringWithOptions:0];
                    } else {
                        base64EncodedData = [attachment.fileData base64EncodedStringWithOptions:0];
                    }
                    
                    NSString *srcTagReplace = [srcTag stringByAppendingString:contentID];
                    
                    NSString *srcTagData = [NSString stringWithFormat:@"src=\"data:%@;base64,%@", attachment.fileMIMEType, base64EncodedData];
                    
                    resultStr = [resultStr stringByReplacingOccurrencesOfString:srcTagReplace withString:srcTagData];
                    
                    [self.attachments removeObject:attachment];
                }
            }
            
            foundIndex += 1;
            
            foundIndex = [htmlString rangeOfString:imgStartTag options:NSCaseInsensitiveSearch range:NSMakeRange(foundIndex, htmlString.length - foundIndex)].location;
        }
    }
    return resultStr;
}

@end
