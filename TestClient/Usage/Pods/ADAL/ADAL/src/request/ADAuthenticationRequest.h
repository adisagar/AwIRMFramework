// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>
#import "ADAuthenticationContext.h"

@class ADUserIdentifier;
@class ADTokenCacheAccessor;

#define AD_REQUEST_CHECK_ARGUMENT(_arg) { \
    if (!_arg || ([_arg isKindOfClass:[NSString class]] && [(NSString*)_arg isEqualToString:@""])) { \
        NSString* _details = @#_arg " must not be nil!"; \
        completionBlock([ADAuthenticationResult resultFromParameterError:_details]); \
        return; \
    } \
}

#define AD_REQUEST_CHECK_PROPERTY(_property) { \
    if (!_property || ([_property isKindOfClass:[NSString class]] && [(NSString*)_property isEqualToString:@""])) { \
        NSString* _details = @#_property " must not be nil!";\
        completionBlock([ADAuthenticationResult resultFromParameterError:_details]); \
        return; \
    } \
}

@interface ADAuthenticationRequest : NSObject
{
@protected
    ADAuthenticationContext* _context;
    NSString* _clientId;
    NSString* _redirectUri;
    ADTokenCacheAccessor* _tokenCache;
    
    ADUserIdentifier* _identifier;
    
    ADPromptBehavior _promptBehavior;
    
    NSString* _resource;
    
    NSString* _scope;
    NSString* _queryParams;
    
    NSString* _refreshTokenCredential;
    
    NSString* _samlAssertion;
    ADAssertionType _assertionType;
    
    BOOL _silent;
    BOOL _allowSilent;
    
    NSUUID* _correlationId;
    NSString* _logComponent;
    
    BOOL _requestStarted;
    BOOL _attemptedFRT;
    
    ADTokenCacheItem* _mrrtItem;
    
    ADAuthenticationError* _underlyingError;
}

@property (retain) NSString* logComponent;

// These constructors exists *solely* to be used when trying to use some of the caching logic.
// You can't actually send requests with it. They will fail.
+ (ADAuthenticationRequest *)requestWithAuthority:(NSString *)authority;
+ (ADAuthenticationRequest *)requestWithContext:(ADAuthenticationContext *)context;

// The default constructor. All of the parameters are mandatory
+ (ADAuthenticationRequest*)requestWithContext:(ADAuthenticationContext*)context
                                   redirectUri:(NSString*)redirectUri
                                      clientId:(NSString*)clientId
                                      resource:(NSString*)resource
                                         error:(ADAuthenticationError* __autoreleasing *)error;

// This message is sent before any stage of processing is done, it marks all the fields as un-editable and grabs the
// correlation ID from the logger
- (void)ensureRequest;
// This exclusion lock should be obtained before launching webview/broker for interaction
- (BOOL)takeUserInterationLock;
- (BOOL)releaseUserInterationLock;

// These can only be set before the request gets sent out.
- (void)setScope:(NSString*)scope;
- (void)setExtraQueryParameters:(NSString*)queryParams;
- (void)setUserIdentifier:(ADUserIdentifier*)identifier;
- (void)setUserId:(NSString*)userId;
- (void)setPromptBehavior:(ADPromptBehavior)promptBehavior;
- (void)setSilent:(BOOL)silent;
- (void)setCorrelationId:(NSUUID*)correlationId;
- (NSUUID*)correlationId;
#if AD_BROKER
- (NSString*)redirectUri;
- (void)setRedirectUri:(NSString*)redirectUri;
- (void)setAllowSilentRequests:(BOOL)allowSilent;
- (void)setRefreshTokenCredential:(NSString*)refreshTokenCredential;
#endif
- (void)setSamlAssertion:(NSString*)samlAssertion;
- (void)setAssertionType:(ADAssertionType)assertionType;

@end

#import "ADAuthenticationRequest+AcquireAssertion.h"
#import "ADAuthenticationRequest+AcquireToken.h"
#import "ADAuthenticationRequest+Broker.h"
#import "ADAuthenticationRequest+WebRequest.h"
