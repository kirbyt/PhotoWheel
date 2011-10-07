//
//  PhotoWheelAppDelegate.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/20/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelAppDelegate.h"
#import "MainViewController.h"

@implementation PhotoWheelAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   // Override point for customization after application launch.
   UINavigationController *customNavigationController = (UINavigationController *)[[self window] rootViewController];
   MainViewController *mainViewController = (MainViewController *)[customNavigationController topViewController];
   [mainViewController setManagedObjectContext:[self managedObjectContext]];
   
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
      __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
      [__managedObjectContext performBlockAndWait:^(void) {
         [__managedObjectContext setPersistentStoreCoordinator:coordinator];
         
         [__managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
         
         [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(mergeChangesFrom_iCloud:)
                                           name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                          object:coordinator];
         
      }];
   }
   return __managedObjectContext;
}

// this takes the NSPersistentStoreDidImportUbiquitousContentChangesNotification
// and transforms the userInfo dictionary into something that
// -[NSManagedObjectContext mergeChangesFromContextDidSaveNotification:] can consume
// then it posts a custom notification to let detail views know they might want to refresh.
// The main list view doesn't need that custom notification because the NSFetchedResultsController is
// already listening directly to the NSManagedObjectContext
- (void)mergeiCloudChanges:(NSDictionary*)noteInfo forContext:(NSManagedObjectContext*)moc
{
    @autoreleasepool {
        NSMutableDictionary *localUserInfo = [NSMutableDictionary dictionary];
        
        NSString* materializeKeys[] = { NSDeletedObjectsKey, NSInsertedObjectsKey };
        int c = (sizeof(materializeKeys) / sizeof(NSString*));
        for (int i = 0; i < c; i++) {
            NSSet* set = [noteInfo objectForKey:materializeKeys[i]];
            if ([set count] > 0) {
                NSMutableSet* objectSet = [NSMutableSet set];
                for (NSManagedObjectID* moid in set) {
                    [objectSet addObject:[moc objectWithID:moid]];
                }
                [localUserInfo setObject:objectSet forKey:materializeKeys[i]];
            }
        }
        
        NSString* noMaterializeKeys[] = { NSUpdatedObjectsKey, NSRefreshedObjectsKey, NSInvalidatedObjectsKey };
        c = (sizeof(noMaterializeKeys) / sizeof(NSString*));
        for (int i = 0; i < 2; i++) {
            NSSet* set = [noteInfo objectForKey:noMaterializeKeys[i]];
            if ([set count] > 0) {
                NSMutableSet* objectSet = [NSMutableSet set];
                for (NSManagedObjectID* moid in set) {
                    NSManagedObject* realObj = [moc objectRegisteredForID:moid];
                    if (realObj) {
                        [objectSet addObject:realObj];
                    }
                }
                [localUserInfo setObject:objectSet forKey:noMaterializeKeys[i]];
            }
        }
        
        NSNotification *fakeSave = [NSNotification notificationWithName:NSManagedObjectContextDidSaveNotification object:self  userInfo:localUserInfo];
        [moc mergeChangesFromContextDidSaveNotification:fakeSave]; 
        
        [moc processPendingChanges];
    }
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    NSLog(@"Merging changes from iCloud with notification: %@", notification);
    
    NSDictionary* userInfo = [notification userInfo];
   NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [moc performBlock:^{
        [self mergeiCloudChanges:userInfo forContext:moc];
    }];
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
    
    // assign the PSC to our app delegate ivar before adding the persistent store in the background
    // this leverages a behavior in Core Data where you can create NSManagedObjectContext and fetch requests
    // even if the PSC has no stores.  Fetch requests return empty arrays until the persistent store is added
    // so it's possible to bring up the UI and then fill in the results later
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotoWheel.sqlite"];
    
    // do this asynchronously since if this is the first time this particular device is syncing with preexisting
    // iCloud content it may take a long long time to download
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Build a URL to use as NSPersistentStoreUbiquitousContentURLKey
        NSURL *cloudURL;
#if TARGET_IPHONE_SIMULATOR
        cloudURL = nil;
#else
        cloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
#endif
        
        NSDictionary *options;
        
        if (cloudURL != nil) {
            NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"photowheel"];
            cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
            
            // here you add the API to turn on Core Data iCloud support
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"com.whitepeaksoftware.photowheel", NSPersistentStoreUbiquitousContentNameKey,
                       cloudURL, NSPersistentStoreUbiquitousContentURLKey,
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
        } else {
            NSLog(@"Uh-oh, nil result from URLForUbiquityContainerIdentifier");
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
        }
        
        NSError *error = nil;
        [__persistentStoreCoordinator lock];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [__persistentStoreCoordinator unlock];
        
        // tell the UI on the main thread we finally added the store and then
        // post a custom notification to make your views do whatever they need to such as tell their
        // NSFetchedResultsController to -performFetch again now there is a real store
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

@end
