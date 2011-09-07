#import "AKSystemSound.h"

// Notifications
NSString *const AKSystemSoundsWillPlayNotification	= @"AKSystemSoundsWillPlayNotification";
NSString *const AKSystemSoundsDidPlayNotification	= @"AKSystemSoundsDidPlayNotification";

NSString *const AKSystemSoundWillPlayNotification	= @"AKSystemSoundWillPlayNotification";
NSString *const AKSystemSoundDidPlayNotification	= @"AKSystemSoundDidPlayNotification";

// Callback declaration
void AKSystemSoundCompleted (SystemSoundID ssID, void* clientData);

// Private interface
@interface AKSystemSound ()
- (void)_soundCompleted;
+ (AKSystemSoundID)_scheduleSound:(AKSystemSound*)sound interval:(NSTimeInterval)interval;
+ (void)_soundWillPlay:(AKSystemSound*)sound;
+ (void)_soundDidPlay:(AKSystemSound*)sound;
@end

// Callback
void AKSystemSoundCompleted (SystemSoundID ssID, void* clientData)
{
	AKSystemSound *sound = (AKSystemSound*)clientData;
	if ([sound isKindOfClass:[AKSystemSound class]])
		[sound _soundCompleted];
}

// Implementation
@implementation AKSystemSound

- (id)initWithName:(NSString*)name
{
	NSParameterAssert(name);
	NSString *soundPath = [[NSBundle mainBundle]
						   pathForResource:name
						   ofType:([[name pathExtension] length] ? nil : @"caf")];
	self = [self initWithPath:soundPath];
	return self;
}

- (id)initWithPath:(NSString*)path
{
	NSParameterAssert(path);
	if ((self = [super init]))
	{
		NSURL *URL = [NSURL fileURLWithPath:path];
		if ((AudioServicesCreateSystemSoundID((CFURLRef)URL, &_soundID)) != noErr)
		{
			NSLog(@"could not load system sound: %@", path);
			return nil;
		}
	}
	return self;
}

+ (AKSystemSound*)soundWithName:(NSString*)name
{
	static NSMutableDictionary *sNamedSounds = nil;
	AKSystemSound *sound = nil;
	@synchronized([AKSystemSound class])
	{
		if (sNamedSounds == nil)
			sNamedSounds = [[NSMutableDictionary alloc] init];
		sound = [sNamedSounds objectForKey:name];
		if (!sound)
		{
			sound = [[[AKSystemSound alloc] initWithName:name] autorelease];
			[sNamedSounds setObject:sound forKey:name];
		}
	}
	return sound;
}

- (void)dealloc
{
	AudioServicesDisposeSystemSoundID(_soundID);
	[super dealloc];
}


- (void)play
{
	@synchronized(self)
	{
		if (_playing == 0)
		{
			// if not already playing, retain (to prevent -dealloc) and set sound completion callback
			[self retain];
			AudioServicesAddSystemSoundCompletion(_soundID, NULL, NULL, AKSystemSoundCompleted, self);
		}
		_playing++;
		
		[[self class] _soundWillPlay:self];
		AudioServicesPlaySystemSound(_soundID);
	}
}

static unsigned int sSoundsPlaying = 0;

+ (void)_soundWillPlay:(AKSystemSound*)sound
{
	@synchronized([AKSystemSound class])
	{
		// if first sound playing right now, send notification
		if (sSoundsPlaying == 0)
			[[NSNotificationCenter defaultCenter]
				postNotificationName:AKSystemSoundsWillPlayNotification
				object:nil];
		sSoundsPlaying++;
	}
	
	// send notification that specific sound will play
	[[NSNotificationCenter defaultCenter]
		postNotificationName:AKSystemSoundWillPlayNotification
		object:sound];
}

+ (void)_soundDidPlay:(AKSystemSound*)sound
{
	// send notification that specific sound did play
	[[NSNotificationCenter defaultCenter]
		postNotificationName:AKSystemSoundDidPlayNotification
		object:sound];
	
	@synchronized([AKSystemSound class])
	{
		sSoundsPlaying--;
		// if this was the last sound, send notification
		if (sSoundsPlaying == 0)
			[[NSNotificationCenter defaultCenter]
				postNotificationName:AKSystemSoundsDidPlayNotification
				object:nil];
	}
}

- (void)_soundCompleted
{
	@synchronized(self)
	{
		[[self class] _soundDidPlay:self];
		
		_playing--;
		if (_playing == 0)
		{
			// if we're done playing, release ourselves (retained in -play)
			// and remove completed callback
			AudioServicesRemoveSystemSoundCompletion(_soundID);
			[self release];
		}
	}
}


- (AKSystemSoundID)scheduleWithInterval:(NSTimeInterval)interval
{
	return [[self class] _scheduleSound:self interval:interval];
}

static NSMutableDictionary *sScheduledTimers = nil;
static AKSystemSoundID sCurrentSystemSoundID = 0;

+ (AKSystemSoundID)_scheduleSound:(AKSystemSound*)sound interval:(NSTimeInterval)interval
{
	AKSystemSoundID soundID;
	
	@synchronized([AKSystemSound class])
	{
		// add 1 to the current system sound id pointer
		sCurrentSystemSoundID++;
		soundID = sCurrentSystemSoundID;
		
		// create the timer, userInfo retains the sound object
		// preveting it from being deallocated while scheduled
		NSTimer *timer = [NSTimer timerWithTimeInterval:interval
			target:self
			selector:@selector(_scheduledTimerFired:)
			userInfo:sound
			repeats:YES];
			
		// add the timer to the scheduled timers dictionary
		if (sScheduledTimers == nil)
			sScheduledTimers = [[NSMutableDictionary alloc] init];
		[sScheduledTimers setObject:timer forKey:[NSNumber numberWithInt:soundID]];
		
		// add the timer to the main runloop
		[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	}
	
	return soundID;
}

+ (void)_scheduledTimerFired:(NSTimer*)timer
{
	if ([timer isValid])
	{
		AKSystemSound *sound = (AKSystemSound*)[timer userInfo];
		[sound play];
	}
}

+ (void)cancelScheduledSoundWithID:(AKSystemSoundID)soundID
{
	if (soundID == AKSystemSoundInvalidID)
		return;
	
	@synchronized([AKSystemSound class])
	{
		NSNumber *key = [NSNumber numberWithInt:soundID];
		NSTimer *timer = [sScheduledTimers objectForKey:key];
		if (timer)
		{
			[timer invalidate];
			[sScheduledTimers removeObjectForKey:key];
		}
	}
}

@end