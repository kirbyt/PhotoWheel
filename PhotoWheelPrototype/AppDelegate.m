//
//  AppDelegate.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "DetailViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   // Override point for customization after application launch.
   
   MasterViewController *masterViewController = 
      [[MasterViewController alloc] initWithNibName:@"MasterViewController" 
                                             bundle:nil];
   UINavigationController *masterNavigationController = 
      [[UINavigationController alloc] 
       initWithRootViewController:masterViewController];
   
   DetailViewController *detailViewController = 
      [[DetailViewController alloc] initWithNibName:@"DetailViewController" 
                                             bundle:nil];
   UINavigationController *detailNavigationController = 
      [[UINavigationController alloc] 
       initWithRootViewController:detailViewController];
   
   // Add this line. It tells the master view controller which
   // detail view controller to use.
   [masterViewController setDetailViewController:detailViewController];
   [masterViewController setManagedObjectContext:[self managedObjectContext]];
   
   self.splitViewController = [[UISplitViewController alloc] init];
   self.splitViewController.delegate = detailViewController;
   self.splitViewController.viewControllers = [NSArray arrayWithObjects:
                                               masterNavigationController, 
                                               detailNavigationController, 
                                               nil];
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

#pragma mark - Core Data Stack 

- (NSManagedObjectContext *)managedObjectContext
{
   if (__managedObjectContext != nil)
   {
      return __managedObjectContext;
   }
   
   NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
   if (coordinator != nil)
   {
      __managedObjectContext = [[NSManagedObjectContext alloc] init];
      [__managedObjectContext setPersistentStoreCoordinator:coordinator];
   }
   return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
   if (__managedObjectModel != nil)
   {
      return __managedObjectModel;
   }
   NSURL *modelURL = [[NSBundle mainBundle]
                      URLForResource:@"PhotoWheelPrototype"
                      withExtension:@"momd"];
   __managedObjectModel = 
   [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
   return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (__persistentStoreCoordinator != nil)
   {
      return __persistentStoreCoordinator;
   }
   
   NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager]
                                            URLsForDirectory:NSDocumentDirectory
                                            inDomains:NSUserDomainMask]
                                           lastObject];
   NSURL *storeURL = [applicationDocumentsDirectory
                      URLByAppendingPathComponent:@"PhotoWheelPrototype.sqlite"];
   
   NSError *error = nil;
   __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
   if (![__persistentStoreCoordinator
         addPersistentStoreWithType:NSSQLiteStoreType
         configuration:nil
         URL:storeURL
         options:nil
         error:&error])
   {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }    
   
   return __persistentStoreCoordinator;
}

@end
