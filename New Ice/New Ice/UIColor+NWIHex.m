//
//  UIColor+NWIHex.m
//  New Ice
//
//  Created by Naphat Sanguansin on 5/6/14.
//
//

#import "UIColor+NWIHex.h"

@implementation UIColor (NWIHex)

+(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned int hexInt = 0;
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    return [self colorFromHexInt:hexInt];
}
+(UIColor *)colorFromHexInt:(unsigned int)hexColor
{
    UIColor *color = [UIColor colorWithRed:((CGFloat) ((hexColor & 0xFF0000) >> 16))/255
                                     green:((CGFloat) ((hexColor & 0x00FF00) >> 8))/255
                                      blue:((CGFloat) (hexColor & 0x0000FF))/255
                                     alpha:1.0];
    return color;
}

@end
