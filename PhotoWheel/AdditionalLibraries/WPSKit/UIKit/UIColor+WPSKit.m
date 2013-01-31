/**
 **   UIColor+WPSKit
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

#import "UIColor+WPSKit.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIColor (WPSKit)

+ (UIColor *)wps_colorWithHexString:(NSString *)hexString
{
   return [self wps_colorWithHexString:hexString alpha:1.0];
}
 
+ (UIColor *)wps_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
   // The following code is a modified version from NachoMan.
   // https://github.com/NachoMan/phonegap/blob/bedf10f873a79c66aea5d89e380479273269eaf7/iphone/Classes/NSString+HexColor.m

   NSString *hexColor = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];  
   
   if ([hexColor length] < 6) {
      return [UIColor blackColor];
   }
   if ([hexColor hasPrefix:@"#"]) {
      hexColor = [hexColor substringFromIndex:1];  
   }
   if ([hexColor length] != 6) {
      return [UIColor blackColor];
   }
   
   NSRange range;  
   range.location = 0;  
   range.length = 2; 
   
   NSString *rString = [hexColor substringWithRange:range];  
   
   range.location = 2;  
   NSString *gString = [hexColor substringWithRange:range];  
   
   range.location = 4;  
   NSString *bString = [hexColor substringWithRange:range];  
   
   // Scan values  
   unsigned int r, g, b;
   [[NSScanner scannerWithString:rString] scanHexInt:&r];  
   [[NSScanner scannerWithString:gString] scanHexInt:&g];  
   [[NSScanner scannerWithString:bString] scanHexInt:&b];
   
   CGFloat red = ((float) r / 255.0f);
   CGFloat green = ((float) g / 255.0f);
   CGFloat blue = ((float) b / 255.0f);
   
   UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
   return color;
}

+ (UIImage *)wps_imageFromColor:(UIColor *)color
{
   CGRect rect = CGRectMake(0, 0, 1, 1);
   UIGraphicsBeginImageContext(rect.size);
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSetFillColorWithColor(context, [color CGColor]);
   CGContextFillRect(context, rect);
   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   return image;
}

- (NSString *)wps_hexString
{  
   const CGFloat *components = CGColorGetComponents([self CGColor]);  
   CGFloat red = components[0];
   CGFloat green = components[1];
   CGFloat blue = components[2];  
   
   // Fix range if needed  
   if (red < 0.0f) red = 0.0f;  
   if (green < 0.0f) green = 0.0f;  
   if (blue < 0.0f) blue = 0.0f;  
   
   if (red > 1.0f) red = 1.0f;  
   if (green > 1.0f) green = 1.0f;  
   if (blue > 1.0f) blue = 1.0f;  
   
   NSString *hex = [NSString stringWithFormat:@"%02X%02X%02X", (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
   return hex;
}

@end
