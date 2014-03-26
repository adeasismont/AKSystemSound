//
//  IVRViewController.h
//  TestSystemSound
//
//  Created by Ivan Rublev on 12/5/13.
//  Copyright (c) 2013 Ivan Rublev http://ivanrublev.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVRViewController : UIViewController
- (IBAction)postNotificationPressed:(id)sender;
- (IBAction)playPressed:(id)sender;
- (IBAction)playWithVibrationPressed:(id)sender;
- (IBAction)playRepeatedlyPressed:(id)sender;
- (IBAction)stopPressed:(id)sender;

@end
