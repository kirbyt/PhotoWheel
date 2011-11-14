//
//  AboutViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/8/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *version;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;

- (IBAction)done:(id)sender;
- (IBAction)visitWebsite:(id)sender;

@end
