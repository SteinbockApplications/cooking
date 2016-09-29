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
    NSString * mediaFolder;
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
        
        mediaFolder = [documentsPath stringByAppendingPathComponent:@"media"];
        if (![fm fileExistsAtPath:mediaFolder]){
            [fm createDirectoryAtPath:mediaFolder withIntermediateDirectories:false attributes:nil error:nil];
        }
    }
    
    return self;
}





-(NSString *)filePathForFilename:(NSString *)filename {
    
    return [mediaFolder stringByAppendingPathComponent:filename];
}
-(BOOL)checkExists:(NSString *)filename {
    
    //check vars
    if (filename.length== 0){
        return false;
    }

    //check if it exists
    NSString * filePath = [self filePathForFilename:filename];
    if ([fm fileExistsAtPath:filePath]) {
        return true;
    }
    
    //default false
    return false;
}
-(void)saveData:(NSData *)data toFilename:(NSString *)filename {

    //create file path
    NSString * filePath = [self filePathForFilename:filename];
    
    //save it
    [data writeToFile:filePath atomically:false];
    
    //make sure it exists
    if ([self checkExists:filename]){
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
-(void)deleteFile:(NSString *)filename {
    
    //create file path
    NSString * filePath = [self filePathForFilename:filename];
    
    //make sure it exists
    if ([self checkExists:filename]){
        NSError * error = nil;
        bool success = [fm removeItemAtPath:filePath error:&error];
        if (!success){
            NSLog(@"could not delete %@", filename);
        }
    }
    
}
-(void)deleteFiles {
    
    NSDirectoryEnumerator * enumerator = [fm enumeratorAtPath:mediaFolder];
    NSString * filename;
    
    while (filename = [enumerator nextObject]){
        [fm removeItemAtPath:[mediaFolder stringByAppendingPathComponent:filename] error:nil];
    }

    //NSArray *files = [fm contentsOfDirectoryAtPath:filePath error:nil];
    //NSLog(@"files in filter are %@", files);
  
}

@end

