/***********************************************************************
 
 Copyright (c) 2008, Memo Akten, www.memo.tv
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 ***********************************************************************/


#import "MSAQTPlayer.h"


@implementation MSAQTPlayer

- (id) init {
	if(self = [super init])	[self setDelegate:self];
	
	window					= NULL;
	movie					= NULL;
	viewer					= NULL;
	stretchToFullScreen		= false;
	
	memset(&screenRect, 0, sizeof(screenRect));
	memset(&movieRect, 0, sizeof(movieRect));	
	
	return self;
}


-(void) cleanUp {
	if(movie)	[movie release];
	if(viewer)	[viewer release];
	if(window)	[window release];
}


- (void) playMovie {
	[viewer play:self];
}

- (void) pauseMovie {
	[viewer pause:self];
}

- (void) togglePlay {
	if([movie rate]!=0) [self pauseMovie];
	else [self playMovie];
}

- (void) toggleMute {
	[movie setMuted:![movie muted]];
}

- (void) setFullscreen:(bool) s {
	stretchToFullScreen = s;
	if(stretchToFullScreen) [window setFrame:screenRect display:YES];
	else [window setFrame:movieRect display:YES];
}

- (void) setInFront:(bool) f {
	inFront = f;
	if(inFront) [window setLevel:NSScreenSaverWindowLevel];	
	else [window setLevel:NSNormalWindowLevel];
}


- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {
	NSLog(@"applicationDidFinishLaunching\n");
	
	// load preferences
	NSDictionary*	prefs		= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"preferences.plist" ofType:NULL]];

	stretchToFullScreen			= [[prefs objectForKey:@"Stretch to fullscreen"] boolValue];
	inFront						= [[prefs objectForKey:@"Start in front"] boolValue];
	NSString*		path		= [prefs objectForKey:@"Path"];
	BOOL			autoPlay	= [[prefs objectForKey:@"Autoplay"] boolValue];
	BOOL			loop		= [[prefs objectForKey:@"Loop"] boolValue];
	
	
	// if path is not absolute, make it relative to the app bundle
	if([path isAbsolutePath] == false) path = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:path];
	
	// check quicktime file
	if([QTMovie canInitWithFile:path] == false) {
		NSLog(@"File %@ CANNOT be used for initialization\n", path);
		[self cleanUp];
		exit(1);
	}
	NSLog(@"CAN init with file: %@\n", path);	
	
	// load quicktime file
	movie = [[QTMovie alloc] initWithFile:path error:NULL];
	if(movie == NULL) {
		NSLog(@"File %@ could not be loaded\n", path);
		[self cleanUp];
		exit(1);
	}
	NSLog(@"Loaded file: %@\n", path);	

	
	// get screen size
	for(id screen in [NSScreen screens]) {
		NSRect curRect = [screen frame];
		screenRect.size.width += curRect.size.width;
	}
	screenRect.size.height = [[NSScreen mainScreen] frame].size.height;
	
	// create and set window
	window = [[NSWindow alloc] initWithContentRect:movieRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreNonretained defer:NO];
	[window setOpaque:YES];
	[window setBackgroundColor:[NSColor clearColor]]; 
	[window setIgnoresMouseEvents:FALSE];
	[window setAcceptsMouseMovedEvents:YES];
	[window makeKeyAndOrderFront:nil];
		
	// set movie properties
	[movie setAttribute:QTMovieApertureModeClean forKey:QTMovieApertureModeAttribute];
	[movie setAttribute:[NSNumber numberWithBool:loop] forKey:QTMovieLoopsAttribute];
	NSTimeInterval duration;
	QTGetTimeInterval([movie duration], &duration);
	incTime			= QTMakeTimeWithTimeInterval(duration/10);
	
	id videoTrack = [[movie tracksOfMediaType:QTMediaTypeVideo] objectAtIndex:0];
	movieRect.size = movieRect.size = [videoTrack apertureModeDimensionsForMode:QTMovieApertureModeClean];
	movieRect.origin.y = screenRect.size.height - movieRect.size.height;
	
	// set viewer
	viewer = [[QTMovieView alloc] initWithFrame:movieRect];
	[viewer setMovie:movie];
	[viewer setControllerVisible:NO];
	[viewer setBackButtonVisible:YES];
	[viewer setStepButtonsVisible:YES];
	[viewer setTranslateButtonVisible:YES];
	[viewer setVolumeButtonVisible:YES];
	[viewer setZoomButtonsVisible:YES];
	
	[window setContentView:viewer];
	[window setInitialFirstResponder:viewer];
	//	movieRect.size.height += [viewer controllerBarHeight];
	//	[window setFrame:movieRect display:YES];
	
	[self setFullscreen:stretchToFullScreen];
	[self setInFront:inFront];
	
	if(autoPlay) [self playMovie];
	
	[NSCursor hide];
}

- (void) mouseMoved:(NSEvent *)event {
	NSPoint 	mouseLoc = [window convertScreenToBase:[NSEvent mouseLocation]];
	NSLog(@"mouseMoved\n");
	
	[NSCursor hide];
	
	if (mouseLoc.x < 0)
		[NSCursor unhide];
	else if (mouseLoc.x > [window frame].size.width)
		[NSCursor unhide];
	
	if (mouseLoc.y < 0)
		[NSCursor unhide];
	else if (mouseLoc.y > [window frame].size.height)
		[NSCursor unhide];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
	NSLog(@"applicationDidBecomeActive\n");
	[NSCursor hide];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
	NSLog(@"applicationDidResignActive\n");
	[NSCursor unhide];
}


- (void) sendEvent:(NSEvent*)event {
	if([event type] == NSKeyDown) {
		int key = [event keyCode];
		float volume = [movie volume];
		switch(key) {
			case 0x35:			// esc
				[NSApp terminate:nil];
				break;
			case 3:				//f
				[self setInFront:!inFront];
				break;
			case 1:				//s
				[self setFullscreen:!stretchToFullScreen];
				break;
				
			case 33:			// [
				[movie setCurrentTime: QTTimeDecrement([movie currentTime], incTime)];
				break;
			case 30:
				[movie setCurrentTime: QTTimeIncrement([movie currentTime], incTime)];
				break;			// ]
				
				
			case 38:			//j
				[movie setRate:([movie rate]-1)];
				break;
			case 40:			// k
				[self pauseMovie];
				break;
			case 37:			// l
				[movie setRate:[movie rate]+1];
				break;
			case 46:			// m
				[self toggleMute];
				break;
			case 49:			// space
				[self togglePlay];
				break;
				
			case 115:			// home
				[viewer gotoBeginning:self];
				break;
				
			case 119:			// end
				[viewer gotoEnd:self];
				break;
				
			case 126:			// up
				[movie setMuted:NO];
				if(volume<1) [movie setVolume:volume + 0.02];
				break;
			case 125:			// down 
				[movie setMuted:NO];
				[movie setVolume:volume - 0.02];
				break;
				
			case 116:			// pgup
				[viewer gotoPreviousSelectionPoint:self];
				break;
			case 117:			// pgdn
				[viewer gotoNextSelectionPoint:self];
				break;
			case 123:			// left
				[viewer stepBackward:self];
				break;
			case 124:			// right
				[viewer stepForward:self];
				break;
		}
		NSLog(@"key: %i\n", key);
		//		NSLog(@"Volume: %.3f\n", volume);
		
		//		NSLog(@"characters: %@\n", [event characters]);
		//		NSLog(@"rate: %.2f\n", [movie rate]);
	}
}


- (void) applicationWillTerminate:(NSNotification*)aNotification {
	NSLog(@"applicationWillTerminate: goodbye!\n");
	[self cleanUp];
}

@end
