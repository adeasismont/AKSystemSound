/*
	AKSystemSound

	Simplifies playing caf audio files using AudioServicesPlaySystemSound.
	Audio files can also be scheduled to be played with a specified interval.

	Convert files to caf using afconvert:
	afconvert -f caff -d LEI16 [input] out.caf

    Requires ARC
    For backward compatability use -fobjc-arc compiler flag on AKSystemSound.m .
 
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

    Unschedule, and stop playing on deallocation of corresponding object:
    [AKSystemSound freeSoundWithName:@"ping"];

	AKSystemSoundsWillPlay-/AKSystemSoundsDidPlayNotification
	Sent before and after a set of sounds are played.
	Good to have if you have any other audio playback (AudioQueue etc)
	and need to temporarily lower the output volume from that.

	AKSystemSoundWillPlay-/AKSystemSoundDidPlayNotification
	Sent before and after each sound is played.
 

	Public domain, free use.
	Created by Anton Kiland 2011
	anton@kiland.se
 
    Portions by Ivan Rublev 2013
    ivan@ivanrublev.me
*/

#import <AudioToolbox/AudioToolbox.h>

// sent before and after a set of sounds
extern NSString *const AKSystemSoundsWillPlayNotification;
extern NSString *const AKSystemSoundsDidPlayNotification;

// sent before and after each sound
extern NSString *const AKSystemSoundWillPlayNotification;
extern NSString *const AKSystemSoundDidPlayNotification;

enum : SystemSoundID {
	AKSystemSoundInvalidID = 0
};
typedef NSInteger AKSystemSoundID;	

typedef enum eAKSystemSoundPlayFunction : NSUInteger {
    AKSystemSoundPlayFunctionSystem = 0, // just sound
    AKSystemSoundPlayFunctionAlert       // sound with system loudness and vibration
} AKSystemSoundPlayFunction;

// debug
#define AKSystemSoundLogError NSLog
#define AKSystemSoundLogDebug NSLog
//#define AKSystemSoundLogDeallocations 1

@interface AKSystemSound : NSObject
{
	SystemSoundID		_soundID;
	unsigned int		_playing;
}

// initialize a system sound without caching it
- (id)initWithName:(NSString*)name;
- (id)initWithPath:(NSString*)path;

// set type of play function
@property (nonatomic, assign) AKSystemSoundPlayFunction playFunction;
// returns self with vibration function set for playing 
- (AKSystemSound *)vibrate:(BOOL)vibrate;

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
// Finds specified sound in cache. If found then:
//   unschedules all soundIDs for found object that were scheduled via -schedule...,
//   forces sending of ...SoundDidPlay... notifications,
//   removes sound from cache.
// If you have no external pointers to instance with sound of name
// it leads to deallocation of object and stop of playing.
+ (BOOL)freeSoundWithName:(NSString*)name;

+ (BOOL)isAnySoundPlaying;
@end