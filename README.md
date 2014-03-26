AKSystemSound
=============

Simplifies playing caf audio files using AudioServicesPlaySystemSound.
Audio files can also be scheduled to be played with a specified interval.


## Features of this fork

The main feature is that the project is translated to ARC.

### Methods are added

+ Returns YES if any sound that was passed to this class is playing now.

````objective-c
[AKSystemSound isAnySoundPlaying];
````

+ Stop playing on deallocation of corresponding object (unscheduled if was):

````objective-c
[AKSystemSound freeSoundWithName:@"ping"];
````

Usage
=====

AKSystemSound uses the AudioServices API to play short alert sounds.
These audio files have to be in the CAF-format.


+ convert files to CAF using afconvert

````
afconvert -f caff -d LEI16 [input] out.caf
````

+ play once

````objective-c
[[AKSystemSound soundWithName:@"ping"] play];
````

+ schedule repeated playback

````objective-c
soundID = [[AKSystemSound soundWithName:@"ping"] scheduleRepeatWithInterval:5];
````

+ schedule playback in delta time

````objective-c
soundID = [[AKSystemSound soundWithName:@"ping"] schedulePlayInInterval:5];
````

+ schedule playback at specified date

````objective-c
soundID = [[AKSystemSound soundWithName:@"ping"] schedulePlayAtDate:date];
````

+ unschedule

````objective-c
[AKSystemSound unscheduleSoundID:soundID];
soundID = AKSystemSoundInvalidID;
````

Notifications
=============

+ AKSystemSoundsWillPlay-/AKSystemSoundsDidPlayNotification
Sent before and after a set of sounds are played.
Good to have if you have any other audio playback (AudioQueue etc)
and need to temporarily lower the output volume from that.

+ AKSystemSoundWillPlay-/AKSystemSoundDidPlayNotification
Sent before and after each sound is played.

Licence
=======

Public domain, free use.
Created by Anton Kiland 2011
anton@kiland.se