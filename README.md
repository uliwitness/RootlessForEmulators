What is it
----------

A bit of sample code that demonstrates a quick-and-dirty way to implement a rootless mode for an emulator that has one huge back buffer in which it draws all its windows.

"Rootless" means that the emulated windows can be shown interleaved on the screen with platform-native window, like many commercial emulators and the Mac's Classic environment used to do it.


Design goals
------------

The design goal was to provide an easy way to hook in source code that assumes it has control over the machine. Your emulator's main function runs (renamed to EmulatorMain()) in its own thread and uses a few callbacks to talk to the actual Mac application framework. That way, its menus stay available even when the emulator itself hangs.

The emulator needs to register every rectangle that should show up as a window with this library. As such, this approach is not suitable for emulators that do not know what OS they run on, and you might have to hook into the host OS in some way to be notified when windows appear, are moved or go away.

It is intended as a demonstration of how it would work. As such, it currently only handles mouse events, though keyboard events could be implemented the same way.


What needs to be optimized?
---------------------------

Right now, back buffer updates are rather heavyweight, as is every API call. While it works and should be sufficiently fast for emulating older machines, one could speed it up significantly by using OpenGL directly and just uploading the pixel buffer to the screen. Maybe even use shared GPU memory for the back buffer and support partial updates only of changed areas. Similarly, the inter-thread communication could be rewritten in lower-level code, as we're really only sending across four numbers.


License
-------

Note: Some submodules may be subject to different licenses.

	Copyright 2003-2014 by Uli Kusterer.
	
	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.
	
	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:
	
	   1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	
	   2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	
	   3. This notice may not be removed or altered from any source
	   distribution.
