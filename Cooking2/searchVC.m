//
//  searchVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "searchVC.h"
#import "Peacock.h"

@interface searchVC () {
    
    Peacock * _peacock;
    float w;
    float h;
    
}

@end

@implementation searchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    [self begin];
}
-(void)setup{
    
    _peacock = [Peacock sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
}
-(void)layout{
    

    UIVisualEffectView * vs = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    vs.frame = self.view.frame;
  //  [self.view addSubview:vs];
    
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 60, w, h-60);
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    
}
-(void)begin{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
