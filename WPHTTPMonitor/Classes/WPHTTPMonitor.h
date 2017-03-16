//
//  WPHTTPMonitor.h
//  Pods
//
//  Created by cui liang on 2017/3/10.
//
//

#import <Foundation/Foundation.h>

#define kRequestMaxCount 250
#define kFlowCount @"kFlowCount"

@interface WPHTTPMonitor : NSURLProtocol

/**
 *  http监控开关
 */
+ (void)setEnabled:(BOOL)enabled;

/**
 *  http监控开关状态
 */
+ (BOOL)isEnabled;

@end
