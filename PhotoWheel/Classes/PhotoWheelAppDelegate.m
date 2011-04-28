//
//  PhotoWheelAppDelegate.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelAppDelegate.h"
#import "MainViewController.h"


@implementation PhotoWheelAppDelegate

@synthesize window = window_;
@synthesize rootViewController = rootViewController_;
@synthesize navigationController = navigationController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;

- (void)dealloc
{
   [window_ release];
   [rootViewController_ release];
   [navigationController_ release];

   [managedObjectContext_ release], managedObjectContext_ = nil;
   [managedObjectModel_ release], managedObjectModel_ = nil;
   [persistentStoreCoordinator_ release], persistentStoreCoordinator_ = nil;
   
   [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   // Override point for customization after application launch.
//   RootViewController *newController = [[RootViewController alloc] init];
//   [newController setManagedObjectContext:[self managedObjectContext]];
//   [self setRootViewController:newController];
//   [newController release];
   
//   CarouselsViewController *newController = [[CarouselsViewController alloc] init];
//   [newController setManagedObjectContext:[self managedObjectContext]];
//   [self setRootViewController:newController];
//   [newController release];
   
   MainViewController *newController = [[MainViewController alloc] init];
   [newController setManagedObjectContext:[self managedObjectContext]];
   [self setRootViewController:newController];
   [newController release];
   
//   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[self rootViewController]];
//   [self setNavigationController:navController];
//   [navController release];
   
   // Add the root view controller to the window.
   self.window.rootViewController = [self rootViewController];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   /*
    Called when the application is about to terminate.
    Save data if appropriate.
    See also applicationDidEnterBackground:.
    */
}


#pragma mark - Data Management

- (void)saveContext
{
   NSError *error = nil;
   NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
   if (managedObjectContext != nil)
   {
      if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
      {
         /*
          Replace this implementation with code to handle the error appropriately.
          
          abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
          */
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      } 
   }
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
   if (managedObjectContext_ != nil)
   {
      return managedObjectContext_;
   }
   
   NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
   if (coordinator != nil)
   {
      managedObjectContext_ = [[NSManagedObjectContext alloc] init];
      [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
   }
   return managedObjectContext_;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
   if (managedObjectModel_ != nil)
   {
      return managedObjectModel_;
   }
   NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoWheel" withExtension:@"momd"];
   managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
   return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (persistentStoreCoordinator_ != nil)
   {
      return persistentStoreCoordinator_;
   }
   
   NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotoWheel.sqlite"];
   
   NSError *error = nil;
   persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
   if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       
       Typical reasons for an error here include:
       * The persistent store is not accessible;
       * The schema for the persistent store is incompatible with current managed object model.
       Check the error message to determine what the actual problem was.
       
       
       If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
       
       If you encounter schema incompatibility errors during development, you can reduce their frequency by:
       * Simply deleting the existing store:
       [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
       
       * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
       
       Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
       
       */
      [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }    
   
   return persistentStoreCoordinator_;
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
   NSFileManager *fileManager = [[NSFileManager alloc] init];
   NSURL *URL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
   [fileManager release];
   return URL;
}

@end
