/**
 **   UIImage+WPSKit
 **
 **   Created by Kirby Turner.
 **   Copyright (c) 2011 White Peak Software. All rights reserved.
 **
 **   Permission is hereby granted, free of charge, to any person obtaining 
 **   a copy of this software and associated documentation files (the 
 **   "Software"), to deal in the Software without restriction, including 
 **   without limitation the rights to use, copy, modify, merge, publish, 
 **   distribute, sublicense, and/or sell copies of the Software, and to permit 
 **   persons to whom the Software is furnished to do so, subject to the 
 **   following conditions:
 **
 **   The above copyright notice and this permission notice shall be included 
 **   in all copies or substantial portions of the Software.
 **
 **   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 **   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 **   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 **   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
 **   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 **   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 **   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **
 **/

#import "UIImage+WPSKit.h"

@implementation UIImage (WPSKit)

- (UIImage *)wps_scaleToSize:(CGSize)newSize 
{
   UIGraphicsBeginImageContextWithOptions(newSize, 1.0f, 1.0f);
   CGRect rect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
   [self drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   return scaledImage;
}

- (UIImage *)wps_scaleAspectToMaxSize:(CGFloat)newSize 
{
   CGSize size = [self size];
   CGFloat ratio;
   if (size.width > size.height) {
      ratio = newSize / size.width;
   } else {
      ratio = newSize / size.height;
   }

   CGSize scaleToSize = CGSizeMake(ratio * size.width, ratio * size.height);
   return [self wps_scaleToSize:scaleToSize];
}

- (UIImage *)wps_scaleAspectFillToSize:(CGSize)newSize
{
   CGSize imageSize = [self size];
   CGFloat horizontalRatio = newSize.width / imageSize.width;
   CGFloat verticalRatio = newSize.height / imageSize.height;
   CGFloat ratio = MAX(horizontalRatio, verticalRatio);   

   CGSize scaleToSize = CGSizeMake(imageSize.width * ratio, imageSize.height * ratio);
   return [self wps_scaleToSize:scaleToSize];
}

- (UIImage *)wps_scaleAspectFitToSize:(CGSize)newSize
{
   CGSize imageSize = [self size];
   CGFloat horizontalRatio = newSize.width / imageSize.width;
   CGFloat verticalRatio = newSize.height / imageSize.height;
   CGFloat ratio = MIN(horizontalRatio, verticalRatio);   
   
   CGSize scaleToSize = CGSizeMake(imageSize.width * ratio, imageSize.height * ratio);
   return [self wps_scaleToSize:scaleToSize];
}

- (UIImage *)wps_cropToRect:(CGRect)cropRect
{
   CGRect cropRectIntegral = CGRectIntegral(cropRect);
   CGImageRef croppedImageRef = CGImageCreateWithImageInRect([self CGImage], cropRectIntegral);
   UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
   CGImageRelease(croppedImageRef);
   
   return croppedImage;
}

- (UIImage *)wps_scaleAndCropToSize:(CGSize)newSize 
{
   UIImage *scaledImage = [self wps_scaleAspectFillToSize:newSize];
   
   // Crop the image to the requested new size maintaining
   // the inner most parts of the image.
   CGSize imageSize = [scaledImage size];
   CGFloat offsetX = round((imageSize.width / 2) - (newSize.width / 2));
   CGFloat offsetY = round((imageSize.height / 2) - (newSize.height / 2));
   
   CGRect cropRect = CGRectMake(offsetX, offsetY, newSize.width, newSize.height);
   UIImage *croppedImage = [scaledImage wps_cropToRect:cropRect];
   return croppedImage;
}

@end
