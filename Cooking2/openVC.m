//
//  openVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "openVC.h"
#import "Peacock.h"
#import "registerVC.h"
@import AVFoundation;

@interface openVC () {
    
    Peacock * _peacock;
    registerVC * _registerVC;
    
    float w;
    float h;
  
    UIImageView * logoIV;
}

@end

@implementation openVC

//SETUP
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    [self begin];
}
-(void)setup{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popRegistrationVC:) name:@"kPopRegisterVC" object:nil];
    
    _peacock = [Peacock sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
}
-(void)layout{
    
    self.view.backgroundColor = [UIColor blackColor];

    UIImageView * bgIV = [UIImageView new];
    bgIV.frame = self.view.bounds;
    bgIV.contentMode = UIViewContentModeScaleAspectFill;
    bgIV.clipsToBounds = true;
    bgIV.image = [UIImage imageNamed:@"bgIV4.jpg"];
    [self.view addSubview:bgIV];

    UIImageView * cover = [UIImageView new];
    cover.frame = bgIV.bounds;
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:cover];
    
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = bgIV.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, [UIColor blackColor].CGColor, nil];
    gradient.locations = @[@0.0,@0.5,@1.0];
    [cover.layer insertSublayer:gradient atIndex:0];
    
    /*
     NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bgvid" ofType:@"mp4"]];
     AVPlayer *player = [AVPlayer playerWithURL:videoURL];
     [player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
     
     AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
     playerLayer.frame = self.view.bounds;
     [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
     [self.view.layer addSublayer:playerLayer];
     [player play];
     */
    
    float yOff = h-20;
    
    yOff -= 60;
    float tvW = MIN(w-40,280);
    UITextView * termsTV = [UITextView new];
    termsTV.frame = CGRectMake((w-tvW)/2, yOff, tvW, 60);
    termsTV.backgroundColor = [UIColor clearColor];
    termsTV.textColor = [UIColor whiteColor];
    termsTV.editable = false;
    termsTV.text = @"By signing up I agree to King Cook Off's Terms of Service and Privacy Policy. The owners of this service are not responsible for its content.";
    termsTV.textContainer.lineFragmentPadding = 0;
    termsTV.textContainerInset = UIEdgeInsetsZero;
    termsTV.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:termsTV];

    yOff -= 40 + 10;
    UIButton * continueButton = [UIButton new];
    continueButton.frame = CGRectMake((w-200)/2, yOff, 200, 40);
    [continueButton setTitle:@"Weiter ohne einzuloggen" forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [continueButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    yOff -= 40 + 10;
    UIButton * signInButton = [UIButton new];
    signInButton.frame = CGRectMake((w-200)/2, yOff, 200, 40);
    [signInButton setTitle:@"Login" forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signInButton setBackgroundColor:[UIColor clearColor]];
    [signInButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [signInButton.layer setCornerRadius:20.0f];
    [signInButton.layer setBorderWidth:1.0f];
    [signInButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [signInButton addTarget:self action:@selector(pushLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signInButton];
    
    yOff -= 40 + 10;
    UIButton * signUpButton = [UIButton new];
    signUpButton.frame = CGRectMake((w-200)/2, yOff, 200, 40);
    [signUpButton setTitle:@"Anmelden" forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setBackgroundColor:_peacock.appColour];
    [signUpButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [signUpButton.layer setCornerRadius:20.0f];
    [signUpButton.layer setBorderWidth:1.0f];
    [signUpButton.layer setBorderColor:_peacock.appColour.CGColor];
    [signUpButton addTarget:self action:@selector(pushRegistrationVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    
    yOff -= 100 + 10;
    UIImageView * logoIVHolder = [UIImageView new];
    logoIVHolder.frame = CGRectMake((w-100)/2, yOff, 100, 100);
    logoIVHolder.clipsToBounds = true;
    [self.view addSubview:logoIVHolder];
    
    logoIV = [UIImageView new];
    logoIV.frame = logoIVHolder.bounds;
    logoIV.image = [[UIImage imageNamed:@"chef-512.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    logoIV.tintColor = [UIColor whiteColor];
    logoIV.contentMode = UIViewContentModeScaleAspectFit;
    [logoIVHolder addSubview:logoIV];
}
-(void)begin{
    
    logoIV.transform = CGAffineTransformMakeTranslation(0, logoIV.frame.size.height);
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         logoIV.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

//REGISTRATION VC
-(void)pushRegistrationVC {

    _registerVC = [registerVC new];
    [self addChildViewController:_registerVC];
    [self.view addSubview:_registerVC.view];
    [_registerVC beginWithUser:nil];
    
    _registerVC.view.transform = CGAffineTransformMakeTranslation(0, _registerVC.view.frame.size.height);
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _registerVC.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
-(void)popRegistrationVC:(NSNotification *)n {
    
    if ([n.userInfo[@"shouldLogin"] boolValue]){
        [self popSelf];
    } else {
        [UIView animateWithDuration:0.6f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _registerVC.view.transform = CGAffineTransformMakeTranslation(0, _registerVC.view.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                             [_registerVC removeFromParentViewController];
                             [_registerVC.view removeFromSuperview];
                             _registerVC = nil;
                         }];
    }
}


-(void)pushLogin{
    
}
-(void)pushContinue{
    
}
-(void)popSelf {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopOpenVC" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
