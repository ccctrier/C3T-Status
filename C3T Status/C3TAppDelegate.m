//
//  C3TAppDelegate.m
//  C3T Status
//
//  Created by Oliver Leitzgen on 20.12.11.
//  Copyright (c) 2011 Chaos Computer Club Trier e. V. All rights reserved.
//

#import "C3TAppDelegate.h"
#import "Reachability.h"

@implementation C3TAppDelegate

@synthesize menuSeperator1;
@synthesize menuSeperator2;
@synthesize startUpMenuItem;
@synthesize notificationSoundMenuItem;
@synthesize userDefaults;
@synthesize triggerNotification;

@synthesize statusMenu, statusItem, statusImage, statusHighlightImage, mainLoopTimer, avAudioPlayer, audioPath, clubIsOnline, networkIsReachable, recheckTimer;

- (void) awakeFromNib 
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    statusImage = [NSImage imageNamed:@"led_gray"];
    statusHighlightImage = [NSImage imageNamed:@"led_blue"];
    
    audioPath = [[NSBundle mainBundle] pathForResource:@"notification" ofType:@"m4a"];
    NSURL* url = [NSURL fileURLWithPath:audioPath];
    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"C3T Status"];
    [statusItem setHighlightMode:YES];
    
    [statusMenu setAutoenablesItems:NO];
    [statusMenu setDelegate:self];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    triggerNotification = YES;
    
    #ifdef MAC_OS_X_VERSION_10_8
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    #endif
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification
{
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    [self setupNetworkCheck];
    [self isAppInLoginItems];
    [self isSoundActive];
        
    [self performSelector:@selector(checkStatus:)withObject:nil];
    mainLoopTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0
                                                     target: self
                                                   selector:@selector(checkStatus:)
                                                   userInfo: nil 
                                                    repeats:YES];
}

- (void) menuWillOpen:(NSMenu *)menu
{
    if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
        [startUpMenuItem setHidden: NO];
        [notificationSoundMenuItem setHidden: NO];
        [menuSeperator1 setHidden: NO];
        [menuSeperator2 setHidden: NO];
    } 
}

- (void) menuDidClose:(NSMenu *)menu
{
    if ([startUpMenuItem isHidden] == NO) {
        [startUpMenuItem setHidden: YES];
        [notificationSoundMenuItem setHidden: YES];
        [menuSeperator1 setHidden: YES];
        [menuSeperator2 setHidden: YES];
    }
}

- (void) triggerSoundNotification
{
    if ([self isSoundActive] && clubIsOnline) {
        [avAudioPlayer play];
    }
}

- (void) triggerGrowlNotification
{
    NSString *notification;
    NSString *message;
    
    if (clubIsOnline) {
        notification = @"Club ist online";
        message = NSLocalizedString(@"Club is online", @"");
    }
    else {
        notification = @"Club ist offline";
        message = NSLocalizedString(@"Club is offline", @"");
    }
    [GrowlApplicationBridge notifyWithTitle:@"C3T Status"
                                description:message
                            notificationName:notification
                                    iconData:nil 
                                    priority:0
                                    isSticky:NO
                                clickContext:notification];
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://c3t.de/club/?status"]];
}

- (void) deliverToNotificationCenter
{
    #ifdef MAC_OS_X_VERSION_10_8
    if (clubIsOnline) {

        NSUserNotification *esIstClub = [[NSUserNotification alloc] init];
        esIstClub.title = @"CCC Trier";
        esIstClub.subtitle = @"Es ist Club!";
        
        // NSUserNotification.soundName is not working in 10.8 (12A193i)
        //esIstClub.soundName = audioPath;
            
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:esIstClub];
        [self triggerSoundNotification];
    }
    else {
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    }
    #endif
}

- (void) switchClubStatusTo:(BOOL)status
{
    clubIsOnline = status;
    if(clubIsOnline) {
        [statusItem setImage:statusHighlightImage];
        [statusItem setAlternateImage:statusImage];
    }
    else {
        [statusItem setImage:statusImage];
        [statusItem setAlternateImage:statusHighlightImage];
    }
    
    if (networkIsReachable) {
        SInt32 OSXversionMajor, OSXversionMinor;
        if(Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) == noErr && Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) == noErr)
        {
            if (triggerNotification) {
                if(OSXversionMajor == 10 && OSXversionMinor >= 8)
                {
                    [self deliverToNotificationCenter];
                } else {
                    [self triggerGrowlNotification];
                    [self triggerSoundNotification];
                }
            }
        }
    }
}

- (IBAction) checkStatus:(id)sender
{ 
    if (networkIsReachable) {
        NSURL *flagURL = [NSURL URLWithString:@"http://c3t.de/club/flag.json"];
        NSURLRequest *request = [NSURLRequest requestWithURL:flagURL];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        if (receivedData == nil) {
            return;
        }
        
        id object = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&error];
        
        BOOL currentStatus = [[object valueForKey:@"status"] boolValue];
        
        if (currentStatus == NO) {
            triggerNotification = YES;
        }
        
        if (clubIsOnline != currentStatus || [[sender class] isSubclassOfClass:[NSMenuItem class]]) {
            [self switchClubStatusTo:currentStatus];
        } 
    }
    else {
        [self switchClubStatusTo:NO];
    }
}

- (IBAction)setLoginItem:(NSMenuItem *)sender 
{
    if (sender.state == NSOnState) {
        [self deleteAppFromLoginItem];
    }
    else if (sender.state == NSOffState) {
        [self addAppAsLoginItem];
    }
    [self isAppInLoginItems];
}

- (IBAction)setNotificationSound:(NSMenuItem *)sender {
     if (sender.state == NSOnState) {
         [userDefaults setBool:NO forKey:@"sound notification"];
     }
     else if (sender.state == NSOffState) {
        [userDefaults setBool:YES forKey:@"sound notification"];
     }
    [self isSoundActive];
}

- (BOOL) isSoundActive
{
    BOOL isActive = [userDefaults boolForKey:@"sound notification"];
    
    if (isActive) {
        notificationSoundMenuItem.state = NSOnState;
    } else {
        notificationSoundMenuItem.state = NSOffState;
    }
    
    return isActive;
}

- (BOOL) isAppInLoginItems
{
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		UInt32 seedValue;
		NSArray *loginItemsArray = (__bridge_transfer NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
                    startUpMenuItem.state = NSOnState;
                    return YES;
				}
			}
		}
	}
    startUpMenuItem.state = NSOffState;
    return NO;
}

- (void) addAppAsLoginItem 
{
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (__bridge_retained CFURLRef)[NSURL fileURLWithPath:appPath]; 

	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
	CFRelease(url);
}

- (void) deleteAppFromLoginItem 
{
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 

	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		UInt32 seedValue;
		NSArray  *loginItemsArray = (__bridge_transfer NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge_transfer NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

- (void) setupNetworkCheck
{
    Reachability * reach = [Reachability reachabilityWithHostname:@"c3t.de"];
    
    reach.reachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            networkIsReachable = YES;
            [self checkStatus:nil];
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            triggerNotification = NO;
            networkIsReachable = NO;
            if (recheckTimer.isValid) {
                [recheckTimer invalidate];
            }
            recheckTimer = [NSTimer scheduledTimerWithTimeInterval: 10
                                                            target: self 
                                                          selector:@selector(checkStatus:) 
                                                          userInfo: nil 
                                                           repeats: NO];
            
        });
    };
    [reach startNotifier];
}

- (BOOL) hasNetworkClientEntitlement
{
    return YES;
}

#ifdef MAC_OS_X_VERSION_10_8
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{    
    return YES;
}
#endif

@end
