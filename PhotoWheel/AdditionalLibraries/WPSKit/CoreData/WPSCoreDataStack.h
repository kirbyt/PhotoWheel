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
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface WPSCoreDataStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/*
 Returns YES if successful, otherwise returns NO and sets the error.
 */
- (BOOL)saveMainContext:(NSError **)error;

#pragma mark - Model file info
/**
 You must override the following before accessing the Core Data Stack
 if you wish to change the default behavior.
 */
- (NSString *)modelName;
- (NSString *)pathToModel;

- (NSString *)storeFileName;
- (NSString *)pathToLocalStore;
- (NSString *)pathToDefaultStore;

#pragma mark - Persistent Store Coordinator Info
/**
 You must override the following before accessing the Core Data Stack
 if you wish to change the default behavior.
 */
- (NSDictionary *)persistentStoreOptions;
- (NSString *)persistentStoreConfiguration;

#pragma mark - Basic fetching

- (NSUInteger)countForEntityName:(NSString *)entityName error:(NSError **)error;
- (NSArray *)objectsWithEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate limit:(NSUInteger)limit batchSize:(NSUInteger)batchSize sortDescriptors:(NSArray *)descriptors error:(NSError **)error;
- (NSArray *)objectsWithEntityName:(NSString *)entityName limit:(NSUInteger)limit batchSize:(NSUInteger)batchSize sortDescriptors:(NSArray *)descriptors error:(NSError **)error;
- (NSArray *)allObjectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)descriptors error:(NSError **)error;
- (NSArray *)objectsWithEntityName:(NSString *)entityName values:(NSArray *)values matchingKey:(NSString *)key error:(NSError **)error;


@end
