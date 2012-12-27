//
//  SimpleFlickrAPI.m
//  PhotoWheel
//
//  Created by Kirby Turner on 12/16/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "SimpleFlickrAPI.h"
#import <Foundation/NSJSONSerialization.h>

// Changes this value to your own application key. More info
// at http://www.flickr.com/services/api/misc.api_keys.html.
#define flickrAPIKey @"YOUR_FLICKR_APP_KEY"

#define flickrBaseURL @"http://api.flickr.com/services/rest/?format=json&"

#define flickrParamMethod @"method"
#define flickrParamAppKey @"api_key"
#define flickrParamUsername @"username"
#define flickrParamUserid @"user_id"
#define flickrParamPhotoSetId @"photoset_id"
#define flickrParamExtras @"extras"
#define flickrParamText @"text"

#define flickrMethodFindByUsername @"flickr.people.findByUsername"
#define flickrMethodGetPhotoSetList @"flickr.photosets.getList"
#define flickrMethodGetPhotosWithPhotoSetId @"flickr.photosets.getPhotos"
#define flickrMethodSearchPhotos @"flickr.photos.search"


@implementation SimpleFlickrAPI

- (NSArray *)photosWithSearchString:(NSString *)string
{
   NSDictionary *parameters = @{
      flickrParamMethod : flickrMethodSearchPhotos,
      flickrParamAppKey : flickrAPIKey,
      flickrParamText : string,
      flickrParamExtras : @"url_t, url_s, url_m, url_sq",
   };
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photoset = [json objectForKey:@"photos"];
   NSArray *photos = [photoset objectForKey:@"photo"];
   return photos;
}

- (NSString *)userIdForUsername:(NSString *)username
{
   NSDictionary *parameters = @{
      flickrParamMethod : flickrMethodFindByUsername,
      flickrParamAppKey : flickrAPIKey,
      flickrParamUsername : username,
   };
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *userDict = [json objectForKey:@"user"];
   NSString *nsid = [userDict objectForKey:@"nsid"];
   
   return nsid;
}

- (NSArray *)photoSetListWithUserId:(NSString *)userId
{
   NSDictionary *parameters = @{
      flickrParamMethod : flickrMethodGetPhotoSetList,
      flickrParamAppKey : flickrAPIKey,
      flickrParamUserid : userId,
   };
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photosets = [json objectForKey:@"photosets"];
   NSArray *photoSet = [photosets objectForKey:@"photoset"];
   return photoSet;
}

- (NSArray *)photosWithPhotoSetId:(NSString *)photoSetId
{
   NSDictionary *parameters = @{
      flickrParamMethod : flickrMethodGetPhotosWithPhotoSetId,
      flickrParamAppKey : flickrAPIKey,
      flickrParamPhotoSetId : photoSetId,
      flickrParamExtras : @"url_t, url_s, url_m, url_sq",
   };
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photoset = [json objectForKey:@"photoset"];
   NSArray *photos = [photoset objectForKey:@"photo"];
   return photos;
}

#pragma mark - Helper methods

- (NSData *)fetchResponseWithURL:(NSURL *)URL
{
   NSURLRequest *request = [NSURLRequest requestWithURL:URL];
   NSURLResponse *response = nil;
   NSError *error = nil;
   NSData *data = [NSURLConnection sendSynchronousRequest:request
                                        returningResponse:&response
                                                    error:&error];
   if (data == nil) {
      NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__,
            [error localizedDescription]);
   }
   return data;
}

- (NSURL *)buildFlickrURLWithParameters:(NSDictionary *)parameters
{
   NSMutableString *URLString = [[NSMutableString alloc]
                                 initWithString:flickrBaseURL];
   for (id key in parameters) {
      NSString *value = [parameters objectForKey:key];
      [URLString appendFormat:@"%@=%@&", key,
       [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   }
   NSURL *URL = [NSURL URLWithString:URLString];
   return URL;
}

- (NSString *)stringWithData:(NSData *)data
{
   NSString *result = [[NSString alloc] initWithBytes:[data bytes]
                                               length:[data length]
                                             encoding:NSUTF8StringEncoding];
   return result;
}

- (NSString *)stringByRemovingFlickrJavaScript:(NSData *)data
{
   // Flickr returns a JavaScript function containing the JSON data.
   // We need to strip out the JavaScript part before we can parse
   // the JSON data. Ex: jsonFlickrApi(JSON-DATA-HERE).
   
   NSMutableString *string = [[self stringWithData:data] mutableCopy];
   NSRange range = NSMakeRange(0, [@"jsonFlickrApi(" length]);
   [string deleteCharactersInRange:range];
   range = NSMakeRange([string length] - 1, 1);
   [string deleteCharactersInRange:range];
   
   return string;
}

- (id)flickrJSONSWithParameters:(NSDictionary *)parameters
{
   NSURL *URL = [self buildFlickrURLWithParameters:parameters];
   NSData *data = [self fetchResponseWithURL:URL];
   NSString *string = [self stringByRemovingFlickrJavaScript:data];
   NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
   
   NSLog(@"%s: json: %@", __PRETTY_FUNCTION__, string);
   
   NSError *error = nil;
   id json = [NSJSONSerialization
              JSONObjectWithData:jsonData
              options:NSJSONReadingAllowFragments
              error:&error];
   if (json == nil) {
      NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__,
            [error localizedDescription]);
   }
   
   return json;
}

@end
