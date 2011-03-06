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

Super simple fullscreen / multiple output Quicktime player with fast, greater-than-4096-pixels support.

I wrote this app for an installation because I needed to play a 4,800 x 600 Quicktime file across 2 outputs on my graphics card, each feeding 3 triple heads to go into 6 projectors, and I couldn't find a single application that could do it.

Most video applications which can output across multiple video-outs cannot play files larger than the maximum size of a texture (usually 4096 pixels). And even if the movie resolution fits in a texture, they are very slow because they convert each frame to a texture and upload to the graphics card. The only application I found which could play a large file is Quicktime Pro, but that cannot output across multiple video-outs. 

This is a native Cocoa app which can do this (using QTKit and OSX 10.5) .

Assumes a simple physical screen layout - all screens are side by side and same height. 

-----------------

MODES

The app has a 'Stretch to fullscreen' mode (toggle with 's' key), which simply stretches the video to cover the entire desktop area. If you have 3 monitors / projectors this will stretch across all 3 monitors / projectors. It doesn't preserve aspect-ratio, will add that later.

It also has a 'in Front' mode (toggle with the 'f' key). This brings the player window to the front of everything (including the dock and menubar). 

For my installation I didn't need the 'stretch' option, just set my two output resolutions to 2400x600 (3 x 800 x 600) giving a combined desktop size of 4800x600 and output straight to all 6 projectors with a 1:1 pixel mapping for best quality. The app was in 'front' mode, to cover the dock and menubar.


-----------------

STARTUP SETTINGS

There is a 'preferences.plist' in the application bundle (right click on the MSAQTPlayer.app and select 'Show package contents', then navigate to contents >> Resources >> preferences.plist).

Double-clicking on this file should open it up with your default plist editor. If you do not have one installed you can either download one, or edit it with Text Edit - it will be ugly, but will still work.

Under Path, you can enter an absolute or relative (to the MSAQTPlayer.app) path. The default is mymovie.mov. If the movie is not found the app will just quit (see the system console for messages).

Stretch to fullscreen, Start in front, and Autoplay are all pretty self-explanatory. If you have a WYSIWYG plist editor they will appear as checkboxes, otherwise you need to type in true or false underneath them.

Save and close the file, next time the app runs it will use those settings.


-----------------

KEYS

esc			- quit
f			- toggle 'in Front' mode
s			- toggle 'Stretch to fullscreen'
space		- toggle play
j, k,l			- control playback rate: slowdown (and play backwards) / stop / speed up (and play forwards)
home, end	- goto beginning / end
left, right		- frame advance back / forward
[ ]			- seek backward / forward 1/10th of the movie
pgup, pgdn	- goto previous / next chapter
m			- toggle Mute
up, down		- change volume



** WARNING **
If the app crashes while in 'front' mode, it might be a bit hard to get back to your desktop. So make sure your file works first while in normal mode, then you can set it to be in front.