//
//  SendEmailController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 9/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "SendEmailController.h"
#import "Photo.h"

@implementation SendEmailController

@synthesize viewController = viewController_;
@synthesize photos = photos_;

- (id)initWithViewController:(UIViewController<SendEmailControllerDelegate> *)viewController 
{
   self = [super init];
   if (self) {
      [self setViewController:viewController];
   }
   return self;
}

- (void)sendEmail 
{
	MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
   [mailer setMailComposeDelegate:self];
   [mailer setSubject:@"Pictures from PhotoWheel"];
   
   __block NSInteger index = 0;
   [[self photos] enumerateObjectsUsingBlock:^(id photo, BOOL *stop) {
      index++;
      UIImage *image;
      if ([photo isKindOfClass:[UIImage class]]) {
         image = photo;
      } else if ([photo isKindOfClass:[Photo class]]) {
         image = [photo originalImage];
      }
      
      if (image) {
         NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
         NSString *fileName = [NSString stringWithFormat:@"photo-%1", index];
         [mailer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:fileName];
      }
   }];
   
	[[self viewController] presentModalViewController:mailer animated:YES];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
   UIViewController<SendEmailControllerDelegate> *viewController = [self viewController];
	[viewController dismissModalViewControllerAnimated:YES];
   if (viewController && [viewController respondsToSelector:@selector(sendEmailControllerDidFinish:)]) {
      [viewController sendEmailControllerDidFinish:self];
   }
}

+ (BOOL)canSendMail
{
   return [MFMailComposeViewController canSendMail];
}

@end


