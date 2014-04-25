//
//  NWIAuthenticator.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/23/14.
//
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(BOOL completed);

@protocol NWIAuthenticationViewControllerDelegate;

@interface NWIAuthenticator : NSObject<NWIAuthenticationViewControllerDelegate>

@property (nonatomic, strong) NSString *netid;

-(BOOL)authenticated;
-(void)showAuthenticationViewIfNeededWithCompletionHandler:(CompletionBlock)completion;

@end
