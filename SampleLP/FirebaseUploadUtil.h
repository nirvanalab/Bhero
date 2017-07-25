//
//  FirebaseUploadUtil.h
//  SampleLP
//
//  Created by Vidhur Voora on 7/25/17.
//  Copyright © 2017 Vidhur Voora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<UIKit/UIKit.h>

@interface FirebaseUploadUtil : NSObject

+ (void)uploadFile:(UIImage *)image path:(NSString *)path metaData:(NSDictionary *)customData;

@end
