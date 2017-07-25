//
//  FirebaseUploadUtil.m
//  SampleLP
//
//  Created by Vidhur Voora on 7/25/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

#import "FirebaseUploadUtil.h"
@import UIKit;
@import FirebaseCore;
@import FirebaseStorage;

@implementation FirebaseUploadUtil

+ (void)uploadFile:(UIImage *)image path:(NSString *)path metaData:(NSDictionary *)customData {
    
    // Get a reference to the storage service using the default Firebase App
    FIRStorage *storage = [FIRStorage storage];
    
    
    // Create a storage reference from our storage service
    FIRStorageReference *storageRef = [storage reference];
    
    // Create a reference to the file you want to upload
    FIRStorageReference *carRef = [storageRef child:path];
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    metadata.customMetadata = customData;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    
    // Upload the file to the path "images/rivers.jpg"
    FIRStorageUploadTask *uploadTask = [carRef putData:imageData
                                              metadata:metadata
                                            completion:^(FIRStorageMetadata *metadata,
                                                         NSError *error) {
                                                if (error != nil) {
                                                    // Uh-oh, an error occurred!
                                                    NSLog(@"Error");
                                                } else {
                                                    // Metadata contains file metadata such as size, content-type, and download URL.
                                                    NSURL *downloadURL = metadata.downloadURL;
                                                    NSLog(@"%@",downloadURL);
                                                }
                                            }];
}
@end
