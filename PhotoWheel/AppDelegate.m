//
//  AppDelegate.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/7/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import "SVProgressHUD.h"
#import "WPSAlertView.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface AppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *iCloudNotificationQueue;
@property (nonatomic, assign, readwrite, getter=isPersistentStoreReady) BOOL persistentStoreReady;
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:HOCKEYKIT_BETA_APPKEY liveIdentifier:HOCKEYKIT_LIVE_APPKEY delegate:self];
   [[BITHockeyManager sharedHockeyManager] startManager];
   
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
         // Force assertion to report the error.
         ZAssert(NO, @"Unresolved error %@\n%@", [error localizedDescription], [error userInfo]);
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
   if (_managedObjectContext != nil) {
      return _managedObjectContext;
   }
   
   NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
   if (coordinator != nil) {
      _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
      [_managedObjectContext setPersistentStoreCoordinator:coordinator];
      [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFromCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
   }
   return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
   if (_managedObjectModel != nil) {
      return _managedObjectModel;
   }
   NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoWheel" withExtension:@"momd"];
   _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
   return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (_persistentStoreCoordinator != nil)
   {
      return _persistentStoreCoordinator;
   }
   
   [self setPersistentStoreReady:NO];
   [SVProgressHUD showWithStatus:@"Syncing with iCloud" maskType:SVProgressHUDMaskTypeClear];

   NSError *error = nil;
   NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotoWheel.sqlite"];
   NSManagedObjectModel *model = [self managedObjectModel];
   BOOL success = [self progressivelyMigrateURL:storeURL ofType:NSSQLiteStoreType toModel:model error:&error];
   if (!success) {
      // TODO: Alert the user.
      DLog(@"Migration error: %@", [error localizedDescription]);
   }

   _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
   
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      // Build a URL to use as NSPersistentStoreUbiquitousContentURLKey
      NSURL *cloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
      
      NSDictionary *options = nil;
      
      if (cloudURL != nil) {
         NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"photowheel"];
         cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
         
         options = @{
         NSPersistentStoreUbiquitousContentNameKey : @"com.whitepeaksoftware.photowheel",
         NSPersistentStoreUbiquitousContentURLKey : cloudURL,
         NSMigratePersistentStoresAutomaticallyOption : @YES,
         NSInferMappingModelAutomaticallyOption: @YES,
         };
      }
      
      NSError *error = nil;
      [_persistentStoreCoordinator lock];
      NSPersistentStore *newStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
      if (!newStore)
      {
         ZAssert(NO, @"Unresolved error %@\n%@", [error localizedDescription], [error userInfo]);
      }
      [_persistentStoreCoordinator unlock];
      [self setPersistentStoreReady:(newStore != nil)];
      
      dispatch_async(dispatch_get_main_queue(), ^{
         if (newStore) {
            DLog(@"Asynchronously added persistent store!");
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefetchAllDataNotification object:self userInfo:nil];
         } else {
            [self alertUserAboutError:error];
         }
         [SVProgressHUD dismiss];
      });
   });
   
   return _persistentStoreCoordinator;
}

#pragma mark - Progressive Migration -

- (BOOL)progressivelyMigrateURL:(NSURL*)sourceStoreURL ofType:(NSString*)type toModel:(NSManagedObjectModel*)finalModel error:(NSError**)error
{
   NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:sourceStoreURL error:error];
   if (!sourceMetadata) {
      return NO;
   }
   
   if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
      *error = nil;
      return YES;
   }
   
   //Find the source model
   NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
   ZAssert(sourceModel != nil, @"Failed to find source model\n%@", sourceMetadata);

   //Find all of the mom and momd files in the Resources directory
   NSMutableArray *modelPaths = [NSMutableArray array];
   NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:nil];
   for (NSString *momdPath in momdArray) {
      NSString *resourceSubpath = [momdPath lastPathComponent];
      NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:resourceSubpath];
      [modelPaths addObjectsFromArray:array];
   }
   NSArray* otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:nil];
   [modelPaths addObjectsFromArray:otherModels];
   if (!modelPaths || ![modelPaths count]) {
      //Throw an error if there are no models
      NSDictionary *dict = @{NSLocalizedDescriptionKey:@"No models found in bundle."};
      *error = [NSError errorWithDomain:@"PhotoWheel" code:8001 userInfo:dict];
      return NO;
   }
   
   //See if we can find a matching destination model
   NSMappingModel *mappingModel = nil;
   NSManagedObjectModel *targetModel = nil;
   NSString *modelPath = nil;
   for (modelPath in modelPaths) {
      targetModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
      mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:targetModel];
      //If we found a mapping model then proceed
      if (mappingModel) {
         break;
      }
   }
   //We have tested every model, if nil here we failed
   if (!mappingModel) {
      NSDictionary *dict = @{NSLocalizedDescriptionKey:@"No models found in bundle."};
      *error = [NSError errorWithDomain:@"PhotoWheel" code:8001 userInfo:dict];
      return NO;
   }
   //We have a mapping model and a destination model.  Time to migrate
   NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:targetModel];
   NSString *modelName = [[modelPath lastPathComponent] stringByDeletingPathExtension];
   NSString *storeExtension = [[sourceStoreURL path] pathExtension];
   NSString *storePath = [[sourceStoreURL path] stringByDeletingPathExtension];
   //Build a path to write the new store
   storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
   NSURL *destinationStoreURL = [NSURL fileURLWithPath:storePath];
   if (![manager migrateStoreFromURL:sourceStoreURL
                                type:type
                             options:nil
                    withMappingModel:mappingModel
                    toDestinationURL:destinationStoreURL
                     destinationType:type
                  destinationOptions:nil
                               error:error]) {
      return NO;
   }
   //Migration was successful, move the files around to preserve the source
   NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
   guid = [guid stringByAppendingPathExtension:modelName];
   guid = [guid stringByAppendingPathExtension:storeExtension];
   NSString *appSupportPath = [storePath stringByDeletingLastPathComponent];
   NSString *backupPath = [appSupportPath stringByAppendingPathComponent:guid];
   
   NSFileManager *fileManager = [NSFileManager defaultManager];
   if (![fileManager moveItemAtPath:[sourceStoreURL path] toPath:backupPath error:error]) {
      //Failed to copy the file
      return NO;
   }
   //Move the destination to the source path
   if (![fileManager moveItemAtPath:storePath toPath:[sourceStoreURL path] error:error]) {
      //Try to back out the source move first, no point in checking it for errors
      [fileManager moveItemAtPath:backupPath toPath:[sourceStoreURL path] error:nil];
      return NO;
   }
   //We may not be at the "current" model yet, so recurse
   return [self progressivelyMigrateURL:sourceStoreURL ofType:type toModel:finalModel error:error];
}

#pragma mark - Report iCloud Error 

- (void)alertUserAboutError:(NSError *)error
{
   NSString *message = [NSString stringWithFormat:@"Uh oh. Something failed with iCloud syncing. Please email this error to me, Kirby Turner. ('%@')", [error localizedDescription]];
   WPSAlertView *alert = [[WPSAlertView alloc] initWithTitle:@"Sync Error" message:message completion:^(WPSAlertView *alertView, NSInteger buttonIndex) {
      
      if (buttonIndex == 1) {
         
         NSString *messageBody = [NSString stringWithFormat:@"Something failed with iCloud syncing. Here's the error:\n\n\n%i %@\n\n%@\n\n%@\n\n%@", [error code], [error domain],[error localizedDescription], [error userInfo], [error localizedFailureReason]];
         
         MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
         [mailer setMailComposeDelegate:self];
         [mailer setSubject:@"PhotoWheel sync error"];
         [mailer setMessageBody:messageBody isHTML:NO];
         [mailer setToRecipients:@[@"support@whitepeaksoftware.com"]];
         
         [[[self window] rootViewController] presentViewController:mailer animated:YES completion:nil];
      }
      
   } cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send Email", nil];
   
   [alert show];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
   if (result == MFMailComposeResultSent) {
      WPSAlertView *alert = [[WPSAlertView alloc] initWithTitle:@"Thanks" message:@"Thank you for your help." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
   }
   [[[self window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - iCloud Sync

- (void)mergeChangesFromCloud:(NSNotification *)notification
{
   [self queueMergeCloudNotification:notification];
   if ([self isPersistentStoreReady]) {
      [self processMergeCloudNotifications];
   }
}

- (void)queueMergeCloudNotification:(NSNotification *)notification
{
   DLog(@"Queuing iCloud merge notification.");
   if (![self iCloudNotificationQueue]) {
      NSMutableArray *newQueue = [NSMutableArray array];
      [self setICloudNotificationQueue:newQueue];
   }
   [[self iCloudNotificationQueue] addObject:notification];
}

- (void)processMergeCloudNotifications
{
   DLog(@"Processing %i notifications.", [[self iCloudNotificationQueue] count]);
   NSManagedObjectContext* moc = [self managedObjectContext];
   [moc performBlock:^{
      [[self iCloudNotificationQueue] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
         [moc mergeChangesFromContextDidSaveNotification:obj];
      }];
      [moc processPendingChanges];
      [[self iCloudNotificationQueue] removeAllObjects];
      
      dispatch_async(dispatch_get_main_queue(), ^{
         NSNotification *refreshNotificaiton = [NSNotification notificationWithName:kRefetchAllDataNotification object:self userInfo:nil];
         [[NSNotificationCenter defaultCenter] postNotification:refreshNotificaiton];
      });
   }];
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
   return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - BITUpdateManagerDelegate
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager
{
#ifndef CONFIGURATION_AppStore
   if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
      return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
   return nil;
}

@end
