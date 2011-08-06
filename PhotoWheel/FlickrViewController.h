//
//  FlickrViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"


@interface FlickrViewController : UIViewController <UISearchBarDelegate, GridViewDataSource>

@property (nonatomic, strong) IBOutlet GridView *gridView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectID *objectID;

- (IBAction)done:(id)sender;

@end
