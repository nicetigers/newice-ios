//
//  Section+FormattedName.m
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import "Section+Extended.h"
#import "Course.h"
#import "UserSectionTable.h"
#import "UIColor+NWIHex.h"
#import "User+Extended.h"

@implementation Section (Extended)

-(NSString *)formattedName
{
    return [NSString stringWithFormat:@"%@ - %@", self.course.courseListings, self.name];
}

-(UIColor *)colorForUser:(User *)user
{
    unsigned int hexColor = 0;
    for (UserSectionTable *enrollment in self.enrollment) {
        if (user == enrollment.user) {
            hexColor = [enrollment.color unsignedIntValue];
        }
    }
    UIColor *color = [UIColor colorFromHexInt:hexColor];
    return color;
}

@end