//
//  UserSectionTable.h
//  New Ice
//
//  Created by Naphat Sanguansin on 5/4/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Section, User;

@interface UserSectionTable : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) User *user;

@end
