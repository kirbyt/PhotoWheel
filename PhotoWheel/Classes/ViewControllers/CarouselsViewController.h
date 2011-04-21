//
//  CarouselsViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTGridView.h"


@interface CarouselsViewController : UIViewController <NSFetchedResultsControllerDelegate, KTGridViewDataSource>
{
    
}

@property (nonatomic, retain) IBOutlet KTGridView *gridView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)showInfoScreen;
- (IBAction)addPhotoWheel;

@end
