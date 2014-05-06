//
//  UIColor+NWIHex.h
//  New Ice
//
//  Created by Naphat Sanguansin on 5/6/14.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (NWIHex)

+(UIColor *)colorFromHexString:(NSString *)hexString;

+(UIColor *)colorFromHexInt:(unsigned int)hexInt;

@end
