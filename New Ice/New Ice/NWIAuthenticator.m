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
@property (nonatomic, strong) NSString *netid;
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

-(void)showAuthenticationViewIfNeeded
{
    if (self.authenticated) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/verify"]];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *returnedValue = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        if (![returnedValue isEqualToString:@"1"] || error) {
            self.netid = nil;
            [self showAuthenticationViewIfNeeded];
        }
        return;
    }
    
    NWIAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NWIAuthenticationViewController *authVC = [delegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"authentication"];
    authVC.authDelegate = self;
    [delegate.window.rootViewController presentViewController:authVC animated:YES completion:nil];
}

-(BOOL)authenticationViewController:(NWIAuthenticationViewController *)authVC didLoginWithUserName:(NSString *)userName
{
    self.netid = userName;
    [[NSUserDefaults standardUserDefaults] setObject:self.netid forKey:@"netid"];
    return YES;
}

@end
