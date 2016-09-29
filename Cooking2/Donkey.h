//
//  Donkey.h
//  Cooking
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Donkey : NSObject
@property NSDictionary * deviceUser;
@property User * currentUser;

@property NSArray * cantons;
@property NSString * selectedCanton;

@property NSArray * ranges;
@property NSArray * skillLevels;
@property NSArray * courses;

@property NSArray * recents;


+(id)sharedInstance;
-(void)saveCurrentUser;
-(void)loadCurrentUser;
-(void)parseMeta:(NSDictionary *)meta;


//
@property NSMutableDictionary * users;
@property NSMutableDictionary * recipes;
-(NSDictionary *)userForID:(NSString *)userID;
-(NSDictionary *)recipeForID:(NSString *)recipeID;

-(void)setPreferredCanton:(NSString *)canton;
-(void)sortDataForPreferredCanton;
@property NSArray * cantonUsers;
@property NSArray * cantonRecipes;
@property NSArray * cantonRecents;

-(NSDictionary *)rankingForRecipe:(NSString *)recipeID;


@property NSArray * media;

@end
