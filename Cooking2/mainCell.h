//
//  mainCell.h
//  Cooking2
//
//  Created by Duncan Geoghegan on 02/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mainCell : UIView
@property UIImageView * bgIV;
@property UILabel * titleLabel;
@property UILabel * subtitleLabel;
@property UIButton * button;
-(void)updateLayoutForTitle:(NSString *)title subtitle:(NSString *)subtitle;

-(void)updateForUser:(NSDictionary *)user;
-(void)updateForRecipe:(NSDictionary *)recipe;
@end
