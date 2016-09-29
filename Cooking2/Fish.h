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
-(NSString *)filePathForFilename:(NSString *)filename;
-(BOOL)checkExists:(NSString *)filename;
-(void)saveData:(NSData *)data toFilename:(NSString *)filename;
-(void)deleteFile:(NSString *)filename;
-(void)deleteFiles;


@end
