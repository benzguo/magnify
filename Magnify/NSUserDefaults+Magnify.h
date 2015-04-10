//
//  NSUserDefaults+Magnify.h
//  Magnify
//
//  Created by Ben Guo on 4/10/15.
//  Copyright (c) 2015 Net Sadness. All rights reserved.
//

#import <Foundation/Foundation.h>

/// The properties in NSUserDefaults+GroundControl aren't accessible in Swift
@interface NSUserDefaults (Magnify)

/// Adds "text/plain" to the serializer's acceptable content types
+ (void)configureResponseSerializer;

@end
