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
@synthesize currentUser;
@synthesize cantons;
@synthesize skillLevels;
@synthesize courses;

@synthesize users;
@synthesize recipes;
@synthesize scores;

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
    
    NSLog(@"donkey on save: %@", currentUser);
    
    NSMutableDictionary * profile = [NSMutableDictionary new];
    profile[@"userID"] = currentUser.userID;
    profile[@"email"] = currentUser.email;
    profile[@"name"] = currentUser.name;
    profile[@"location"] = currentUser.location;
    profile[@"bio"] = currentUser.bio;
    profile[@"exposesContact"] = currentUser.exposesContact;
    profile[@"favourites"] = currentUser.favouriteArray;
    profile[@"following"] = currentUser.followingArray;
    profile[@"recipes"] = currentUser.recipeArray;
    
    [[NSUserDefaults standardUserDefaults] setObject:profile forKey:@"profile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)loadCurrentUser {
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"profile"]){
    
        NSLog(@"HIT");
        
        NSMutableDictionary * profile = [NSMutableDictionary new];
        [profile addEntriesFromDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"profile"]];
        
        NSLog(@"profile is %@", profile);
        
        currentUser = [User new];
        currentUser.userID = profile[@"userID"];
        currentUser.email = profile[@"email"];
        currentUser.name = profile[@"name"];
        currentUser.location = profile[@"location"];
        currentUser.bio = profile[@"bio"];
        currentUser.exposesContact = profile[@"exposesContact"];
        currentUser.favouriteArray = profile[@"favourites"];
        currentUser.followingArray = profile[@"following"];
        currentUser.recipeArray = profile[@"recipes"];
        
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
     recipes = [recipeID,recipeID,recipeID]
     favourites = [redipeID,recipeID]
     following = [userID,userID,userID,userID]
     reviews = {recipeID:score,recipeID:score}
     score =
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
    }
     
    */
    users = [[NSMutableArray alloc] initWithArray:meta[@"users"]];
    recipes = [[NSMutableArray alloc] initWithArray:meta[@"recipes"]];
    scores = [[NSMutableArray alloc] initWithArray:meta[@"scores"]];
    
    NSLog(@"USERS_ %@", users);
    NSLog(@"RECIPES_ %@", recipes);
    NSLog(@"SCORES_ %@", scores);
    
    NSMutableDictionary * reviewerDictionary = [NSMutableDictionary new];
    NSMutableDictionary * reviewedDictionary = [NSMutableDictionary new];
    for (NSDictionary * dictionary in scores){
        NSString * reviewer = dictionary[@"reviewerID"];
        NSString * reviewed = dictionary[@"userID"];
        NSString * recipe = dictionary[@"recipeID"];
        NSString * score = dictionary[@"score"];
        
        //add object to reviewer dictionary
        NSMutableDictionary * rr = [NSMutableDictionary new];
        //add existing objects
        if ([reviewerDictionary.allKeys containsObject:reviewer]){
            [rr addEntriesFromDictionary:reviewerDictionary[reviewer]];
        }
        //add new object
        rr[recipe]=score;
        
        //save back in
        reviewerDictionary[reviewer]=rr;
        
        //add object to reviewed dictionary
        NSMutableDictionary * rd = [NSMutableDictionary new];
        //add existing objects
        if ([reviewedDictionary.allKeys containsObject:reviewed]){
            [rd addEntriesFromDictionary:reviewedDictionary[reviewed]];
        }
        //pull the array of scores
        NSMutableArray * rda = [NSMutableArray new];
        if ([rd valueForKey:recipe]){
            [rda addObjectsFromArray:rd[recipe]];
        }
        //add new object
        [rda addObject:score];
        //add back in
        rd[recipe]=rda;
        reviewedDictionary[reviewed]=rd;

    }
    
    NSLog(@"reviewer dictionary is %@", reviewerDictionary);
    NSLog(@"reviewed dictionary is %@", reviewedDictionary);
}

@end
