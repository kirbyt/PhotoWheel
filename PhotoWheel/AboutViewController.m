//
//  AboutViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/8/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (nonatomic, weak) IBOutlet UILabel *copyright;
@property (nonatomic, weak) IBOutlet UILabel *version;
@property (nonatomic, weak) IBOutletCollection(UIButton) NSArray *buttons;

- (IBAction)done:(id)sender;
- (IBAction)visitWebsite:(id)sender;
@end

@implementation AboutViewController

- (IBAction)done:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
   NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
   NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
   NSString *fullVersion = [NSString stringWithFormat:@"Version %@ (build %@)", version, build];
   [[self version] setText:fullVersion];
   
   // Setup a gesture to test crash reporting.
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(crashTestDummies:)];
   [tap setNumberOfTapsRequired:5];
   [tap setNumberOfTouchesRequired:2];
   [[self copyright] addGestureRecognizer:tap];
   [[self copyright] setUserInteractionEnabled:YES];
}

- (void)viewDidUnload 
{
    [self setVersion:nil];
    [super viewDidUnload];
}

- (IBAction)visitWebsite:(id)sender
{
   NSArray *websites = [NSArray arrayWithObjects:
                        [NSURL URLWithString:@"http://www.learningipadprogramming.com/"],
                        [NSURL URLWithString:@"http://www.kirbyturner.com/"],
                        [NSURL URLWithString:@"http://www.atomicbird.com/"],
                        [NSURL URLWithString:@"http://www.elucidata.net/"],
                        [NSURL URLWithString:@"http://www.learningipadprogramming.com/source-code/"],
                        nil];

   NSURL *URL;
   NSInteger index = [sender tag];
   if (index < [websites count]) {
      URL = [websites objectAtIndex:index];
   } else {
      URL = [websites objectAtIndex:0];
   }
   
   [[UIApplication sharedApplication] openURL:URL];
}

- (void)crashTestDummies:(id)sender
{
   [NSException raise:@"Crash Test Dummy" format:@"Crash test dummy."];
}

@end
