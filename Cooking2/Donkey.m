//
//  Donkey.m
//  Cooking
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "Donkey.h"

@implementation Donkey
static Donkey *sharedInstance = nil;

@synthesize deviceUser;

@synthesize currentUser;
@synthesize cantons;
@synthesize skillLevels;
@synthesize courses;

@synthesize users;
@synthesize recipes;

+ (Donkey *)sharedInstance {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}
- (id)init {
    self = [super init];
    if (self) {
        
           cantons = @[@"Aargau",
                       @"Appenzell Ausserrhoden",
                       @"Appenzell Innerrhoden",
                       @"Basel-Landschaft",
                       @"Basel-Stadt",
                       @"Bern",
                       @"Freiburg",
                       @"Genf",
                       @"Glarus",
                       @"Graubünden",
                       @"Jura",
                       @"Luzern",
                       @"Neuenburg",
                       @"Nidwalden",
                       @"Obwalden",
                       @"Schaffhausen",
                       @"Schwyz",
                       @"Solothurn",
                       @"St.Gallen",
                       @"Tessin",
                       @"Thurgau",
                       @"Uri",
                       @"Waadt",
                       @"Wallis",
                       @"Zug",
                       @"Zurich"];
        
        skillLevels = @[@"Noob",
                        @"Hausfrau",
                        @"Profi"];
        
        courses = @[@"Entree",
                    @"Hauptgericht",
                    @"Dessert",
                    @"Snack"];
        
    }
    return self;
}

-(void)saveCurrentUser {

    [[NSUserDefaults standardUserDefaults] setObject:deviceUser forKey:@"profile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)loadCurrentUser {
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"profile"]){
        deviceUser = [[NSUserDefaults standardUserDefaults] valueForKey:@"profile"];
        
    }
    
}
-(void)parseMeta:(NSDictionary *)meta {

    /*
     userID = {
     createTS =
     email =
     name =
     location =
     bio =
     skill =
     exposesContact =
     recipes = [recipeID,recipeID,recipeID] //add from recipe loop
     reviews = {recipeID:score,recipeID:score} //add from score loop
     favourites = [redipeID,recipeID] //pull directly and parse
     following = [userID,userID,userID,userID] // pull directly and parse
     score =
     scoreCount
     }
     recipeID = {
     createTS =
     recipeName =
     duration =
     difficulty =
     course =
     introduction =
     ingredients =
     instructions =
     score =
     scores = []
     }
     */
    
    
    //pull the user data
    NSMutableArray * userArray = [[NSMutableArray alloc] initWithArray:meta[@"users"]];
    
    //init the users dictionary
    users = [NSMutableDictionary new];
    
    //add the content for the user key
    for (NSDictionary * user in userArray){
        NSString * userID = user[@"userID"];
        users[userID]=user;
    }
    

    //pull the recipe data
    NSMutableArray * recipeArray = [[NSMutableArray alloc] initWithArray:meta[@"recipes"]];
    
    //init the recipes dictionary
    recipes = [NSMutableDictionary new];
    
    //go through the recipes
    for (NSMutableDictionary * recipe in recipeArray){
        
        NSString * recipeID = recipe[@"recipeID"];
        recipes[recipeID] = recipe;
        
        NSString * userID = recipe[@"userID"];
        if (users[userID]){
            NSMutableDictionary * mUser = [[NSMutableDictionary alloc] initWithDictionary:users[userID]];
            NSMutableArray * existingRecipes = [NSMutableArray new];
            [existingRecipes addObjectsFromArray:mUser[@"recipes"]];
            [existingRecipes addObject:recipeID];
            mUser[@"recipes"]=existingRecipes;
            users[userID]=mUser;
        }
    }
    
    //pull the score data
    NSMutableArray * scoreArray = [[NSMutableArray alloc] initWithArray:meta[@"scores"]];

    //loop through adding in the scores
    for (NSDictionary * score in scoreArray){
        
        NSString * recipeID = score[@"recipeID"];
        NSString * userID = score[@"userID"];
        NSString * reviewerID = score[@"reviewerID"];
        NSString * review = score[@"score"];
        
        //set the score for the reviewer ID
        //as this is displayed when the user
        //visits this recipe
        if (users[reviewerID]){
            NSMutableDictionary * mUser = [[NSMutableDictionary alloc] initWithDictionary:users[reviewerID]];
            NSMutableDictionary * existingScores = [NSMutableDictionary new];
            existingScores[recipeID]=review;
            mUser[@"reviews"]=existingScores;
            users[reviewerID]=mUser;
        }
        
        //set the score for the recipe ID
        //this is used to calculate the
        //mean average score for the recipe
        if (recipes[recipeID]){
            NSMutableDictionary * mRecipe = [[NSMutableDictionary alloc] initWithDictionary:recipes[recipeID]];
            NSMutableArray * existingScores = [NSMutableArray new];
            [existingScores addObjectsFromArray:mRecipe[@"scores"]];
            [existingScores addObject:review];
            mRecipe[@"scores"]=existingScores;
            recipes[recipeID]=mRecipe;
        }
        
        //set the score for the user ID
        //this is calculated at the end
        if (users[userID]){
            NSMutableDictionary * mUser = [[NSMutableDictionary alloc] initWithDictionary:users[userID]];
            NSMutableArray * existingScores = [NSMutableArray new];
            [existingScores addObjectsFromArray:mUser[@"scores"]];
            [existingScores addObject:review];
            mUser[@"scores"]=existingScores;
            users[userID]=mUser;
        }
    }
    
    //calculate averages
    for (NSMutableDictionary * user in users.allValues){
        if (user[@"scores"]){
            
            //calculate mean
            float total = 0.0f;
            NSArray * scores = user[@"scores"];
            for (NSString * scoreString in scores){ total += scoreString.floatValue;}
            float mean = total / scores.count;
        
            //save in
            user[@"scores"]=nil;
            user[@"scoreCount"]=[NSString stringWithFormat:@"%i",(int)scores.count];
            user[@"score"]=[NSString stringWithFormat:@"%f",mean];
            users[user[@"userID"]]=user;
        }
    }
    
    for (NSMutableDictionary * recipe in recipes.allValues){
        
        if (recipe[@"scores"]){
            
            //calculate mean
            float total = 0.0f;
            NSArray * scores = recipe[@"scores"];
            for (NSString * scoreString in scores){ total += scoreString.floatValue;}
            float mean = total / scores.count;
            
            //save in
            recipe[@"score"]=[NSString stringWithFormat:@"%f",mean];
            recipes[recipe[@"recipeID"]]=recipe;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMetaReady" object:nil];
    
}



-(NSArray *)sortUsersByScoreForCanton:(NSString *)canton forRange:(int)days {
    
    //holds filtered users
    NSMutableArray * unsorted = [NSMutableArray new];
    
    //create range timestamp
    NSDate * rangeDate = [[NSDate date] dateByAddingTimeInterval:-86400*days];
    NSString * rangeTimestamp = [NSString stringWithFormat:@"%.0f",[rangeDate timeIntervalSince1970]];

    //loop through pulling out values
    for (NSDictionary * user in users.allValues){
        
        NSString * location = user[@"location"];
        if ([location isEqualToString:canton] || [canton.lowercaseString isEqualToString:@"all"]){
            
            NSString * timestamp = user[@"createTS"];
            if (timestamp.floatValue > rangeTimestamp.floatValue || days == -1){
                [unsorted addObject:user];
            }
        }
    }

    //sort by score
    NSSortDescriptor * scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:false];
    NSSortDescriptor * reviewDescriptor = [[NSSortDescriptor alloc] initWithKey:@"scoreCount" ascending:false];
    NSArray * sorted = [unsorted sortedArrayUsingDescriptors:@[scoreDescriptor, reviewDescriptor]];
    
    
    
    return sorted;
    
}
-(NSArray *)sortRecipesByScoreForCanton:(NSString *)canton forRange:(int)days {
    
    //holds filtered users
    NSMutableArray * unsorted = [NSMutableArray new];
    
    //create range timestamp
    NSDate * rangeDate = [[NSDate date] dateByAddingTimeInterval:-86400*days];
    NSString * rangeTimestamp = [NSString stringWithFormat:@"%.0f",[rangeDate timeIntervalSince1970]];
    
    //loop through pulling out values
    for (NSDictionary * user in recipes.allValues){
        
        NSString * location = user[@"location"];
        if ([location isEqualToString:canton] || [canton.lowercaseString isEqualToString:@"all"]){
            
            NSString * timestamp = user[@"createTS"];
            if (timestamp.floatValue > rangeTimestamp.floatValue || days == -1){
                [unsorted addObject:user];
            }
        }
    }
    
    //sort by score
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:false];
    NSArray * sorted = [unsorted sortedArrayUsingDescriptors:@[descriptor]];
    return sorted;
}


@end
