/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  PropertyTag.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/24/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CFileReaderPropertyTagSenderName;

extern NSString *const CFileReaderPropertyTagDisplayTo;
extern NSString *const CFileReaderPropertyTagDisplayCC;
extern NSString *const CFileReaderPropertyTagDisplayBCC;

extern NSString *const CFileReaderPropertyTagSubject;

extern NSString *const CFileReaderPropertyTagMessageType;
extern NSString *const CFileReaderPropertyTagMessageBody;
extern NSString *const CFileReaderPropertyTagMessageBodyHTML;
extern NSString *const CFileReaderPropertyTagMessageBodyRTF;

//Message SentTime
extern NSString *const CFileReaderPropertyTagProviderSubmitTime;
extern NSString *const CFileReaderPropertyTagClientSubmitTime;

//Mapped Properties
extern NSString *const CFileReaderPropertyTagMeetingLocation;
extern NSString *const CFileReaderPropertyTagMeetingStartTime;
extern NSString *const CFileReaderPropertyTagMeetingEndTime;

extern NSString *const CFileReaderPropertyTagAttachmentFileName;
extern NSString *const CFileReaderPropertyTagAttachmentMIMETYPE;
extern NSString *const CFileReaderPropertyTagAttachmentData;
extern NSString *const CFileReaderPropertyTagAttachmentContentID;

extern NSString *const CFileReaderPropertyTagAttachment;

extern NSString *const CFileReaderPropertyTagPropertyStream;
extern NSString *const CFileReaderPropertyTagNamedProperty;
extern NSString *const CFileReaderPropertyTagSubStgVersion;
extern NSString *const CFileReaderPropertyTagEntryStream;
extern NSString *const CFileReaderPropertyTagStringStream;