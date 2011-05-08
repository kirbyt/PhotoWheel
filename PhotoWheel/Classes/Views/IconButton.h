//
//  IconButton.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/8/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IconButton : UIControl
{
    
}

+ (IconButton *)iconButtonWithImage:(UIImage*)image title:(NSString *)title;

- (void)setImage:(UIImage *)image;
- (void)setTitle:(NSString *)title;

@end
