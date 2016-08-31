//
//  Recipe.h
//  Cooking
//
//  Created by Duncan Geoghegan on 26/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recipe : NSObject
@property NSString * recipeID;
@property NSString * timestamp;
@property NSString * recipeName;
@property NSString * duration;
@property NSString * difficulty;
@property NSString * course;
@property NSString * introduction;
@property NSString * ingredients;
@property NSString * instructions;
@property NSArray * scores;
@end
