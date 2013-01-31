/**
 **   WPSCoreDataStack
 **
 **   Created by Kirby Turner.
 **   Copyright 2011 White Peak Software. All rights reserved.
 **
 **   Permission is hereby granted, free of charge, to any person obtaining 
 **   a copy of this software and associated documentation files (the 
 **   "Software"), to deal in the Software without restriction, including 
 **   without limitation the rights to use, copy, modify, merge, publish, 
 **   distribute, sublicense, and/or sell copies of the Software, and to permit 
 **   persons to whom the Software is furnished to do so, subject to the 
 **   following conditions:
 **
 **   The above copyright notice and this permission notice shall be included 
 **   in all copies or substantial portions of the Software.
 **
 **   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 **   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 **   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 **   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
 **   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 **   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 **   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **
 **   This code is based on the PRPBasicDataModel code
 **   presented in the book iOS Receipts.
 **   http://pragprog.com/titles/cdirec/ios-recipes
 ** 
 **   Portions created by Matt Drance.
 **   Portions copyright 2010 Bookhouse Software, LLC. All rights reserved.
 **
 **/

#import "WPSCoreDataStack.h"

@interface WPSCoreDataStack ()
- (NSString *)documentsDirectory;
@end


@implementation WPSCoreDataStack

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainManagedObjectContext = _mainManagedObjectContext;

#pragma mark - Basic fetching

- (NSUInteger)countForEntityName:(NSString *)entityName error:(NSError **)error 
{
   NSManagedObjectContext *context = [self mainManagedObjectContext];
   NSUInteger count = 0;
   NSFetchRequest *request = [[NSFetchRequest alloc] init];
   [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
   [context countForFetchRequest:request error:error];
   
   return count;
}

- (NSArray *)objectsWithEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate limit:(NSUInteger)limit batchSize:(NSUInteger)batchSize sortDescriptors:(NSArray *)descriptors error:(NSError **)error 
{
   NSManagedObjectContext *context = [self mainManagedObjectContext];
   NSFetchRequest *request = [[NSFetchRequest alloc] init];
   [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
   [request setSortDescriptors:descriptors];
   [request setFetchLimit:limit];
   [request setFetchBatchSize:batchSize];
   [request setPredicate:predicate];
   NSArray *results = [context executeFetchRequest:request error:error];
   
   return results;    
}

- (NSArray *)objectsWithEntityName:(NSString *)entityName limit:(NSUInteger)limit batchSize:(NSUInteger)batchSize sortDescriptors:(NSArray *)descriptors error:(NSError **)error 
{
   return [self objectsWithEntityName:entityName matchingPredicate:nil limit:limit batchSize:batchSize sortDescriptors:descriptors error:error];
}

- (NSArray *)allObjectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)descriptors error:(NSError **)error 
{
   return [self objectsWithEntityName:entityName matchingPredicate:nil limit:0 batchSize:0 sortDescriptors:descriptors error:error];
}

- (NSArray *)objectsWithEntityName:(NSString *)entityName values:(NSArray *)values matchingKey:(NSString *)key error:(NSError **)error 
{
   return [self objectsWithEntityName:entityName matchingPredicate:[NSPredicate predicateWithFormat:@"%@ in %@", key, values] limit:0 batchSize:0 sortDescriptors:nil error:error];
}

#pragma mark - Filesystem hooks

- (NSString *)modelName 
{
   return [[[NSBundle mainBundle] bundleIdentifier] pathExtension];
}

- (NSString *)pathToModel 
{
   NSString *filename = [self modelName];
   NSString *localModelPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"momd"];
   NSAssert1(localModelPath, @"Could not find '%@.momd'", filename);
   return localModelPath;
}

- (NSString *)storeFileName 
{
   return [[self modelName] stringByAppendingPathExtension:@"sqlite"];
}

- (NSString *)pathToLocalStore 
{
   NSString *storeName = [self storeFileName];
   NSString *docPath = [self documentsDirectory];
   return [docPath stringByAppendingPathComponent:storeName];
}

- (NSString *)pathToDefaultStore 
{
   NSString *storeName = [self storeFileName];
   return [[NSBundle mainBundle] pathForResource:storeName ofType:nil];
}

#pragma mark - Persistent Store Coordinator Info

- (NSDictionary *)persistentStoreOptions
{
   NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                            nil];
   return options;
}

- (NSString *)persistentStoreConfiguration
{
   return nil;
}

#pragma mark - Core Data Stack

- (NSManagedObjectContext *)mainManagedObjectContext 
{
   if (_mainManagedObjectContext == nil) {
      NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
      if (coordinator) {
         _mainManagedObjectContext = [[NSManagedObjectContext alloc] init];
         [_mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
      }
   }
   
   return _mainManagedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel 
{
   if (_managedObjectModel == nil) {
      NSURL *storeURL = [NSURL fileURLWithPath:[self pathToModel]];
      _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:storeURL];
   }
   return _managedObjectModel;
}

- (void)preinstallDefaultDatabase 
{
   // Copy the default DB from the app bundle if none exists (either 
   // first launch or just removed above)
   NSString *pathToLocalStore = [self pathToLocalStore];
   NSString *pathToDefaultStore = [self pathToDefaultStore];
   NSError *error = nil;
   NSFileManager *fileManager = [NSFileManager defaultManager];
   BOOL noLocalDBExists = ![fileManager fileExistsAtPath:pathToLocalStore];
   BOOL defaultDBExists = [fileManager fileExistsAtPath:pathToDefaultStore];
   if (noLocalDBExists && defaultDBExists) {
      if (![[NSFileManager defaultManager] copyItemAtPath:pathToDefaultStore toPath:pathToLocalStore error:&error]) {
         NSLog(@"Error copying default DB to %@ (%@)", pathToLocalStore, error);
      }
   }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
   if (_persistentStoreCoordinator == nil) {
      NSURL *storeURL = [NSURL fileURLWithPath:[self pathToLocalStore]];
      NSPersistentStoreCoordinator *coordinator;
      coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
      NSDictionary *options = [self persistentStoreOptions];
      NSString *configuration = [self persistentStoreConfiguration];
      
      NSError *error = nil;
      if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:options error:&error]) {
         NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey];
         NSException *exc = nil;
         NSString *reason = @"Could not create persistent store.";
         exc = [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
         @throw exc;
      }
      _persistentStoreCoordinator = coordinator;
   }
   
   return _persistentStoreCoordinator;
}

#pragma mark - Basic Operations

- (BOOL)saveMainContext:(NSError **)error;
{
   BOOL success = YES;
   NSManagedObjectContext *managedObjectContext = [self mainManagedObjectContext];
   if (managedObjectContext != nil)
   {
      if ([managedObjectContext hasChanges] && ![managedObjectContext save:error])
      {
         success = NO;
      } 
   }
   return success;
}

#pragma mark - Helpers

- (NSString *)documentsDirectory 
{
   NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
   if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
      NSError *error = nil;
      if (![[NSFileManager defaultManager] createDirectoryAtPath:docDir
                                     withIntermediateDirectories:YES
                                                      attributes:nil 
                                                           error:&error]) {
         NSString *errorMsg = @"Could not find or create a Documents directory.";
         NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey];
         NSException *directoryException = [NSException exceptionWithName:NSInternalInconsistencyException
                                                                   reason:errorMsg
                                                                 userInfo:errorInfo];
         
         @throw directoryException;
      }
   }
   return docDir;
}

@end
