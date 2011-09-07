/*
	AKSystemSound

	Simplifies playing caf audio files using AudioServicesPlaySystemSound.
	Audio files can also be scheduled to be played with a specified interval.

	Convert files to caf using afconvert:
	afconvert -f caff -d LEI16 [input] out.caf

	Usage
	Play once:
	[[AKSystemSound soundWithName:@"ping"] play];

	Schedule repeated playback:
	soundID = [[AKSystemSound soundWithName:@"ping"] scheduleRepeatWithInterval:5];
	
	Schedule playback in delta time:
	soundID = [[AKSystemSound soundWithName:@"ping"] schedulePlayInInterval:5];
	
	Schedule playback at specified date:
	soundID = [[AKSystemSound soundWithName:@"ping"] schedulePlayAtDate:date];

	Unschedule:
	[AKSystemSound unscheduleSoundID:soundID];
	soundID = AKSystemSoundInvalidID;

	AKSystemSoundsWillPlay-/AKSystemSoundsDidPlayNotification
	Sent before and after a set of sounds are played.
	Good to have if you have any other audio playback (AudioQueue etc)
	and need to temporarily lower the output volume from that.

	AKSystemSoundWillPlay-/AKSystemSoundDidPlayNotification
	Sent before and after each sound is played.


	Public domain, free use.
	Created by Anton Kiland 2011
	anton@kiland.se
*/

#import <AudioToolbox/AudioToolbox.h>

// sent before and after a set of sounds
extern NSString *const AKSystemSoundsWillPlayNotification;
extern NSString *const AKSystemSoundsDidPlayNotification;

// sent before and after each sound
extern NSString *const AKSystemSoundWillPlayNotification;
extern NSString *const AKSystemSoundDidPlayNotification;

enum {
	AKSystemSoundInvalidID = 0
};
typedef NSInteger AKSystemSoundID;	

@interface AKSystemSound : NSObject
{
	SystemSoundID		_soundID;
	unsigned int		_playing;
}

// initialize a system sound without caching it
- (id)initWithName:(NSString*)name;
- (id)initWithPath:(NSString*)path;

// play the sound manually once
- (void)play;

// schedule a repeated playback with interval seconds
- (AKSystemSoundID)scheduleRepeatWithInterval:(NSTimeInterval)interval;
// schedule sound to be played in delta seconds
- (AKSystemSoundID)schedulePlayInInterval:(NSTimeInterval)delta;
// schedule sound to be played at date
- (AKSystemSoundID)schedulePlayAtDate:(NSDate*)date;
// unschedule soundID returned from -schedule...
+ (void)unscheduleSoundID:(AKSystemSoundID)soundID;

// initializes a system sound and caches it
+ (AKSystemSound*)soundWithName:(NSString*)name;

@end