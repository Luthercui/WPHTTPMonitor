//
//  WPHTTPModelManager.h
//  Pods
//
//  Created by cui liang on 2017/3/10.
//
//

#import <Foundation/Foundation.h>
#import "WPHTTPMonitor.h"

@class WPHTTPModel;
@interface WPHTTPModelManager : NSObject

+ (WPHTTPModelManager *)defaultManager;

- (void)addModel:(WPHTTPModel *) aModel;

- (NSMutableArray *)allobjects;
- (void) deleteAllItem;

- (NSMutableArray *)allMapObjects;
- (void)addMapObject:(WPHTTPModel *)mapReq;
- (void)removeMapObject:(WPHTTPModel *)mapReq;
- (void)removeAllMapObjects;
@end
