//
//  FirstViewController.m
//  SilverPanda
//
//  Created by Miron Vranjes on 11/16/13.
//  Copyright (c) 2013 Miron Vranjes. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize session;
@synthesize aMovieFileOutput;

int timerCount;

- (IBAction)startRecording:(id)sender {
    
        NSLog(@"boom");
    
    NSUUID  *UUID = [NSUUID UUID];
    NSString* stringUUID = [NSString stringWithFormat:@"%@%@", [UUID UUIDString], @".mov"];

    NSString *plistPath;
    NSString *rootPath;
    rootPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:stringUUID];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:plistPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:plistPath]) {
        NSLog(@"file exist  %s     n       url   %@  ",[rootPath UTF8String],fileURL);
        [fileManager removeItemAtPath:plistPath error:NULL];
    }
    
    //Timer
    timerCount = 0;
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
    [_recordingTimer fire];
    
    [aMovieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (IBAction)stopRecording:(id)sender {
        NSLog(@"shakalaka      3");
    _recordingLabel.text = @"";
        [_recordingTimer invalidate];
    [aMovieFileOutput stopRecording];
    [self flipViews];
    
//    NSURL *URL = [NSURL URLWithString:@"http://silverpanda.herokuapp.com"];
     NSURL *URL = [NSURL URLWithString:@"http://169.254.207.230:5000"];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:URL];

    NSMutableURLRequest *request = [manager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:@"/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:aMovieFileOutput.outputFileURL]
                                    name:@"test"
                                fileName:@"test.mov"
                                mimeType:@"video/quicktime"];
    }];
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"operation successful");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"operation failed");
    }];
    
    // queue up the operation
    [manager enqueueObjectRequestOperation:operation];
}

-(void)flipViews
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_videoWindow cache:YES];
    
    if ([_videoTable superview])
    {
        [_videoTable removeFromSuperview];
        [_videoWindow addSubview:_videoView];
        [_videoWindow sendSubviewToBack:_videoTable];
    }
    else
    {
        [_videoView removeFromSuperview];
        [_videoWindow addSubview:_videoTable];
        [_videoWindow sendSubviewToBack:_videoView];
    }
    
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    session = [[AVCaptureSession alloc] init];
    //session is global object.
    
    session.sessionPreset = AVCaptureSessionPresetLow;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    captureVideoPreviewLayer.frame = _videoWindow.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _videoView = [[UIView alloc] initWithFrame:_videoWindow.bounds];
    [_videoView.layer addSublayer: captureVideoPreviewLayer];
    [_videoWindow addSubview: _videoView];
    [_videoTable removeFromSuperview];

    AVCaptureDevice *device =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    NSLog(@"start      3");
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"No camera!"
                                                             message:@"Crap. Your device doesn't have a camera."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }
    
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if(!audioInput)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"No microphone!"
                                                             message:@"Like the 1920s, your device doesn't have microphones."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }
    
    [session addInput:input];
    [session addInput:audioInput];

    /*
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
    */
    
    aMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
 //   [aMovieFileOutput setMaxRecordedDuration:CMTimeMakeWithSeconds(5, 1)];
    
    [session addOutput:aMovieFileOutput];
    [session startRunning];
    
    //previously i used to do this way but saw people doing it after delay thought it might be taking some time to initialized so tried this way also.
    
    
}

- (void)increaseTimerCount
{
    if(timerCount != 0)
    {
    _recordingLabel.text = [NSString stringWithFormat:@"%d", timerCount++];
    } else {
        _recordingLabel.text = @"";
        timerCount++;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
