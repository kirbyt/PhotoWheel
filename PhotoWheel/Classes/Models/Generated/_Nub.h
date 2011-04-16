//
//  _Nub.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _PhotoWheel;

@interface _Nub : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * fileExtension;
@property (nonatomic, retain) NSString * baseFileName;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) _PhotoWheel * photoWheel;

@end
