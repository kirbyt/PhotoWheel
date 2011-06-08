//
//  SendEmailController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 6/8/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@protocol SendEmailControllerDelegate;


@interface SendEmailController : NSObject <MFMailComposeViewControllerDelegate> 
{
}

@property (nonatomic, retain) UIViewController<SendEmailControllerDelegate> *viewController;
@property (nonatomic, retain) NSSet *photos;


- (id)initWithViewController:(UIViewController<SendEmailControllerDelegate> *)viewController;
- (void)sendEmail;

@end


@protocol SendEmailControllerDelegate <NSObject>
@required
- (void)sendEmailControllerDidFinish:(SendEmailController *)controller;
@end
