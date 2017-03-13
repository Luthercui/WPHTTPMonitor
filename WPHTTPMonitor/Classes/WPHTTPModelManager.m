//
//  WPHTTPModelManager.m
//  Pods
//
//  Created by cui liang on 2017/3/10.
//
//

#import "WPHTTPModelManager.h"

@interface WPHTTPModelManager ()
{
    NSMutableArray *allRequests;
    NSMutableArray *allMapRequests;
}
@end

@implementation WPHTTPModelManager

- (id)init {
    self = [super init];
    if (self) {
        allRequests = [NSMutableArray arrayWithCapacity:1];
        allMapRequests = [NSMutableArray arrayWithCapacity:1];

    }
    return self;
}

+ (WPHTTPModelManager *)defaultManager {
    
    static WPHTTPModelManager *staticManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticManager=[[WPHTTPModelManager alloc] init];
    });
    return staticManager;
    
}
- (void)addModel:(WPHTTPModel *) aModel{
    [allRequests addObject:aModel];
}

- (NSMutableArray *)allobjects{
    return allRequests;
}

- (void) deleteAllItem{
    [allRequests removeAllObjects];
}

- (NSMutableArray *)allMapObjects{
    return allMapRequests;
}

- (void)addMapObject:(WPHTTPModel *)mapReq{
    [allMapRequests addObject:mapReq];
}

- (void)removeMapObject:(WPHTTPModel *)mapReq{
    
}

- (void)removeAllMapObjects{
        [allMapRequests removeAllObjects];
}


@end
