//
//  Nub.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "_Nub.h"

#define NUB_IMAGE_SIZE_WIDTH 80
#define NUB_IMAGE_SIZE_HEIGHT 80

@interface Nub : _Nub 
{

}

+ (NSString *)entityName;
+ (Nub *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context;

- (UIImage *)smallImage;
- (UIImage *)deviceSpecificImage;
- (UIImage *)originalImage;
- (void)saveImage:(UIImage *)image;

@end
