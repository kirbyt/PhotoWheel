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
   [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
   _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
   NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotoWheel.sqlite"];
   
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
         [self alertUserAboutError:error];
         [SVProgressHUD dismiss];
      });
   });
   
   return _persistentStoreCoordinator;
}

#pragma mark - Report iCloud Error 

- (void)alertUserAboutError:(NSError *)error
{
   NSString *message = [NSString stringWithFormat:@"I really want to see what this error message is. Tap OK to email it to me. ('%@')", [error localizedDescription]];
   WPSAlertView *alert = [[WPSAlertView alloc] initWithTitle:@"Error" message:message completion:^(WPSAlertView *alertView, NSInteger buttonIndex) {
      
      if (buttonIndex == 1) {
         
         NSString *messageBody = [NSString stringWithFormat:@"Let's see what this bad boy is reporting.\n\n\n%i %@\n\n%@\n\n%@\n\n%@", [error code], [error domain],[error localizedDescription], [error userInfo], [error localizedFailureReason]];
         
         MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
         [mailer setMailComposeDelegate:self];
         [mailer setSubject:@"PhotoWheel error"];
         [mailer setMessageBody:messageBody isHTML:NO];
         [mailer setToRecipients:@[@"support@whitepeaksoftware.com"]];
         
         [[[self window] rootViewController] presentViewController:mailer animated:YES completion:nil];
      }
      
   } cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
   
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
