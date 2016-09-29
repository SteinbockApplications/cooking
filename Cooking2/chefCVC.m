//
//  chefCVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "chefCVC.h"

@implementation chefCVC {
    
    float w;
    float h;
    
}
@synthesize profileLabel;
@synthesize profileIV;
@synthesize noScoreLabel;
@synthesize rankLabel;
@synthesize titleLabel;
@synthesize subtitleLabel;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        w = frame.size.width;
        h = frame.size.height;
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIView * profileCircle = [UIView new];
        profileCircle.frame = CGRectMake(10, 10, 60, 60);
        profileCircle.layer.cornerRadius = 30.0f;
        profileCircle.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:profileCircle];
        
        profileLabel = [UILabel new];
        profileLabel.frame = profileCircle.bounds;
        profileLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
        profileLabel.textColor = [UIColor whiteColor];
        profileLabel.textAlignment = NSTextAlignmentCenter;
        [profileCircle addSubview:profileLabel];
        
        profileIV = [UIImageView new];
        profileIV.frame = profileCircle.bounds;
        profileIV.contentMode = UIViewContentModeScaleAspectFill;
        profileIV.clipsToBounds = true;
        profileIV.layer.cornerRadius = 30.0f;
        [profileCircle addSubview:profileIV];
        
        noScoreLabel = [UILabel new];
        noScoreLabel.frame = CGRectMake(80, 10, w-90, 20.0f);
        noScoreLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightBold];
        noScoreLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:noScoreLabel];

        rankLabel = [UILabel new];
        rankLabel.frame = CGRectMake(80, 10, w-90, 20.0f);
        rankLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        rankLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        rankLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:rankLabel];
        
        titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(80, 30, w-90, 20.0f);
        titleLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
        titleLabel.textColor = [UIColor blackColor];
        [self addSubview:titleLabel];
        
        subtitleLabel = [UILabel new];
        subtitleLabel.frame = CGRectMake(80, 50, w-90, 20.0f);
        subtitleLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        subtitleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:subtitleLabel];
        
        UIImageView * div = [UIImageView new];
        div.frame = CGRectMake(0, 79.5, w, 0.5f);
        div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
        [self addSubview:div];

        
    }
    return self;
}
@end
