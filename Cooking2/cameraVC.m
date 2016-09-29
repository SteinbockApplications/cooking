//
//  cameraVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 30/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "cameraVC.h"
#import "Peacock.h"
#import "Fish.h"
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@interface cameraVC () {
    
    Peacock * _peacock;
    Fish * _fish;
    
    float w;
    float h;
    
    int _type;
    bool isVideo;
    
    UIButton * photoButton;
    UIButton * videoButton;
    UIButton * captureButton;
    UILabel * recordLabel;
    
    //INPUT
    UIView * previewHolder;
    AVCaptureSession * session;
    AVCaptureMovieFileOutput * fileOut;
    AVCaptureVideoDataOutput * dataOut;
    AVCaptureVideoPreviewLayer * preview;
    AVCaptureConnection * connection;
    
    //PHOTO
    UIImage * runImage;
    
    //VIDEO
    bool isRecording;
    NSTimer * videoTimer;
    int elapsedSeconds;
    
    //OUTPUT
    UIImage * filtered;
    UIImage * filteredThumb;
    UIImage * videoThumb;
    
}
@end

@implementation cameraVC

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    
}

-(void)setup{
    
    _peacock = [Peacock sharedInstance];
    _fish = [Fish sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusBarAppearance" object:[NSNumber numberWithBool:true]];
    
}
-(void)layout{
    
    self.view.backgroundColor = [UIColor blackColor];

    previewHolder = [UIView new];
    previewHolder.frame = self.view.bounds;
    previewHolder.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
    [self.view addSubview:previewHolder];

    recordLabel = [UILabel new];
    recordLabel.frame = CGRectMake(0, 0, h, 50);
    recordLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    recordLabel.textAlignment = NSTextAlignmentCenter;
    recordLabel.textColor = [UIColor whiteColor];
    recordLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
    recordLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    recordLabel.center = CGPointMake(w-25, h/2);
    recordLabel.userInteractionEnabled = true;
    [self.view addSubview:recordLabel];
    
    UIButton * closeButton = [UIButton new];
    closeButton.frame = CGRectMake(h-50, 0, 50, 50);
    [closeButton setImage:[[UIImage imageNamed:@"close-120.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor whiteColor]];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(10,10,10,10)];
    [closeButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [recordLabel addSubview:closeButton];
    
    UIView * captureHolder = [UIView new];
    captureHolder.frame = CGRectMake((w-80)/2, h-100, 80, 80);
    captureHolder.backgroundColor = [UIColor whiteColor];
    captureHolder.layer.cornerRadius = 40.0f;
    [self.view addSubview:captureHolder];
    
    captureButton = [UIButton new];
    captureButton.frame = CGRectMake(5, 5, 70, 70);
    captureButton.backgroundColor = [UIColor whiteColor];
    captureButton.layer.cornerRadius = 35;
    captureButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f].CGColor;
    captureButton.layer.borderWidth = 1.0f;
    [captureButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [captureHolder addSubview:captureButton];


}
-(void)beginWithType:(int)type {
    
    _type = type;
    if (_type == 0){ //photo
        recordLabel.text = @"Hauptbild";
        [self loadScannerForPhoto];
    } else if (_type == 1){ //additional photo
        recordLabel.text = @"Weiteres Bild";
        [self loadScannerForPhoto];
    } else if (_type == 2){ //video
        isVideo = true;
        recordLabel.text = @"00:00/00:30";
        captureButton.backgroundColor = _peacock.tedRed;
        [self loadScannerForFilm];
    } else if (_type == 3){
        recordLabel.text = @"Benutzerprofil Bild";
        [self loadScannerForPhoto];
    }
}
-(void)loadScannerForPhoto {
    
    if (TARGET_IPHONE_SIMULATOR){
        NSLog(@"simulator");
        return;
    }
    
    
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (_type == 3){ videoDevice = [self frontCamera]; }
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    
    dataOut = [AVCaptureVideoDataOutput new];
    [dataOut setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [dataOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];

    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    [session addInput:videoInput];
    [session addOutput:dataOut];
    [session startRunning];
    
    preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewHolder.bounds;
    [previewHolder.layer insertSublayer:preview atIndex:0];
    
    connection = preview.connection;
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [previewHolder.layer insertSublayer:preview atIndex:0];

}
-(void)loadScannerForFilm {

    if (TARGET_IPHONE_SIMULATOR){
        NSLog(@"simulator");
        return;
    }
    
    AVCaptureDevice * audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    fileOut = [AVCaptureMovieFileOutput new];
    
    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    [session addInput:audioInput];
    [session addInput:videoInput];
    [session addOutput:fileOut];
    [session startRunning];
    
    preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewHolder.bounds;
    [previewHolder.layer insertSublayer:preview atIndex:0];
}
-(void)capture {
    
    if (isVideo){ //VIDEO

        if (!isRecording){ //START RECORDING
            
            if (TARGET_IPHONE_SIMULATOR){ return; }
            /*
            isRecording = true;
            NSString * outputPath = [_fish filePathForFilename:@"temp.mp4" inFolder:@"videos"];
            NSURL * outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
            [fileOut startRecordingToOutputFileURL:outputURL recordingDelegate:self];
            */
        } else { //END RECORDING

            isRecording = false;
            [fileOut stopRecording];
            
        }

    } else { //PHOTO
        
        [self processImage:runImage];
        
        
    }
}

//PHOTO
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    runImage = [self imageForBuffer:sampleBuffer];
    
}
-(UIImage *)imageForBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    UIImage * rotated = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRight];
    return rotated;
}
-(AVCaptureDevice *)frontCamera {
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * d in devices) {
        if ([d position] == AVCaptureDevicePositionFront) {
            return d;
        }
    }
    return nil;
}

//VIDEO
-(void)updateTimer {
    
    elapsedSeconds++;
    recordLabel.text = [NSString stringWithFormat:@"00:%02d / 00:30", elapsedSeconds];
    
    if (elapsedSeconds == 30){
        [fileOut stopRecording];
    }
    
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
   
    //start recording
    NSLog(@"start recording");
    
    //ui
    elapsedSeconds = 0;
    videoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer) userInfo:nil repeats:true];
    [videoTimer fire];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         captureButton.backgroundColor = _peacock.tedRed;
                     }
                     completion:^(BOOL finished){
                     }];
    
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    //stop recording
    NSLog(@"stop recording");
    
    //ui
    elapsedSeconds = 0;
    [videoTimer invalidate];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         captureButton.backgroundColor = [UIColor whiteColor];
                     }
                     completion:^(BOOL finished){
                     }];
    
    //data
    if (!outputFileURL){
        return;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:outputFileURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    videoThumb = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [self processComplete];

}


//PROCESSING
-(void)processImage:(UIImage *)image {
    
    NSLog(@"process image");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        filtered = image;
        //if (_type == 3){ filtered = [_peacock rotateImage:filtered byDegree:180]; NSLog(@"HIT"); }
        //if (_type == 3){ filtered = [_peacock unrotateImage:filtered];}
        filtered = [_peacock applyFilterToImage:filtered];
        filteredThumb = [_peacock scaleImage:filtered toMaxDimension:400];

        if (_type == 3){ filteredThumb = [_peacock rotateImage:filteredThumb byDegree:180]; NSLog(@"HIT"); }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self processComplete];
        });
        
    });
}
-(void)processComplete { //pop

    NSLog(@"process complete");
    
    if (_type == 0 || _type == 1 || _type == 3){ //images
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusBarAppearance" object:[NSNumber numberWithBool:false]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopCameraVC" object:[NSNumber numberWithInteger:_type] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:filteredThumb, @"thumb", filtered, @"original", nil]];
        
    } else if (_type == 2){ //video
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusBarAppearance" object:[NSNumber numberWithBool:false]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopCameraVC" object:[NSNumber numberWithInteger:_type] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:videoThumb,@"thumb", nil]];
        
    }
}

//OTHER
-(void)popSelf {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusBarAppearance" object:[NSNumber numberWithBool:false]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopCameraVC" object:nil];
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
