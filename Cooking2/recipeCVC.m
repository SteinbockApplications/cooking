//
//  recipeCVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "recipeCVC.h"

@implementation recipeCVC {
    float w;
    float h;
    
}

@synthesize recipeIV;
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
        
        UIImageView * recipeIVHolder = [UIImageView new];
        recipeIVHolder.frame = CGRectMake(0, 0, w, 240);
        recipeIVHolder.clipsToBounds = true;
        recipeIVHolder.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:recipeIVHolder];
        
        recipeIV = [UIImageView new];
        recipeIV.frame = CGRectMake(0, 0, w, 240);
        recipeIV.contentMode = UIViewContentModeScaleAspectFill;
        [recipeIVHolder addSubview:recipeIV];
        
        UIView * cover = [UIView new];
        cover.frame = CGRectMake(0, 160, w, 80);
        cover.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        [self addSubview:cover];
        
        noScoreLabel = [UILabel new];
        noScoreLabel.frame = CGRectMake(10, 170, w-20, 20.0f);
        noScoreLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightBold];
        noScoreLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:noScoreLabel];
        
        rankLabel = [UILabel new];
        rankLabel.frame = CGRectMake(10, 170, w-20, 20.0f);
        rankLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        rankLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        rankLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:rankLabel];
        
        titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(10, 190, w-20, 20.0f);
        titleLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightBold];
        titleLabel.textColor = [UIColor blackColor];
        [self addSubview:titleLabel];
        
        subtitleLabel = [UILabel new];
        subtitleLabel.frame = CGRectMake(10, 210, w-20, 20.0f);
        subtitleLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        subtitleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
        [self addSubview:subtitleLabel];
        
        UIImageView * div = [UIImageView new];
        div.frame = CGRectMake(0, 239.5, w, 0.5f);
        div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        [self addSubview:div];

    }
    return self;
}
@end
