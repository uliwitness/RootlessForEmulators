//
//  EmulatorMain.c
//  RootlessForEmulators
//
//  Created by Uli Kusterer on 08/03/15.
//  Copyright (c) 2015 Uli Kusterer. All rights reserved.
//

#include "RootlessForEmulators.h"
#include <stdio.h>
#include <memory.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>


int	EmulatorMain( int argc, const char** argv )
{
	// We get all command-line arguments (note that MacOS X adds its own arguments when launching GUI apps, so be prepared for unknown args):
	for( int x = 0; x < argc; x++ )
	{
		printf( "%s ", argv[x] );
	}
	
	printf("\n");
	
	// Create a back buffer:
	int	screenWidth = 1024, screenHeight = 768;
	GetScreenSize( &screenWidth, &screenHeight );
	
	uint32_t*	backBuffer = malloc(screenWidth * screenHeight * 4);
	for( int x = 0; x < (screenWidth * screenHeight); x++ )
		backBuffer[x] = 0xFF0000FF;	// Red with 100% alpha.
	BackBufferChanged( backBuffer, screenWidth * 4, screenWidth, screenHeight );	// And tell the rootless code to load it. You do that every time something changes.
	
	// Everything that should show up as a window should be registered using this call:
	RootlessWindow wd = CreateWindowWithRect( 100, 100, 512, 342 );
	// SetWindowRect(wd,150,100,512,342);	// Move a window.
	
	// Now process events coming in (We just loop until you click the right mouse button in a window):
	while( true )
	{
		int	buttonDown, x, y;
		if( QueryInputDevices( &buttonDown, &x, &y ) && buttonDown == 1 )
		{
			break;
		}
	}
	
	FreeWindow(wd);	// Get rid of a window.
	
	return 0;
}