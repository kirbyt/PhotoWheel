//
//  AppDelegate.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/7/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   [[CNSHockeyManager sharedHockeyManager] configureWithBetaIdentifier:HOCKEYKIT_BETA_APPKEY
                                                        liveIdentifier:HOCKEYKIT_LIVE_APPKEY
                                                              delegate:self];
   
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
   
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
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
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   // Saves changes in the application's managed object context before the application terminates.
   [self saveContext];
}

- (void)saveContext
{
   NSError *error = nil;
   NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
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

- (void)managedObjectContextDidSave:(NSNotification *)notification
{
   NSManagedObjectContext *context = [self managedObjectContext];
   [context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
   if (__managedObjectContext != nil)
   {
      return __managedObjectContext;
   }
   
   NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
   if (coordinator != nil)
   {
      NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
      [moc performBlockAndWait:^(void) {
         [moc setPersistentStoreCoordinator:coordinator];
         [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
         
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
      }];
      __managedObjectContext = moc;
   }
   return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
   if (__managedObjectModel != nil)
   {
      return __managedObjectModel;
   }
   NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoWheel" withExtension:@"momd"];
   __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
   return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (__persistentStoreCoordinator != nil)
   {
      return __persistentStoreCoordinator;
   }
   
   __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
   
   NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotoWheel.sqlite"];
   
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
      // Build a URL to use as NSPersistentStoreUbiquitousContentURLKey
      NSURL *cloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
      
      NSDictionary *options = nil;
      
      if (cloudURL != nil) {
         NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"photowheel"];
         cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
         
         //  The API to turn on Core Data iCloud support here.
         options = [NSDictionary dictionaryWithObjectsAndKeys:@"com.whitepeaksoftware.photowheel", NSPersistentStoreUbiquitousContentNameKey, cloudURL, NSPersistentStoreUbiquitousContentURLKey, [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
      }
      
      NSError *error = nil;
      [__persistentStoreCoordinator lock];
      if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
      {
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
      [__persistentStoreCoordinator unlock];
      
      dispatch_async(dispatch_get_main_queue(), ^{
         NSLog(@"asynchronously added persistent store!");
         [[NSNotificationCenter defaultCenter] postNotificationName:kRefetchAllDataNotification object:self userInfo:nil];
      });
   });
   
   return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
   return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - iCloud

- (void)mergeiCloudChanges:(NSNotification*)notification forContext:(NSManagedObjectContext*)moc
{
   [moc mergeChangesFromContextDidSaveNotification:notification];
   NSNotification *refreshNotificaiton = [NSNotification notificationWithName:kRefetchAllDataNotification object:self userInfo:[notification userInfo]];
   [[NSNotificationCenter defaultCenter] postNotification:refreshNotificaiton];
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification 
{
   NSManagedObjectContext* moc = [self managedObjectContext];
   [moc performBlock:^{
      [self mergeiCloudChanges:notification forContext:moc];
   }];
}

#pragma mark CNSHockeyManagerDelegate Methods

- (NSString *)customDeviceIdentifier {
#if defined (CONFIGURATION_Beta)
   if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
      return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
   }
#endif
   
   return nil;
}
@end
