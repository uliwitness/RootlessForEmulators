//
//  AppDelegate.h
//  RootlessForEmulators
//
//  Created by Uli Kusterer on 08/03/15.
//  Copyright (c) 2015 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>

-(void)		addEvent: (NSEvent*)evt;
-(NSEvent*)	dequeueNextEvent;

@end

