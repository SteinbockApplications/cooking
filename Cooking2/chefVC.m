//
//  chefVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "chefVC.h"
#import "peacock.h"
#import "donkey.h"

@interface chefVC () {
  
    Peacock * _peacock;
    Donkey * _donkey;
 
    float w;
    float h;

    UIScrollView * mainScroller;
}
@end
@implementation chefVC
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
}
-(void)setup{

    w = self.view.frame.size.width;
    h = self.view.frame.size.height;

}
-(void)layout{

    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView * profileIV = [UIImageView new];
    profileIV.frame = self.view.bounds;
    profileIV.backgroundColor = [UIColor darkGrayColor];
    profileIV.contentMode = UIViewContentModeScaleAspectFill;
    profileIV.clipsToBounds = true;
    profileIV.image = [UIImage imageNamed:@"cook.png"];
    [self.view addSubview:profileIV];
    
    UIImageView * cover = [UIImageView new];
    cover.frame = profileIV.bounds;
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:cover];
    
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = profileIV.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, [UIColor blackColor].CGColor, nil];
    gradient.locations = @[@0.0,@0.5,@1.0];
    [cover.layer insertSublayer:gradient atIndex:0];
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = self.view.bounds;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    mainScroller.alwaysBounceVertical = true;
    mainScroller.userInteractionEnabled = true;
    [self.view addSubview:mainScroller];
    
    
    float yOff = h-200;
    UILabel * nameLabel = [UILabel new];
    nameLabel.frame = CGRectMake(20, yOff, w-40, 100);
    nameLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = @"Duncan Geoghegan";
    [mainScroller addSubview:nameLabel];
    
    yOff += 100;
    
    UIView * biographyHeader = [self headerViewWithString:@"Biographie" atOffset:yOff];
    [mainScroller addSubview:biographyHeader];
    yOff += 30;
    
    mainScroller.contentSize = CGSizeMake(w, yOff);
    
    
    
    
}

-(UIView *)headerViewWithString:(NSString *)string atOffset:(float)yOff{
    
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, yOff, w, 30);
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 30);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    label.textColor = [UIColor whiteColor];
    label.text = string;
    [view addSubview:label];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 29, w-40, 0.5f);
    div.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [view addSubview:div];
    
    return view;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
