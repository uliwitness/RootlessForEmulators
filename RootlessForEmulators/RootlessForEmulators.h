//
//  RootlessForEmulators.h
//  RootlessForEmulators
//
//  Created by Uli Kusterer on 08/03/15.
//  Copyright (c) 2015 Uli Kusterer. All rights reserved.
//


#include <stdbool.h>


typedef void*	RootlessWindow;

RootlessWindow	CreateWindowWithRect( int x, int y, int width, int height );
void			SetWindowRect( RootlessWindow win, int x, int y, int width, int height );
void			FreeWindow( RootlessWindow win );

void			BackBufferChanged( void* data, int rowBytes, int width, int height );	// Pixel data assumed to be 32-bit RGBA. Could be sth. else, just seemed like a useful choice.
bool			QueryInputDevices( int *outButtonDown, int *outX, int *outY );
void			GetScreenSize( int *outWidth, int *outHeight );


int				EmulatorMain( int argc, const char** argv );	// This is what you implement.