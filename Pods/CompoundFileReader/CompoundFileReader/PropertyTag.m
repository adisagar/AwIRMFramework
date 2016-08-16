/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  PropertyTag.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/24/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "PropertyTag.h"

NSString *const CFileReaderPropertyTagSenderName = @"0C1A";

NSString *const CFileReaderPropertyTagDisplayTo = @"0E04";
NSString *const CFileReaderPropertyTagDisplayCC = @"0E03";
NSString *const CFileReaderPropertyTagDisplayBCC = @"0E02";

NSString *const CFileReaderPropertyTagSubject = @"0037";

NSString *const CFileReaderPropertyTagMessageType = @"001A";
NSString *const CFileReaderPropertyTagMessageBody = @"1000";
NSString *const CFileReaderPropertyTagMessageBodyHTML = @"1013";
NSString *const CFileReaderPropertyTagMessageBodyRTF = @"1009";

//Message SentTime
NSString *const CFileReaderPropertyTagProviderSubmitTime = @"0048";
NSString *const CFileReaderPropertyTagClientSubmitTime = @"0039";

//Mapped Properties
NSString *const CFileReaderPropertyTagMeetingLocation = @"8208";
NSString *const CFileReaderPropertyTagMeetingStartTime = @"820D";
NSString *const CFileReaderPropertyTagMeetingEndTime = @"820E";

NSString *const CFileReaderPropertyTagAttachmentFileName = @"3707";
NSString *const CFileReaderPropertyTagAttachmentMIMETYPE = @"370E";
NSString *const CFileReaderPropertyTagAttachmentData = @"3701";
NSString *const CFileReaderPropertyTagAttachmentContentID = @"3712";

NSString *const CFileReaderPropertyTagAttachment = @"__attach_version1.0_#";

NSString *const CFileReaderPropertyTagPropertyStream = @"__properties_version1.0";
NSString *const CFileReaderPropertyTagNamedProperty = @"__nameid_version1.0";
NSString *const CFileReaderPropertyTagSubStgVersion = @"__substg1.0";
NSString *const CFileReaderPropertyTagEntryStream = @"__substg1.0_00030102";
NSString *const CFileReaderPropertyTagStringStream = @"__substg1.0_00040102";