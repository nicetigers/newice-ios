//
//  Section+FormattedName.m
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import "Section+FormattedName.h"
#import "Course.h"

@implementation Section (FormattedName)

-(NSString *)formattedName
{
    return [NSString stringWithFormat:@"%@ - %@", self.course.courseListings, self.name];
}

@end