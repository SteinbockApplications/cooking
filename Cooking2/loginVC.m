//
//  loginVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "loginVC.h"
#import "Peacock.h"

@interface loginVC () {
    
    Peacock * _peacock;
    float w;
    float h;
    
}

@end

@implementation loginVC

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
    
    self.view.backgroundColor = [UIColor blackColor];
}
-(void)begin{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
