//
//  FirstViewController.h
//  SilverPanda
//
//  Created by Miron Vranjes on 11/16/13.
//  Copyright (c) 2013 Miron Vranjes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FirstViewController : UIViewController

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMovieFileOutput *aMovieFileOutput;
@property (weak, nonatomic) IBOutlet UIView *videoWindow;
@property (weak, nonatomic) IBOutlet UILabel *recordingLabel;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (weak, nonatomic) IBOutlet UITableView *videoTable;
@property (nonatomic, strong) UIView *videoView;

@end
