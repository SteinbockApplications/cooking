//
//  recipeCell.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 08/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "recipeCell.h"
#import "Peacock.h"
@implementation recipeCell {
    
    Peacock * _peacock;
    
    float w;
    float h;
    
    UILabel * titleLabel;
    UILabel * subtitleLabel;
    UILabel * rankLabel;
    
}
@synthesize recipeIV, button;
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _peacock = [Peacock sharedInstance];
        
        w = frame.size.width;
        h = frame.size.height;
        
        self.backgroundColor = _peacock.appleWhite;
        
        UIImageView * recipeIVHolder = [UIImageView new];
        recipeIVHolder.frame = CGRectMake(0, 0, w, 160);
        recipeIVHolder.clipsToBounds = true;
        recipeIVHolder.backgroundColor = _peacock.appleDark;
        [self addSubview:recipeIVHolder];
        
        recipeIV = [UIImageView new];
        recipeIV.frame = CGRectMake(0, 0, w, 190);
        recipeIV.contentMode = UIViewContentModeScaleAspectFill;
        [recipeIVHolder addSubview:recipeIV];
        
        rankLabel = [UILabel new];
        rankLabel.frame = CGRectMake(10, 170, w-20, 20.0f);
        rankLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        rankLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        rankLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:rankLabel];
        
        titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(10, 190, w-20, 20.0f);
        titleLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
        titleLabel.textColor = [UIColor blackColor];
        [self addSubview:titleLabel];
        
        subtitleLabel = [UILabel new];
        subtitleLabel.frame = CGRectMake(10, 210, w-20, 20.0f);
        subtitleLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        subtitleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:subtitleLabel];
        
        UIImageView * div = [UIImageView new];
        div.frame = CGRectMake(0, 239.5, w, 0.5f);
        div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        [self addSubview:div];
        
        button = [UIButton new];
        button.frame = self.bounds;
        [self addSubview:button];
        
    }
    return self;
}
-(void)updateForRecipe:(NSDictionary *)recipe {
    
   // NSLog(@"recipe is %@", recipe);
    

    //profile iv
    recipeIV.image = [UIImage imageNamed:@"recipe.png"];
    // NSString * path = [NSString stringWithFormat:@"http://www.steinbockapplications.com/other/cooking/users/%@/profile_thumb.jpg",user[@"userID"]];
    // UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];
    // bgIV.image = image;
    
    //star view
    UIView * starView = [_peacock starViewWithScore:3.50f ofColour:_peacock.appColour forHeight:15.0f atPoint:CGPointMake(10, 170)];
    [self addSubview:starView];
    
    
    //rank label
    rankLabel.text = @"#1";
    
    //title label
    titleLabel.text = recipe[@"recipeName"];
    
    //subtitle
    subtitleLabel.text = recipe[@"userName"];

    
}


@end
