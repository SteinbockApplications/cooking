//
//  Fish.h
//  CC0
//
//  Created by Duncan Geoghegan on 30/06/15.
//  Copyright (c) 2015 Steinbock Applications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fish : NSObject
+(id)sharedInstance;
-(BOOL)checkExists:(NSString *)filename inFolder:(NSString *)folder;
-(NSString *)filePathForFilename:(NSString *)filename inFolder:(NSString *)folder;
-(void)saveData:(NSData *)data toFilename:(NSString *)filename inFolder:(NSString *)folder;

-(void)deleteFile:(NSString *)filename inFolder:(NSString *)folder;
-(void)deleteLargeFiles;

@end
