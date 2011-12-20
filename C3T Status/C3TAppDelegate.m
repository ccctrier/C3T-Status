//
//  C3TAppDelegate.m
//  C3T Status
//
//  Created by Oliver Leitzgen on 20.12.11.
//  Copyright (c) 2011 Chaos Computer Club Trier e. V. All rights reserved.
//

#import "C3TAppDelegate.h"

@implementation C3TAppDelegate

@synthesize statusMenu, statusItem, statusImage, statusHighlightImage, mainLoopTimer, clubIsOnline;

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
    
    [self performSelector:@selector(checkStatus:)withObject:nil];
    mainLoopTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0
                                                     target: self
                                                   selector:@selector(checkStatus:)
                                                   userInfo: nil 
                                                    repeats:YES];
}

- (void) triggerGrowlNotification
{
    NSString *notification;
    NSString *message;
    
    if (clubIsOnline) {
        notification = @"Club ist online";
        message = @"Es ist Club!";
    }
    else {
        notification = @"Club ist offline";
        message = @"Der Club ist offline!";
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
    [self triggerGrowlNotification];
}

- (IBAction) checkStatus:(id)sender
{ 
    NSURL *flagURL = [NSURL URLWithString:@"http://c3t.de/club/flag.xml"];
    NSURLRequest *request = [NSURLRequest requestWithURL:flagURL];

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    
    NSXMLDocument *xmlDoc;
    xmlDoc = [[NSXMLDocument alloc] initWithData:receivedData options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&error];
    
    NSXMLNode *statusEntry = [[[xmlDoc rootElement] children] objectAtIndex:0];
    
    BOOL currentStatus = [[statusEntry stringValue] boolValue];
    
    if (clubIsOnline != currentStatus || [[sender class] isSubclassOfClass:[NSMenuItem class]]) {
        [self switchClubStatusTo:currentStatus];
    }
}

@end
