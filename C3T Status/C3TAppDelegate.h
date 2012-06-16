//
//  C3TAppDelegate.h
//  C3T Status
//
//  Created by Oliver Leitzgen on 20.12.11.
//  Copyright (c) 2011 Chaos Computer Club Trier e. V. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <Growl/Growl.h>

@interface C3TAppDelegate : NSObject
#ifdef MAC_OS_X_VERSION_10_8
<NSApplicationDelegate, GrowlApplicationBridgeDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate>
#else
<NSApplicationDelegate, GrowlApplicationBridgeDelegate, NSMenuDelegate>
#endif


@property (weak) IBOutlet NSMenu        *statusMenu;
@property (weak) IBOutlet NSMenuItem    *startUpMenuItem;
@property (weak) IBOutlet NSMenuItem    *notificationSoundMenuItem;
@property (weak) IBOutlet NSMenuItem    *menuSeperator1;
@property (weak) IBOutlet NSMenuItem    *menuSeperator2;
@property (strong)  NSStatusItem        *statusItem;
@property (strong)  NSImage             *statusImage;
@property (strong)  NSImage             *statusHighlightImage;
@property (strong)  NSTimer             *mainLoopTimer;   
@property (strong)  AVAudioPlayer       *avAudioPlayer;
@property (strong)  NSString            *audioPath;
@property (strong)  NSUserDefaults      *userDefaults;
@property           BOOL                clubIsOnline;
@property           BOOL                networkIsReachable;
@property           BOOL                triggerNotification;
@property (strong)  NSTimer             *recheckTimer;


- (IBAction)    checkStatus:(id)sender;
- (IBAction)    setLoginItem:(NSMenuItem *)sender;
- (IBAction)    setNotificationSound:(NSMenuItem *)sender;
- (BOOL)        isSoundActive;
- (BOOL)        isAppInLoginItems;
- (void)        addAppAsLoginItem;
- (void)        deleteAppFromLoginItem;

@end
