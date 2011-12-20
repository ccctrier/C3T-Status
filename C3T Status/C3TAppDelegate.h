//
//  C3TAppDelegate.h
//  C3T Status
//
//  Created by Oliver Leitzgen on 20.12.11.
//  Copyright (c) 2011 Chaos Computer Club Trier e. V. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface C3TAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate>

@property (weak)    IBOutlet NSMenu     *statusMenu;
@property (strong)  NSStatusItem        *statusItem;
@property (strong)  NSImage             *statusImage;
@property (strong)  NSImage             *statusHighlightImage;

-(IBAction)pushedItem:(id)sender;

@end
