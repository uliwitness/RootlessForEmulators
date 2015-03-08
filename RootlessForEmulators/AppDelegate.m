//
//  AppDelegate.m
//  RootlessForEmulators
//
//  Created by Uli Kusterer on 08/03/15.
//  Copyright (c) 2015 Uli Kusterer. All rights reserved.
//

#import "AppDelegate.h"
#import "RootlessForEmulators.h"


@interface AppDelegate ()

@property (nonatomic, strong) NSImage*			backBuffer;
@property (strong) NSMutableArray*				windows;
@property (strong) NSMutableArray*				events;

@end


@interface RootlessWindowContentView : NSView

@end


@implementation RootlessWindowContentView

-(void)	drawRect:(NSRect)dirtyRect
{
	NSImage	*bb = [(id)NSApplication.sharedApplication.delegate backBuffer];
	NSRect	myBox = [self.window contentRectForFrameRect: self.window.frame];
	[bb drawAtPoint: NSZeroPoint fromRect: myBox operation: NSCompositeCopy fraction: 1.0];
}


-(void)	mouseDown:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	mouseDragged:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	mouseUp:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	rightMouseDown:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	rightMouseDragged:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	rightMouseUp:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	otherMouseDown:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	otherMouseDragged:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	otherMouseUp:(NSEvent *)theEvent
{
	[(id)NSApplication.sharedApplication.delegate addEvent: theEvent];
}


-(void)	windowDidMove: (NSNotification*)notif
{
	[self setNeedsDisplay: YES];
}


-(void)	viewDidMoveToWindow
{
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowDidMove:) name: NSWindowDidMoveNotification object: self.window];
}

@end


@interface RootlessWindowAndFrame : NSObject
{
	NSRect		mFrame;
	NSWindow*	mWindow;
}

-(id)	initWithWindow: (NSWindow*)wd frame: (NSRect)box;

-(NSRect)		frame;
-(NSWindow*)	window;
-(void)			setWindow: (NSWindow*)wd;

@end


@implementation RootlessWindowAndFrame

-(id)	initWithWindow: (NSWindow*)wd frame: (NSRect)box
{
	self = [super init];
	if( self )
	{
		mWindow = wd;
		mFrame = box;
	}
	return self;
}

-(NSRect)		frame
{
	return mFrame;
}


-(NSWindow*)	window
{
	return mWindow;
}


-(void)	setWindow: (NSWindow*)wd
{
	mWindow = wd;
}

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSRect		backBufferBox = { NSZeroPoint, [NSScreen.screens.firstObject frame].size };
	self.backBuffer = [[NSImage alloc] initWithSize: backBufferBox.size];
	
	[self.backBuffer lockFocus];
		[NSColor.blackColor set];
		NSRectFillUsingOperation( backBufferBox, NSCompositeCopy );
	[self.backBuffer unlockFocus];
	
	self.windows = [[NSMutableArray alloc] init];
	self.events = [[NSMutableArray alloc] init];
	
	[NSApplication.sharedApplication setPresentationOptions: NSApplicationPresentationAutoHideDock | NSApplicationPresentationAutoHideMenuBar];
	
	[NSThread detachNewThreadSelector: @selector(emulatorMain) toTarget: self withObject: nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// Insert code here to tear down your application
}


-(void)	emulatorMain
{
	NSArray*	args = [NSProcessInfo processInfo].arguments;
	NSInteger	numArgs = args.count;
	char*		emulatorArgs[numArgs];
	
	// First build a buffer with all C strings in it and
	//	fill the array with their *offsets* in the data as
	//	the pointers could change every time we append more data.
	NSMutableData*	stringData = [NSMutableData data];
	NSInteger		idx = 0;
	NSInteger		offset  = 0;
	for( NSString* currArg in args )
	{
		uint8_t		zeroByte = 0;
		emulatorArgs[idx] = (char*)offset;
		NSData*		currCStr = [currArg dataUsingEncoding: NSUTF8StringEncoding];
		[stringData appendBytes: currCStr.bytes length: currCStr.length];
		[stringData appendBytes: &zeroByte length: 1];
		offset += currCStr.length +1;
		idx++;
	}
	
	// Now that the strings array is stable, turn the offsets into pointers:
	char*	firstPointer = (char*)[stringData bytes];
	for( int x = 0; x < numArgs; x++ )
	{
		emulatorArgs[x] += (intptr_t)firstPointer;
	}
	
	EmulatorMain( numArgs, emulatorArgs );
	
	[NSApplication.sharedApplication performSelectorOnMainThread: @selector(terminate:) withObject: nil waitUntilDone: NO];
}


-(void)	addWindow: (RootlessWindowAndFrame*)waf
{
	NSWindow*	theWindow = [[NSWindow alloc] initWithContentRect: waf.frame styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered defer: NO];
	theWindow.releasedWhenClosed = NO;
	theWindow.opaque = NO;
	
	[theWindow setContentView: [[RootlessWindowContentView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)]];
	
	[self.windows addObject: theWindow];
	[theWindow makeKeyAndOrderFront: self];
	
	waf.window = theWindow;
}


-(void)	moveWindow: (RootlessWindowAndFrame*)waf
{
	[waf.window setFrame: [waf.window frameRectForContentRect: waf.frame] display: YES];
}


-(void)	removeWindow: (NSWindow*)theWindow
{
	[theWindow close];
	[self.windows removeObject: theWindow];
}


-(void)	setBackBuffer: (NSImage *)backBuffer
{
	self->_backBuffer = backBuffer;
	for( NSWindow* aWindow in self.windows )
		[aWindow.contentView setNeedsDisplay: YES];
}


-(void)	addEvent: (NSEvent*)evt
{
	@synchronized( self )
	{
		[self.events addObject: evt];
	}
}


-(NSEvent*)	dequeueNextEvent
{
	NSEvent*	evt = nil;
	@synchronized( self )
	{
		evt = self.events.firstObject;
		if( evt )
			[self.events removeObjectAtIndex: 0];
	}
	return evt;
}

@end


RootlessWindow	CreateWindowWithRect( int x, int y, int width, int height )
{
	RootlessWindowAndFrame	*	waf = [[RootlessWindowAndFrame alloc] initWithWindow: nil frame: NSMakeRect(x, y, width, height)];
	
	[(id)NSApplication.sharedApplication.delegate performSelectorOnMainThread: @selector(addWindow:) withObject: waf waitUntilDone: YES];
	
	return (__bridge RootlessWindow)waf.window;
}


void	SetWindowRect( RootlessWindow win, int x, int y, int width, int height )
{
	RootlessWindowAndFrame	*	waf = [[RootlessWindowAndFrame alloc] initWithWindow: (__bridge NSWindow*)win frame: NSMakeRect(x, y, width, height)];
	
	[(id)NSApplication.sharedApplication.delegate performSelectorOnMainThread: @selector(moveWindow:) withObject: waf waitUntilDone: YES];
}


void	FreeWindow( RootlessWindow win )
{
	[(id)NSApplication.sharedApplication.delegate performSelectorOnMainThread: @selector(removeWindow:) withObject: (__bridge NSWindow*)win waitUntilDone: YES];
}


void	BackBufferChanged( void* data, int rowBytes, int width, int height )
{
	NSImage*			newBackBuffer = [[NSImage alloc] initWithSize: NSMakeSize(width, height)];
	unsigned char*		pixels[4] = { data, NULL, NULL, NULL };
	NSBitmapImageRep*	bir = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: pixels pixelsWide:width pixelsHigh: height bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar: NO colorSpaceName:NSCalibratedRGBColorSpace bitmapFormat: NS32BitLittleEndianBitmapFormat bytesPerRow: rowBytes bitsPerPixel: 32];
	[newBackBuffer addRepresentation: bir];
	[(id)NSApplication.sharedApplication.delegate performSelectorOnMainThread: @selector(setBackBuffer:) withObject: newBackBuffer waitUntilDone: YES];
}


bool	QueryInputDevices( int *outButtonDown, int *outX, int *outY )
{
	NSEvent*	evt = [(id)NSApplication.sharedApplication.delegate dequeueNextEvent];
	if( !evt )
	{
		return false;
	}
	
	if( evt.type == NSLeftMouseDown || evt.type == NSLeftMouseUp || evt.type == NSLeftMouseDragged
		|| evt.type == NSRightMouseDown || evt.type == NSRightMouseUp || evt.type == NSRightMouseDragged
		|| evt.type == NSOtherMouseDown || evt.type == NSOtherMouseUp || evt.type == NSOtherMouseDragged )
	{
		*outButtonDown = (int)evt.buttonNumber;
		NSPoint		pos = evt.locationInWindow;
		pos.x += evt.window.frame.origin.x;
		pos.y += evt.window.frame.origin.y;
		*outX = pos.x;
		*outY = pos.y;
	}
	
	return true;
}


void	GetScreenSize( int *outWidth, int *outHeight )
{
	NSScreen*	currScreen = NSScreen.screens.firstObject;
	*outWidth = currScreen.frame.size.width;
	*outHeight = currScreen.frame.size.height;
}


