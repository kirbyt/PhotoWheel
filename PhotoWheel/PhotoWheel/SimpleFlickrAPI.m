//
//  SimpleFlickrAPI.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "SimpleFlickrAPI.h"
#import <Foundation/NSJSONSerialization.h>                                 // 1

// Changes this value to your own application key. More info 
// at http://www.flickr.com/services/api/misc.api_keys.html. 
#define flickrAPIKey @"YOUR_FLICKR_APP_KEY"                                // 2

#define flickrBaseURL @"http://api.flickr.com/services/rest/?format=json&" // 3

#define flickrParamMethod @"method"                                        // 4
#define flickrParamAppKey @"api_key"
#define flickrParamUsername @"username"
#define flickrParamUserid @"user_id"
#define flickrParamPhotoSetId @"photoset_id"
#define flickrParamExtras @"extras"
#define flickrParamText @"text"

#define flickrMethodFindByUsername @"flickr.people.findByUsername"         // 5
#define flickrMethodGetPhotoSetList @"flickr.photosets.getList"
#define flickrMethodGetPhotosWithPhotoSetId @"flickr.photosets.getPhotos"
#define flickrMethodSearchPhotos @"flickr.photos.search"


@interface SimpleFlickrAPI ()                                              // 6
- (id)flickrJSONSWithParameters:(NSDictionary *)parameters;
@end

@implementation SimpleFlickrAPI

- (NSArray *)photosWithSearchString:(NSString *)string                     // 7
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               flickrMethodSearchPhotos, flickrParamMethod, 
                               flickrAPIKey, flickrParamAppKey, 
                               string, flickrParamText, 
                               @"url_t, url_s, url_m, url_sq", flickrParamExtras, 
                               nil];                                       // 8
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];       // 9
   NSDictionary *photoset = [json objectForKey:@"photos"];                 // 10
   NSArray *photos = [photoset objectForKey:@"photo"];                     // 11
   return photos;                                                          // 12
}

- (NSString *)userIdForUsername:(NSString *)username                       // 13
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               flickrMethodFindByUsername, flickrParamMethod, 
                               flickrAPIKey, flickrParamAppKey, 
                               username, flickrParamUsername, 
                               nil];
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *userDict = [json objectForKey:@"user"];
   NSString *nsid = [userDict objectForKey:@"nsid"];
   
   return nsid;
}

- (NSArray *)photoSetListWithUserId:(NSString *)userId                     // 14
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               flickrMethodGetPhotoSetList, flickrParamMethod, 
                               flickrAPIKey, flickrParamAppKey, 
                               userId, flickrParamUserid, 
                               nil];
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photosets = [json objectForKey:@"photosets"];
   NSArray *photoSet = [photosets objectForKey:@"photoset"];
   return photoSet;
}

- (NSArray *)photosWithPhotoSetId:(NSString *)photoSetId                   // 15
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                         flickrMethodGetPhotosWithPhotoSetId, flickrParamMethod, 
                         flickrAPIKey, flickrParamAppKey, 
                         photoSetId, flickrParamPhotoSetId, 
                         @"url_t, url_s, url_m, url_sq", flickrParamExtras, 
                         nil];
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photoset = [json objectForKey:@"photoset"];
   NSArray *photos = [photoset objectForKey:@"photo"];
   return photos;
}

#pragma mark - Helper methods

- (NSData *)fetchResponseWithURL:(NSURL *)URL                              // 16
{
   NSURLRequest *request = [NSURLRequest requestWithURL:URL];              // 17
   NSURLResponse *response = nil;                                          // 18
   NSError *error = nil;                                                   // 19
   NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                        returningResponse:&response 
                                                    error:&error];         // 20
   if (data == nil) {                                                      // 21
      NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
   }
   return data;                                                            // 22
}

- (NSURL *)buildFlickrURLWithParameters:(NSDictionary *)parameters         // 23
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

- (NSString *)stringWithData:(NSData *)data                                // 24
{
   NSString *result = [[NSString alloc] initWithBytes:[data bytes] 
                                               length:[data length] 
                                             encoding:NSUTF8StringEncoding];
   return result;
}

- (NSString *)stringByRemovingFlickrJavaScript:(NSData *)data              // 25
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

- (id)flickrJSONSWithParameters:(NSDictionary *)parameters                 // 26
{
   NSURL *URL = [self buildFlickrURLWithParameters:parameters];
   NSData *data = [self fetchResponseWithURL:URL];
   NSString *string = [self stringByRemovingFlickrJavaScript:data];
   NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
   
   NSLog(@"%s: json: %@", __PRETTY_FUNCTION__, string);
   
   NSError *error = nil;
   id json = [NSJSONSerialization JSONObjectWithData:jsonData 
                                             options:NSJSONReadingAllowFragments 
                                               error:&error];
   if (json == nil) {
      NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
   }
   
   return json;
}

@end
