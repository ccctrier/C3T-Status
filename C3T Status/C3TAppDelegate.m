//
//  C3TAppDelegate.m
//  C3T Status
//
//  Created by Oliver Leitzgen on 20.12.11.
//  Copyright (c) 2011 Chaos Computer Club Trier e. V. All rights reserved.
//

#import "C3TAppDelegate.h"

@implementation C3TAppDelegate

@synthesize statusMenu, statusItem, statusImage, statusHighlightImage;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void) awakeFromNib 
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    statusImage = [NSImage imageNamed:@"led_gray.png"];
    statusHighlightImage = [NSImage imageNamed:@"led_blue.png"];
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"C3T Status"];
    [statusItem setHighlightMode:YES];
    
    [GrowlApplicationBridge setGrowlDelegate:self];  
}

-(IBAction)pushedItem:(id)sender
{
    NSLog(@"hello");
    [GrowlApplicationBridge notifyWithTitle:@"C3T Status"
                                description:@"Es ist Club!"
                            notificationName:@"Club is online"
                                    iconData:nil 
                                    priority:0
                                    isSticky:NO
                                clickContext:@"clicked"];
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    NSLog(@"%@", clickContext);
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://c3t.de/club/?status"]];
}

- (void)growlNotificationTimedOut:(id)clickContext
{
    NSLog(@"timeout");
}

@end
