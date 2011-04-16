//
//  Nub.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "_Nub.h"

@interface Nub : _Nub 
{

}

+ (NSString *)entityName;
+ (Nub *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context;

@end
