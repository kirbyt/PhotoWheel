//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/7/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
{
    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;

- (void)toggleChromeDisplay;

@end

