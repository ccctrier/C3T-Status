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
<NSApplicationDelegate, GrowlApplicationBridgeDelegate, NSUserNotificationCenterDelegate>
#else
<NSApplicationDelegate, GrowlApplicationBridgeDelegate>
#endif


@property (weak)    IBOutlet NSMenu     *statusMenu;
@property (weak)    IBOutlet NSMenuItem *startUpMenuItem;
@property (strong)  NSStatusItem        *statusItem;
@property (strong)  NSImage             *statusImage;
@property (strong)  NSImage             *statusHighlightImage;
@property (strong)  NSTimer             *mainLoopTimer;   
@property (strong)  AVAudioPlayer       *avAudioPlayer;
@property (strong)  NSString            *audioPath;
@property           BOOL                clubIsOnline;

- (IBAction) checkStatus:(id)sender;
- (IBAction)setLoginItem:(NSMenuItem *)sender;
- (BOOL) isAppInLoginItems;
- (void) addAppAsLoginItem;
- (void) deleteAppFromLoginItem;

@end
