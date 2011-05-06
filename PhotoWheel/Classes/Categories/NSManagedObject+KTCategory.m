//
//  NSManagedObject+KTCategory.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/5/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "NSManagedObject+KTCategory.h"


@implementation NSManagedObject (NSManagedObject_KTCategory)

- (BOOL)kt_save
{
   BOOL success = YES;
   NSManagedObjectContext *context = [self managedObjectContext];
   
   // Save the context.
   NSError *error = nil;
   if (![context save:&error])
   {
      success = NO;
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   return success;
}

@end
