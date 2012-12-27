//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 11/25/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, strong) NSArray *photos;

- (void)toggleChromeDisplay;

@property (strong, nonatomic) IBOutlet UIView *filterViewContainer;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;

// Actions that modify the image
- (IBAction)enhanceImage:(id)sender;
- (IBAction)zoomToFaces:(id)sender;
- (IBAction)applyFilter:(id)sender;

// Actions that save or restore the image
- (IBAction)revertToOriginal:(id)sender;
- (IBAction)saveImage:(id)sender;
- (IBAction)cancel:(id)sender;

@end
