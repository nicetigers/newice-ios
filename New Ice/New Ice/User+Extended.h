//
//  User+Extended.h
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import "User.h"

@interface User (Extended)

+(User *)userByNetID:(NSString *)netID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
