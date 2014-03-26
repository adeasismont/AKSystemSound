//
//  IVRViewController.m
//  TestSystemSound
//
//  Created by Ivan Rublev on 12/5/13.
//  Copyright (c) 2013 Ivan Rublev http://ivanrublev.me. All rights reserved.
//
//  Ship_Brass_Bell.caf from soundbible.com
//  Ship Brass Bell Recorded by Mike Koenig
//  http://creativecommons.org/licenses/by/3.0/
//
//
#import "IVRViewController.h"
#import "AKSystemSound.h"

@interface IVRViewController () {
    AKSystemSoundID soundid;
}
@end

@implementation IVRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:AKSystemSoundsWillPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:AKSystemSoundsDidPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:AKSystemSoundWillPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:AKSystemSoundDidPlayNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postNotificationPressed:(id)sender {
    UILocalNotification * noty = [UILocalNotification new];
    noty.alertBody = @"DayBell";
    noty.alertAction = @"Snooze";
    noty.soundName = @"Ship_Brass_Bell.caf";
    noty.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    [[UIApplication sharedApplication] scheduleLocalNotification:noty];
    NSLog(@"notification posted:%@", noty);
}

- (IBAction)playPressed:(id)sender {
    [[AKSystemSound soundWithName:@"Ship_Brass_Bell"] play];
}

- (IBAction)playWithVibrationPressed:(id)sender {
    [[[AKSystemSound soundWithName:@"Ship_Brass_Bell"] vibrate:YES] play];
}

- (IBAction)playRepeatedlyPressed:(id)sender {
    soundid = [[[AKSystemSound soundWithName:@"Ship_Brass_Bell"] vibrate:YES] scheduleRepeatWithInterval:0];
}

- (IBAction)stopPressed:(id)sender {
    [AKSystemSound freeSoundWithName:@"Ship_Brass_Bell"];
    NSLog(@"stopPressed");
}

- (void)notificationReceived:(NSNotification *)note
{
    NSLog(@"Received bell notification:%@", note);
}

@end
