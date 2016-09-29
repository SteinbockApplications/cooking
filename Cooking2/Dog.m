//
//  Dog.m
//  car4rep
//
//  Created by Duncan Geoghegan on 29/10/15.
//  Copyright © 2015 Steinbock Applications. All rights reserved.
//

#import "Dog.h"
#import "Donkey.h"
#import "Fish.h"
//#import "Harbour.h"

@implementation Dog {
    
    Fish * _fish;
  //  Harbour * _harbour;
    
    Donkey * _donkey;
    NSMutableArray * fetchArray;
    
}
static Dog *sharedInstance = nil;
+ (Dog *)sharedInstance {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}
- (id)init {
    self = [super init];
    if (self) {
            _fish = [Fish sharedInstance];
      //  _harbour = [Harbour sharedInstance];
        
        _donkey = [Donkey sharedInstance];
        fetchArray = [NSMutableArray new];
    }
    return self;
}


-(void)updateFavouriteOnServerForMediaID:(NSString *)mediaID isUpVote:(bool)isUpVote {
    
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    //Create an URLRequest
    NSURL * url = [NSURL URLWithString:@"http://steinbockapplications.com/other/zeroApp/php/favourite.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //Create POST Params and add it to HTTPBody
    NSString * postString = [NSString stringWithFormat:@"username=Ghost&password=65j8krP2&mediaID=%@&isUpVote=%i",mediaID,isUpVote];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Create task
    NSURLSessionDataTask * dataTask =[defaultSession
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          NSLog(@"DATA STRING IS %@", dataString);
                                          
                                      }];
    [dataTask resume];
    
    
}
-(void)updateFlagOnServerForMediaID:(NSString *)mediaID flag:(NSString *)flag shouldRemove:(bool)shouldRemove {
    
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    //Create an URLRequest
    NSURL * url = [NSURL URLWithString:@"http://steinbockapplications.com/other/zeroApp/php/flag.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //Create POST Params and add it to HTTPBody
    NSString * postString = [NSString stringWithFormat:@"username=Ghost&password=65j8krP2&mediaID=%@&flag=%@&shouldRemove=%i",mediaID,flag,shouldRemove];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Create task
    NSURLSessionDataTask * dataTask =[defaultSession
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          NSLog(@"DATA STRING IS %@", dataString);
                                          
                                      }];
    [dataTask resume];
    
    
}
/*
-(void)syncroniseFiles:(NSArray *)vendors{
 
    //go through the vendor objects downloaded, and pull out the file attributes
    //check if the file names exist on the device --> if they do, ok, if not, fetch them
    //then check what is on the device but no longer in the latest vendor filelist --> delete
    
    
    Fish * _fish = [Fish sharedInstance];
    NSMutableDictionary * fullFileManifest = [NSMutableDictionary new];
    for (VendorObject * v in vendors){

        NSMutableArray * filesForVendor = [NSMutableArray new];
        if (v.photos.count>0){[filesForVendor addObjectsFromArray:v.photos];}
        if (v.profileImage.length>0){[filesForVendor addObject:v.profileImage];}
        if (v.heroImage.length>0){[filesForVendor addObject:v.heroImage];}
        if (v.logoImage.length>0){[filesForVendor addObject:v.logoImage];}

        for (NSString * filename in filesForVendor){
            if (![_fish checkExists:filename forFolder:v.folder]){
                [self fetchFile:filename forFolder:v.folder];
            }
        }
        
        fullFileManifest[v.folder] = filesForVendor;
    }
    
    //now go through the full manifest file and see if there's anything saved to the device
    //that is no longer required.
    [_fish deleteOldFiles:fullFileManifest];

}

-(void)fetchFile:(NSString *)file forFolder:(NSString *)folder {

    NSLog(@"fetch file: %@", file);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        
        NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        
        //Create an URLRequest
        NSURL * url = [NSURL URLWithString:@"http://ch-coatings.biz/CMS/php/fetchFile.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        //Create POST Params and add it to HTTPBody
        NSString * postString = [NSString stringWithFormat:@"username=Ghost&password=65j8krP2&folder=%@&file=%@",folder,file];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Create task
        NSURLSessionDataTask * dataTask =[defaultSession
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              if (!data || error){
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"fileFailed" object:nil];
                                                  return;
                                                  
                                              }
                                              
                                              
                                              //NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                              //NSLog(@"datastring is %@", dataString);
                                              
                                              NSError * jsonError = nil;
                                              NSDictionary * d = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                              
                                              if (!jsonError && d){
                                                  
                                                  
                                                  NSString * incomingFilename = d[@"filename"];
                                                  NSString * incomingFolder = d[@"folder"];
                                                  NSString * base64DataString = d[@"file"];
                                                  NSData * fileData = [[NSData alloc] initWithBase64EncodedString:base64DataString options:0];

                                                  //save
                                                  Fish * _fish = [Fish sharedInstance];
                                                  [_fish saveData:fileData toFilename:incomingFilename forFolder:incomingFolder];
                                                  
                                                  
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      //inform for display updates
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"fileReady" object:[NSDictionary dictionaryWithObjectsAndKeys:incomingFilename,@"file",incomingFolder,@"folder", nil]];
                                                      
                                                      
                                                  });
                                                  
                                              }
                                              
                                          }];
        [dataTask resume];
        
        
    });
    
    
    
    
    
}
 */


//FETCH META
-(void)fetchMetaData {
    
     NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
     NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
     
     //Create an URLRequest
     NSURL * url = [NSURL URLWithString:@"http://steinbockapplications.com/other/cooking/php/scan.php"];
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
     
     //Create POST Params and add it to HTTPBody
     NSString * postString = @"username=Ghost&password=65j8krP2";
     [request setHTTPMethod:@"POST"];
     [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
     
     //Create task
     NSURLSessionDataTask * dataTask =[defaultSession
     dataTaskWithRequest:request
     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     
     //NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     //NSLog(@"DATA STRING IS %@", dataString);
     NSError * jsonError = nil;
     NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
     if (jsonError){
         NSLog(@"JSON ERROR: %@", jsonError.description);
     } else {
         [_donkey parseMeta:dictionary];
     }
     
     
     }];
     [dataTask resume];
    
    
}

//FETCH FILE
-(NSString *)fetchFileFromPath:(NSString *)path withCallback:(NSString *)callback {
    
    
    NSString * filename = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //NSLog(@"filename is %@", filename);
    
    //does not allow overwriting
    if ([_fish checkExists:filename]){
        return [_fish filePathForFilename:filename];
    }
    //if it's already being pulled
    if (![fetchArray containsObject:filename]){
        [fetchArray addObject:filename];
    } else {
        return nil;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.steinbockapplications.com/other/cooking/users/%@",path]];
        NSData * data = [NSData dataWithContentsOfURL:url];
        NSLog(@"url is %@", url);
        if (data){
            
            [_fish saveData:data toFilename:filename];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFileReady" object:callback userInfo:@{@"path":[_fish filePathForFilename:filename]}];
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFileFailed" object:callback];
            });
            
        }
    });
    
    return nil;
}

//UPDATING USER
-(void)checkUsernameIsAvailable:(NSString *)username {
    
}
-(void)updateUser:(NSDictionary *)dictionary {
    
    NSString * timestamp = dictionary[@"timestamp"]; //string
    NSString * userID = dictionary[@"userID"]; //string
    NSString * dbUser = @"Ghost";
    NSString * dbPassword = @"65j8krP2";
    
    NSString * name = dictionary[@"name"]; //string
    NSString * email = dictionary[@"email"]; //string
    NSString * password = dictionary[@"password"]; //string
    NSString * location = dictionary[@"location"]; //string
    NSString * bio = dictionary[@"bio"]; //string
    NSString * skill = dictionary[@"skill"]; //string
    NSString * exposeContact = dictionary[@"exposesContact"]; //string
    NSString * newUser = dictionary[@"newUser"]; //string
    
    UIImage * image = dictionary[@"original"]; //image
    UIImage * thumb = dictionary[@"thumb"]; //image
    NSData * imageData = UIImageJPEGRepresentation(image, 0.6);
    NSData * thumbData = UIImageJPEGRepresentation(thumb, 0.6);
    
    

    NSLog(@"received: %@", dictionary);

    
    //build the data
    NSString * boundary = @"--->boundary<---";
    NSMutableData * body = [NSMutableData data];

    //DATABASE
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"dbUser"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", dbUser] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"dbPassword"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", dbPassword] dataUsingEncoding:NSUTF8StringEncoding]];

    //timestamp
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"timestamp"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", timestamp] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //userID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"userID"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", userID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //name
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"name"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //email
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"email"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", email] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //password
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"password"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", password] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //location
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"location"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", location] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //bio
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"bio"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", bio] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //skill
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"skill"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", skill] dataUsingEncoding:NSUTF8StringEncoding]];

    //exposesContact
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"exposeContact"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", exposeContact] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //newUser
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"newUser"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", newUser] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    //image data is not always provided
    //only when there is a change in image
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"imageData.jpg\"\r\n", @"imageData"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (thumbData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"thumbData.jpg\"\r\n", @"thumbData"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:thumbData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    

    //close
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"api-key"       : @"55e76dc4bbae25b066cb",
                                                   @"Accept"        : @"application/json",
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSString * uploadPath = @"http://steinbockapplications.com/other/cooking/php/userEdit.php";
    NSURL *url = [NSURL URLWithString:uploadPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataString is %@", dataString);
        if ([dataString containsString:@"SUCCESS"]){
            [self performSelectorOnMainThread:@selector(submitSuccess) withObject:nil waitUntilDone:false];
        } else {
            [self performSelectorOnMainThread:@selector(submitFailure) withObject:nil waitUntilDone:false];
        }
        
        //NSError * jsonError = nil;
        //NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    }];
    [uploadTask resume];

}
-(void)submitSuccess {
    NSLog(@"submit success");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserUpdateSuccess" object:nil];
}
-(void)submitFailure{
    NSLog(@"submit failure");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserUpdateFailure" object:nil];
}



-(void)updateRecipe:(NSDictionary *)dictionary {
    

    NSString * dbUser = @"Ghost";
    NSString * dbPassword = @"65j8krP2";

    NSString * timestamp = dictionary[@"timestamp"]; //string
    NSString * userID = dictionary[@"userID"]; //string
    NSString * recipeID = dictionary[@"recipeID"];
    
    NSString * recipeName = dictionary[@"recipeName"];
    NSString * duration = dictionary[@"duration"];
    NSString * difficulty = dictionary[@"difficulty"];
    NSString * course = dictionary[@"course"];
    NSString * introduction = dictionary[@"introduction"];
    NSString * ingredients = dictionary[@"ingredients"];
    NSString * instructions = dictionary[@"instructions"];
    NSDictionary * mediaDictionary = dictionary[@"mediaDictionary"];

    NSData * heroData;
    NSData * videoThumbData;
    NSData * a0Data;
    NSData * a1Data;
    NSData * a2Data;
    NSData * a3Data;

    if (mediaDictionary[@"hero"]){
        UIImage * image = mediaDictionary[@"hero"];
        heroData = UIImageJPEGRepresentation(image, 0.6);
    }
    //VIDEO
    if (mediaDictionary[@"videoThumb"]){
        UIImage * image = mediaDictionary[@"videoThumb"];
        videoThumbData = UIImageJPEGRepresentation(image, 0.6);
    }
    if (mediaDictionary[@"a0"]){
        UIImage * image = mediaDictionary[@"a1"];
        a0Data = UIImageJPEGRepresentation(image, 0.6);
    }
    if (mediaDictionary[@"a1"]){
        UIImage * image = mediaDictionary[@"a1"];
        a1Data = UIImageJPEGRepresentation(image, 0.6);
    }
    if (mediaDictionary[@"a2"]){
        UIImage * image = mediaDictionary[@"a2"];
        a2Data = UIImageJPEGRepresentation(image, 0.6);
    }
    if (mediaDictionary[@"a3"]){
        UIImage * image = mediaDictionary[@"a3"];
        a3Data = UIImageJPEGRepresentation(image, 0.6);
    }


    NSLog(@"received: %@", dictionary);

    //build the data
    NSString * boundary = @"--->boundary<---";
    NSMutableData * body = [NSMutableData data];
    
    //DATABASE
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"dbUser"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", dbUser] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"dbPassword"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", dbPassword] dataUsingEncoding:NSUTF8StringEncoding]];

    //userID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"userID"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", userID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //recipeID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"recipeID"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", recipeID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //timestamp
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"timestamp"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", timestamp] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //recipe name
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"recipeName"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", recipeName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //duration
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"duration"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", duration] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //difficulty
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"difficulty"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", difficulty] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //course
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"course"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", course] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //introduction
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"introduction"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", introduction] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //ingredients
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"ingredients"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", ingredients] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //instructions
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"instructions"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", instructions] dataUsingEncoding:NSUTF8StringEncoding]];
    
   
    if (heroData) {
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"hero.jpg\"\r\n", @"heroData"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:heroData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (videoThumbData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"videoThumb.jpg\"\r\n", @"videoThumbData"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:videoThumbData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (a0Data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"a0.jpg\"\r\n", @"a0Data"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:a0Data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (a1Data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"a1.jpg\"\r\n", @"a1Data"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:a1Data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (a2Data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"a2.jpg\"\r\n", @"a2Data"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:a2Data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (a3Data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"a3.jpg\"\r\n", @"a3Data"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:a3Data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    
    
    /*
     if (thumbData) {
     [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"thumbData.jpg\"\r\n", @"thumbData"] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:thumbData];
     [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
     }
   */
    
    //close
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"api-key"       : @"55e76dc4bbae25b066cb",
                                                   @"Accept"        : @"application/json",
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSString * uploadPath = @"http://steinbockapplications.com/other/cooking/php/recipeEdit.php";
    NSURL *url = [NSURL URLWithString:uploadPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataString is %@", dataString);
        if ([dataString containsString:@"SUCCESS"]){
            [self performSelectorOnMainThread:@selector(recipeSubmitSuccess) withObject:nil waitUntilDone:false];
        } else {
            [self performSelectorOnMainThread:@selector(recipeSubmitFailure) withObject:nil waitUntilDone:false];
        }
        
        //NSError * jsonError = nil;
        //NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    }];
    [uploadTask resume];

     
  /*   */
    
}

-(void)recipeSubmitSuccess {
    NSLog(@"recipeSubmitSuccess");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRecipeSubmitFailure" object:nil];
}
-(void)recipeSubmitFailure{
    NSLog(@"recipeSubmitFailure");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRecipeSubmitFailure" object:nil];
}

-(void)updateUserProfile:(NSDictionary *)dictionary {
    
      /* 
    NSString * timestamp = dictionary[@"timestamp"]; //string
    NSString * uniqueID = dictionary[@"userID"]; //string
    NSString * username = @"Ghost";
    NSString * password = @"65j8krP2";
    
    NSString * name = dictionary[@"name"]; //string
    NSString * author = dictionary[@"username"]; //string
    NSString * keywords = dictionary[@"password"]; //string
    NSString * location = dictionary[@"location"]; //string
    NSString * filter = dictionary[@"bio"]; //string
    NSString * colours = dictionary[@"allowed"]; //string

    UIImage * image = dictionary[@"image"]; //image
    UIImage * thumb = dictionary[@"thumb"]; //image
    NSData * imageData = UIImageJPEGRepresentation(image, 0.6);
    NSData * thumbData = UIImageJPEGRepresentation(thumb, 0.6);
    
    //NSData * videoData = dictionary[@"videoData"]; //data
    //NSArray * videoThumbs = dictionary[@"videoFrames"]; //images
    


    NSLog(@"received: %@", dictionary);
 
    
    //build the data
    NSString * boundary = @"--->boundary<---";
    NSMutableData * body = [NSMutableData data];
 
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"username"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", username] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"password"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", password] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"timestamp"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", timestamp] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"uniqueID"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", uniqueID] dataUsingEncoding:NSUTF8StringEncoding]];
    

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"name"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"author"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", author] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"keywords"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", keywords] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"category"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", category] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"location"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", location] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"filter"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", filter] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"colours"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", colours] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"imageData.jpg\"\r\n", @"imageData"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (thumbData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"thumbData.jpg\"\r\n", @"thumbData"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:thumbData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //close
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"api-key"       : @"55e76dc4bbae25b066cb",
                                                   @"Accept"        : @"application/json",
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSString * uploadPath = @"http://steinbockapplications.com/other/zeroApp/php/submit.php";
    NSURL *url = [NSURL URLWithString:uploadPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataString is %@", dataString);
        if ([dataString containsString:@"SUCCESS"]){
           [self performSelectorOnMainThread:@selector(submitSuccess) withObject:nil waitUntilDone:false];
        } else {
           [self performSelectorOnMainThread:@selector(submitFailure) withObject:nil waitUntilDone:false];
        }
  
        //NSError * jsonError = nil;
        //NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    }];
    [uploadTask resume];
    */
    

    
}



-(void)voteOnRecipe:(NSString *)recipeID
         forVoterID:(NSString *)voterID
         forOwnerID:(NSString *)ownerID
           withVote:(int)vote {

    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    //Create an URLRequest
    NSURL * url = [NSURL URLWithString:@"http://steinbockapplications.com/other/cooking/php/vote.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //Create POST Params and add it to HTTPBody
    NSString * postString = [NSString stringWithFormat:@"dbUser=Ghost&dbPassword=65j8krP2&recipeID=%@&voterID=%@&ownerID=%@&vote=%i",recipeID,voterID,ownerID,vote];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Create task
    NSURLSessionDataTask * dataTask =[defaultSession
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          //NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          //NSLog(@"DATA STRING IS %@", dataString);
                                          
                                      }];
    [dataTask resume];
    
    
}
@end
