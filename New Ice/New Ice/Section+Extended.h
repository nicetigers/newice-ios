//
//  Section+FormattedName.h
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import "Section.h"
@class User;

@interface Section (Extended)

-(NSString *)formattedName;
-(UIColor *)colorForUser:(User *)user;

@end
