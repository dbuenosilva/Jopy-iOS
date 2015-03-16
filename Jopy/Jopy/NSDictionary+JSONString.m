//
//  NSDictionary+JSONString.m
//  Transparencia
//
//  Created by Edson Teco on 23/06/14.
//  Copyright (c) 2014 Transparenciapp. All rights reserved.
//

#import "NSDictionary+JSONString.h"

@implementation NSDictionary (JSONString)

- (NSString *)jsonString
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        return @"{}";
    }
    else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
