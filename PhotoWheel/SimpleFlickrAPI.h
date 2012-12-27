//
//  SimpleFlickrAPI.h
//  PhotoWheel
//
//  Created by Kirby Turner on 12/16/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleFlickrAPI : NSObject

// Returns a set of photos matching the search string.
- (NSArray *)photosWithSearchString:(NSString *)string;

// Returns the Flickr NSID for the given user name.
- (NSString *)userIdForUsername:(NSString *)username;

// Returns a Flickr photo set for the user. userId is the Flickr NSID
// of the user.
- (NSArray *)photoSetListWithUserId:(NSString *)userId;

// Returns the photos for a Flickr photo set.
- (NSArray *)photosWithPhotoSetId:(NSString *)photoSetId;

@end
