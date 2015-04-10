//
//  NSUserDefaults+Magnify.m
//  Magnify
//
//  Created by Ben Guo on 4/10/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

#import "NSUserDefaults+Magnify.h"
#import "NSUserDefaults+GroundControl.h"
#import "AFNetworking.h"

@implementation NSUserDefaults (Magnify)

+ (void)configureResponseSerializer
{
    AFPropertyListResponseSerializer *serializer = [AFPropertyListResponseSerializer serializer];
    serializer.acceptableContentTypes = [[NSSet alloc] initWithArray:@[@"application/x-plist",
                                                                       @"text/plain"]];
    [[NSUserDefaults standardUserDefaults] setResponseSerializer:serializer];
}

@end
