/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Attachment.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/18/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Attachment.h"
#import "PropertyTag.h"
#import "MapiPropertyParser.h"

@interface Attachment ()

@property (nonatomic, strong) Storage *attachmentStorage;
@property (nonatomic, strong) MapiPropertyParser *mapiPropertyParser;

@end

@implementation Attachment

- (void)dealloc
{
    _attachmentStorage = nil;
    _fileData = nil;
    _fileMIMEType = nil;
    _fileName = nil;
    _contentID = nil;
    _mapiPropertyParser = nil;
}

- (id)initWithStorage:(Storage *)storage
{
    if (self = [super init]) {
        _attachmentStorage = storage;
        _mapiPropertyParser = [[MapiPropertyParser alloc] initWithStorage:storage];
    }
    return self;
}

- (NSString *)fileName
{
    if (!_fileName) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagAttachmentFileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _fileName = propertyValue;
    }
    return _fileName;
}

- (NSString *)fileMIMEType
{
    if (!_fileMIMEType) {
        NSString *propertyValue = [[self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagAttachmentMIMETYPE] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _fileMIMEType = propertyValue;
    }
    return _fileMIMEType;
}

- (NSData *)fileData
{
    if (!_fileData) {
        NSData *propertyValue = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagAttachmentData];
        _fileData = propertyValue;
    }
    return _fileData;
}

- (NSString *)contentID
{
    if (!_contentID) {
        NSString *propertyValue = [self.mapiPropertyParser mapipropertyValueOfPropID:CFileReaderPropertyTagAttachmentContentID];
        _contentID = propertyValue;
    }
    return _contentID;
}

@end
