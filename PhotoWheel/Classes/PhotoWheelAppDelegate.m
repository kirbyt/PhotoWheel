//
//  PhotoWheelAppDelegate.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelAppDelegate.h"

#import "RootViewController.h"

@interface PhotoWheelAppDelegate ()
@property (nonatomic, retain) NSMutableArray *data;
- (NSString *)dataPath;
- (BOOL)loadData;
- (BOOL)saveData;
@end

@implementation PhotoWheelAppDelegate

@synthesize window = window_;
@synthesize splitViewController = splitViewController_;
@synthesize rootViewController = rootViewController_;
@synthesize detailViewController = detailViewController_;
@synthesize data = data_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   // Override point for customization after application launch.
   // Add the split view controller's view to the window and display.
   self.window.rootViewController = self.splitViewController;
   [self.window makeKeyAndVisible];
   return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
   /*
    Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   /*
    Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    */
   [self saveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   /*
    Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   /*
    Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    */
   [self loadData];
   [[self rootViewController] setData:[self data]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   /*
    Called when the application is about to terminate.
    Save data if appropriate.
    See also applicationDidEnterBackground:.
    */
   [self saveData];
}

- (void)dealloc
{
   [window_ release];
   [splitViewController_ release];
   [rootViewController_ release];
   [detailViewController_ release];
   [data_ release];
   [super dealloc];
}


#pragma mark - 
#pragma mark Data Management

- (NSString *)dataPath
{
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *documentsDirectoryPath = [paths objectAtIndex:0];
   NSString *path = [documentsDirectoryPath stringByAppendingPathComponent:@"photowheel.dat"];
   return path;
}

- (BOOL)loadData
{
   BOOL success = YES;
   
   NSString *path = [self dataPath];
   NSFileManager *fileManager = [[NSFileManager alloc] init];
   BOOL fileExists = [fileManager fileExistsAtPath:path];
   [fileManager release];
   
   if (fileExists) {
      NSMutableArray *newData = [[NSMutableArray alloc] initWithContentsOfFile:[self dataPath]];
      [self setData:newData];
      [newData release];
      
   } else {
      NSMutableArray *newData = [[NSMutableArray alloc] init];
      [self setData:newData];
      [newData release];
      
   }
   
   return success;
}

- (BOOL)saveData
{
   NSString *path = [self dataPath];
   NSError *error = nil;
   BOOL success = [[self data] writeToFile:path atomically:YES];
   if (!success) {
      // Handle error.
      NSLog(@"Error saving data: %@ %@", [error localizedDescription], [error userInfo]);
   }
   return success;
}

@end
