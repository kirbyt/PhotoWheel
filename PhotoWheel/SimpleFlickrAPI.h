//
//  SimpleFlickrAPI.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleFlickrAPI : NSObject

- (NSString *)userIdForUsername:(NSString *)username;          // Returns the Flickr NSID for the given user name.
- (NSArray *)photoSetListWithUserId:(NSString *)userId;   // userId is the Flickr NSID of the user.
- (NSArray *)photosWithPhotoSetId:(NSString *)photoSetId;
- (NSArray *)photosWithSearchString:(NSString *)string;

@end
