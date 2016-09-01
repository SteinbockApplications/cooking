//
//  Fish.m
//  CC0
//
//  Created by Duncan Geoghegan on 30/06/15.
//  Copyright (c) 2015 Steinbock Applications. All rights reserved.
//

#import "Fish.h"

@implementation Fish {
    NSFileManager *fm;
    NSString * videoFolder;
    NSString * userFolder;
    NSString * thumbsFolder;
}
static Fish * sharedInstance = nil;
+ (Fish *)sharedInstance {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}
- (id)init {
    self = [super init];
    if (self) {
        
        //create manager
        fm = [NSFileManager new];

        //create folder
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsPath = [paths objectAtIndex:0];
        
        videoFolder = [documentsPath stringByAppendingPathComponent:@"videos"];
        if (![fm fileExistsAtPath:videoFolder]){
            [fm createDirectoryAtPath:videoFolder withIntermediateDirectories:false attributes:nil error:nil];
        }
        
        userFolder = [documentsPath stringByAppendingPathComponent:@"database"];
        if (![fm fileExistsAtPath:userFolder]){
            [fm createDirectoryAtPath:userFolder withIntermediateDirectories:false attributes:nil error:nil];
        }
        
        thumbsFolder = [documentsPath stringByAppendingPathComponent:@"thumbs"];
        if (![fm fileExistsAtPath:thumbsFolder]){
            [fm createDirectoryAtPath:thumbsFolder withIntermediateDirectories:false attributes:nil error:nil];
        }
        
        /*

        */
    }
    
    return self;
}
-(NSString *)filePathForFilename:(NSString *)filename inFolder:(NSString *)folder {
    
    NSString * folderPath = videoFolder;
    if ([folder isEqualToString:@"database"]){ folderPath = userFolder; }
    else if ([folder isEqualToString:@"thumbs"]) { folderPath = thumbsFolder; }
    return [folderPath stringByAppendingPathComponent:filename];
}

-(BOOL)checkExists:(NSString *)filename inFolder:(NSString *)folder {
    
    //check vars
    if (filename.length== 0 || folder.length == 0){
        return false;
    }
    
    //check if it exists
    NSString * filePath = [self filePathForFilename:filename inFolder:folder];
    if ([fm fileExistsAtPath:filePath]) {
        return true;
    }
    
    //default false
    return false;
}
-(void)saveData:(NSData *)data toFilename:(NSString *)filename inFolder:(NSString *)folder {

    //create file path
    NSString * filePath = [self filePathForFilename:filename inFolder:folder];
    
    //save it
    [data writeToFile:filePath atomically:false];
    
    NSLog(@"saving data: %@", filename);
    
    //make sure it exists
    if ([self checkExists:filename inFolder:folder]){
        //block it from icloud back up
        NSError * error = nil;
        NSURL * url = [NSURL fileURLWithPath:filePath];
        bool success = [url setResourceValue:[NSNumber numberWithBool:true] forKey:NSURLIsExcludedFromBackupKey error:&error];
        //if it hasn't been added, delete straight away
        if (!success){
            [fm removeItemAtPath:filePath error:nil];
        }
    }
}
-(void)deleteFile:(NSString *)filename inFolder:(NSString *)folder {
    
    //create file path
    NSString * filePath = [self filePathForFilename:filename inFolder:folder];
    
    //make sure it exists
    if ([self checkExists:filename inFolder:folder]){
        //block it from icloud back up
        NSError * error = nil;
        bool success = [fm removeItemAtPath:filePath error:&error];
        if (!success){
            NSLog(@"could not delete %@", filename);
        }
    }
    
}
-(void)deleteLargeFiles {
    
    NSDirectoryEnumerator * enumerator = [fm enumeratorAtPath:videoFolder];
    NSString * filename;
    
    while (filename = [enumerator nextObject]){
        [fm removeItemAtPath:[videoFolder stringByAppendingPathComponent:filename] error:nil];
    }

    enumerator = [fm enumeratorAtPath:thumbsFolder];
    filename = @"";
    
    while (filename = [enumerator nextObject]){
        [fm removeItemAtPath:[thumbsFolder stringByAppendingPathComponent:filename] error:nil];
    }

    
    //NSArray *files = [fm contentsOfDirectoryAtPath:filePath error:nil];
    //NSLog(@"files in filter are %@", files);
  
}

@end

