//
//  recipeCell.h
//  Cooking2
//
//  Created by Duncan Geoghegan on 08/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface recipeCell : UIView
@property UIImageView * recipeIV;
@property UIButton * button;
-(void)updateForRecipe:(NSDictionary *)recipe atRank:(int)rank;
@end
