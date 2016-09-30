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


@synthesize ranges;
@synthesize skillLevels;
@synthesize courses;

@synthesize users;
@synthesize recipes;
@synthesize recents;


@synthesize selectedCanton;
@synthesize cantonUsers;
@synthesize cantonRecipes;
@synthesize cantonRecents;

@synthesize media;

+ (Donkey *)sharedInstance {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}
- (id)init {
    self = [super init];
    if (self) {
        
           cantons = @[@"Schweizweit",
                       @"Aargau",
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
        
        ranges = @[@"Alle",
                   @"Heute",
                   @"Woche",
                   @"Monat"];
        
    }
    return self;
}

-(void)saveCurrentUser {

    [[NSUserDefaults standardUserDefaults] setObject:deviceUser forKey:@"profile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)loadCurrentUser {
    
    NSLog(@"LOAD");
    
    //load user profile if available
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"profile"]){
        deviceUser = [[NSUserDefaults standardUserDefaults] valueForKey:@"profile"];
    }
    //load canton if available
    selectedCanton = @"Schweizweit";
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"preferredCanton"]){
        selectedCanton = [[NSUserDefaults standardUserDefaults] valueForKey:@"preferredCanton"];
    }

}
-(void)parseMeta:(NSDictionary *)meta {

    //NSLog(@"META: %@", meta);
    
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
    //NSLog(@"meta is %@", meta);
    
    
    //pull the user data
    NSMutableArray * userArray = [[NSMutableArray alloc] initWithArray:meta[@"users"]];
    
    //init the users dictionary
    users = [NSMutableDictionary new];
    
    //add the content for the user key
    for (NSDictionary * user in userArray){
        
        NSMutableDictionary * mUser = [[NSMutableDictionary alloc] initWithDictionary:user];
        mUser[@"type"]=@"user";
        users[user[@"userID"]]=mUser;
    }
    

    //pull the recipe data
    NSMutableArray * recipeArray = [[NSMutableArray alloc] initWithArray:meta[@"recipes"]];
    
    //init the recipes dictionary
    recipes = [NSMutableDictionary new];
    
    //go through the recipes
    for (NSMutableDictionary * recipe in recipeArray){
        
        NSString * userName;
        NSString * location;
        NSString * recipeID = recipe[@"recipeID"];
        NSString * userID = recipe[@"userID"];
        
        //pull the user data for that recipe
        if (users[userID]){
            //create a mutable --> add existing recipes
            NSMutableDictionary * mUser = [[NSMutableDictionary alloc] initWithDictionary:users[userID]];
            NSMutableArray * existingRecipes = [NSMutableArray new];
            [existingRecipes addObjectsFromArray:mUser[@"recipes"]];
            [existingRecipes addObject:recipeID];
            //save back in
            mUser[@"recipes"]=existingRecipes;
            users[userID]=mUser;
            //set the user name
            userName = mUser[@"name"];
            location = mUser[@"location"];
        }
        
        //create a mutable
        NSMutableDictionary * mRecipe = [[NSMutableDictionary alloc] initWithDictionary:recipe];
        //add and set
        mRecipe[@"location"]= location;
        mRecipe[@"userName"]= userName;
        mRecipe[@"type"]= @"recipe";
        recipes[recipeID] = mRecipe;
    }
    
    //SCORING
    //pull the score data
    NSMutableArray * voteArray = [[NSMutableArray alloc] initWithArray:meta[@"votes"]];
    float scoreTally = 0.0f;
    //NSLog(@"score array is %@", voteArray);
    
    //loop through adding in the scores
    for (NSDictionary * score in voteArray){
        
        NSString * recipeID = score[@"recipeID"];
        NSString * ownerID = score[@"ownerID"];
        NSString * voterID = score[@"voterID"];
        NSString * vote = score[@"vote"];
        
        //set the score for the reviewer ID
        //as this is displayed when the user
        //visits this recipe
        //--> setting the score this user has set for the other recipe id
        if (users[voterID]){
            NSMutableDictionary * mUser = [[NSMutableDictionary alloc] initWithDictionary:users[voterID]];
            NSMutableDictionary * existingScores = [[NSMutableDictionary alloc] initWithDictionary:mUser[@"reviews"]];
            existingScores[recipeID]=vote;
            mUser[@"reviews"]=existingScores;
            users[voterID]=mUser;
        }
        
        //set the score for the recipe ID
        //this is used to calculate the
        //mean average score for the recipe
        //--> setting the score for this recipe
        if (recipes[recipeID]){
            NSMutableDictionary * mRecipe = [[NSMutableDictionary alloc] initWithDictionary:recipes[recipeID]];
            NSMutableArray * existingScores = [NSMutableArray new];
            [existingScores addObjectsFromArray:mRecipe[@"scores"]];
            [existingScores addObject:vote];
            mRecipe[@"scores"]=existingScores;
            recipes[recipeID]=mRecipe;
        }
        
        //set the score for the user ID
        //this is calculated at the end
        //--> set the score for the user herself
        if (users[ownerID]){
            NSMutableDictionary * mUser = [[NSMutableDictionary alloc] initWithDictionary:users[ownerID]];
            NSMutableArray * existingScores = [NSMutableArray new];
            [existingScores addObjectsFromArray:mUser[@"scores"]];
            [existingScores addObject:vote];
            mUser[@"scores"]=existingScores;
            users[ownerID]=mUser;
        }
        
        //used to calculate total mean
        scoreTally += vote.floatValue;
    }
    
    //WEIGHTED SCORING (number of votes, mean vote)
    //need to calculate mean scores for all
    float overalMeanScore = scoreTally / voteArray.count;
    float minimumVotesRequired = 3.0f;

    //calculate averages
    for (NSMutableDictionary * user in users.allValues){
        if (user[@"scores"]){
            
            //pull data
            NSArray * scores = user[@"scores"];
            
            //calculate mean --> calculate across all reviews
            float total = 0.0f;
            int votes = (int)scores.count;
            for (NSString * scoreString in scores){ total += scoreString.floatValue;}
            float mean = total / votes;
            
            //Bayesian estimate
            float weightedAverage = (votes / (votes + minimumVotesRequired)) * mean + (minimumVotesRequired / (votes + minimumVotesRequired)) * overalMeanScore;
            if (votes < minimumVotesRequired){  weightedAverage = 0; }
            
            //save in for the user
            user[@"scores"]=nil;
            user[@"votes"]=[NSString stringWithFormat:@"%i",votes];
            user[@"score"]=[NSString stringWithFormat:@"%f",mean];
            user[@"weighted"]=[NSString stringWithFormat:@"%f",weightedAverage];
            users[user[@"userID"]]=user;
        }
    }
    
    for (NSMutableDictionary * recipe in recipes.allValues){
        
        if (recipe[@"scores"]){
            
            //pull data
            NSArray * scores = recipe[@"scores"];
            
            //calculate mean --> calculate across all reviews
            float total = 0.0f;
            int votes = (int)scores.count;
            for (NSString * scoreString in scores){ total += scoreString.floatValue;}
            float mean = total / votes;
            
            //Bayesian estimate
            float weightedAverage = (votes / (votes + minimumVotesRequired)) * mean + (minimumVotesRequired / (votes + minimumVotesRequired)) * overalMeanScore;
            if (votes < minimumVotesRequired){  weightedAverage = 0; }
            
            //save in for the recipe
            recipe[@"score"]=[NSString stringWithFormat:@"%f",mean];
            recipe[@"votes"]=[NSString stringWithFormat:@"%i",votes];
            recipe[@"weighted"]=[NSString stringWithFormat:@"%f",weightedAverage];
            recipes[recipe[@"recipeID"]]=recipe;
        }
    }
    
    //MEDIA --> pulled when needed
    media = meta[@"files"];

    
    //RECENT
    NSMutableArray * temp = [NSMutableArray new];
    for (NSString * key in users.allKeys){
        [temp addObject:users[key]];
    }
    for (NSString * key in recipes.allKeys){
        [temp addObject:recipes[key]];
    }
    
    recents = [NSArray arrayWithArray:temp];
    NSSortDescriptor * ts = [[NSSortDescriptor alloc] initWithKey:@"createTS" ascending:true];
    recents =  [recents sortedArrayUsingDescriptors:@[ts]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMetaReady" object:nil];
 
}
-(NSString *)pathForProfileForUser:(NSString *)userID isThumb:(bool)isThumb {
    
    NSLog(@"media is %@", media);
    
    
    return nil;
}

-(void)setPreferredCanton:(NSString *)canton {
    
    //set new canton and save
    selectedCanton = canton;
    [[NSUserDefaults standardUserDefaults] setObject:selectedCanton forKey:@"preferredCanton"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //sort the local values
    [self sortDataForPreferredCanton];
}
-(void)sortDataForPreferredCanton {

    cantonUsers = [self sortUsersForCanton:selectedCanton];
    cantonRecipes = [self sortRecipesForCanton:selectedCanton];
    cantonRecents = [self sortRecentsForCanton:selectedCanton];

}
-(NSArray *)sortUsersForCanton:(NSString *)canton {
    
    //holds filtered users
    NSMutableArray * unsorted = [NSMutableArray new];
    
    //loop through pulling out values
    for (NSDictionary * user in users.allValues){
        NSString * location = user[@"location"];
        if ([location isEqualToString:canton] || [canton isEqualToString:@"Schweizweit"]){
            [unsorted addObject:user];
        }
    }
    
    //sort by score
    NSSortDescriptor * scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weighted" ascending:false];
    return [unsorted sortedArrayUsingDescriptors:@[scoreDescriptor]];
}
-(NSArray *)sortRecipesForCanton:(NSString *)canton {

    //holds filtered recipes
    NSMutableArray * unsorted = [NSMutableArray new];
    
    //loop through pulling out values
    for (NSDictionary * recipe in recipes.allValues){
        NSString * location = recipe[@"location"];
        if ([location isEqualToString:canton] || [canton isEqualToString:@"Schweizweit"]){
            [unsorted addObject:recipe];
        }
    }
    
    //NSLog(@"unsorted is %@", unsorted);
    
    //sort by score
    NSSortDescriptor * weightDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weighted" ascending:false];
    NSSortDescriptor * scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:false];
    return [unsorted sortedArrayUsingDescriptors:@[weightDescriptor,scoreDescriptor]];

}
-(NSArray *)sortRecentsForCanton:(NSString *)canton {
    
    //holds filtered recipes
    NSMutableArray * unsorted = [NSMutableArray new];
    
    //loop through pulling out values
    for (NSDictionary * recent in recents){
        NSString * location = recent[@"location"];
        if ([location isEqualToString:canton] || [canton isEqualToString:@"Schweizweit"]){
            [unsorted addObject:recent];
        }
    }
    
    //sort by ts
    NSSortDescriptor * scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTS" ascending:false];
    return [unsorted sortedArrayUsingDescriptors:@[scoreDescriptor]];
    
}
-(NSDictionary *)rankingForRecipe:(NSString *)recipeID {
    
    //get data
    NSDictionary * recipe = recipes[recipeID];
    NSString * userID = recipe[@"userID"];
    NSDictionary * user = users[userID];
    NSString * location = user[@"location"];
    
    //get rank
    NSArray * national = [self sortRecipesForCanton:@"Schweizweit"];
    NSArray * cantonal = [self sortRecipesForCanton:location];
    int nationalRank = (int)[national indexOfObject:recipe]+1;
    int cantonalRank = (int)[cantonal indexOfObject:recipe]+1;

    //return star count
    NSMutableDictionary * md = [NSMutableDictionary new];
    NSArray * scores = recipe[@"scores"];
    for (NSString * score in scores){
        md[score] = [NSNumber numberWithInt:[md[score] intValue]+1];
    }
    
    //pull max
    float max = [[md.allValues valueForKeyPath:@"@max.self"] floatValue];
    
    NSMutableDictionary * mdP = [NSMutableDictionary new];
    for (NSString * key in md.allKeys){
        mdP[key]= [NSNumber numberWithFloat:100 / (max / [md[key] floatValue])];
    }
    
    NSDictionary * package = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:nationalRank],@"national",
                              [NSNumber numberWithInt:cantonalRank],@"cantonal",
                              md,@"count",
                              mdP,@"percentages", nil];
    return package;
    

}

/*
 -(void)sortForRanking:(NSArray *)array {

}


 -(NSArray *)sortUsersByScoreForCanton:(NSString *)canton inRange:(int)days {
 
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
 -(NSArray *)sortRecipesByScoreForCanton:(NSString *)canton inRange:(int)days {
 
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

 */

@end
