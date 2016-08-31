//
//  cameraVC.h
//  Cooking2
//
//  Created by Duncan Geoghegan on 30/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface cameraVC : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate>
-(void)beginWithType:(int)type;
@end
