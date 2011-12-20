//
//  C3TAppDelegate.m
//  C3T Status
//
//  Created by Oliver Leitzgen on 20.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"C3T Status"];
}

-(IBAction)pushedItem:(id)sender
{
    NSLog(@"hello");
}

@end
