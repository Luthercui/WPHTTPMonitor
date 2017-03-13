//
//  WPURLSessionConfiguration.h
//  Pods
//
//  Created by cui liang on 2017/3/10.
//
//

#import <Foundation/Foundation.h>

@interface WPURLSessionConfiguration : NSObject
@property (nonatomic,assign) BOOL isSwizzle;

+ (WPURLSessionConfiguration *)defaultConfiguration;

- (void)load;

- (void)unload;
@end
