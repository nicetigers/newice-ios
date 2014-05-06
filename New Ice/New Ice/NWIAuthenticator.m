//
//  NWIAuthenticator.m
//  New Ice
//
//  Created by Naphat Sanguansin on 4/23/14.
//
//

#import "NWIAppDelegate.h"
#import "NWIAuthenticationViewController.h"
#import "NWIAuthenticator.h"


@interface NWIAuthenticator ()

@property (nonatomic, strong) ShownBlock completion;
@property (nonatomic, weak) NSOperationQueue *authenticationQueue;

@end

@implementation NWIAuthenticator

-(id)init
{
    self = [super init];
    if (self) {
        self.netid = [[NSUserDefaults standardUserDefaults] stringForKey:@"netid"];
    }
    return self;
}

-(BOOL)authenticated
{
    return self.netid != nil;
}

-(void)showAuthenticationViewIfNeededWithCompletionHandler:(ShownBlock)completion
{
    if (self.authenticated) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/verify", SERVER_URL]]];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *returnedValue = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        if (![returnedValue isEqualToString:@"1"] || error) {
            self.netid = nil;
            [self showAuthenticationViewIfNeededWithCompletionHandler:completion];
        } else {
            if (completion) {
                completion(NO);
            }
        }
        return;
    }
    
    NWIAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NWIAuthenticationViewController *authVC = [delegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"authentication"];
    authVC.authDelegate = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [delegate.window.rootViewController presentViewController:authVC animated:YES completion:nil];
    }];
    self.completion = completion;
    self.authenticationQueue = [NSOperationQueue currentQueue];
    NSLog(@"current queue is %@", self.authenticationQueue);
}

-(BOOL)authenticationViewController:(NWIAuthenticationViewController *)authVC didLoginWithUserName:(NSString *)userName
{
    NSLog(@"execution queue is %@", [NSOperationQueue currentQueue]);
    self.netid = userName;
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"netid"];
    [self.authenticationQueue addOperationWithBlock:^{
        if (self.completion) {
            self.completion(YES);
            self.completion = nil;
        }
    }];
    return YES;
}

@end
