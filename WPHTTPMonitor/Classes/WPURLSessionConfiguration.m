//
//  WPURLSessionConfiguration.m
//  Pods
//
//  Created by cui liang on 2017/3/10.
//
//

#import "WPURLSessionConfiguration.h"
#import <objc/runtime.h>b
#import "WPHTTPMonitor.h"

@implementation WPURLSessionConfiguration

+ (WPURLSessionConfiguration *)defaultConfiguration {
    
    static WPURLSessionConfiguration *staticConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticConfiguration=[[WPURLSessionConfiguration alloc] init];
    });
    return staticConfiguration;
    
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSwizzle=NO;
    }
    return self;
}


- (void)load {
    
    self.isSwizzle=YES;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
    
}

- (void)unload {
    
    self.isSwizzle=NO;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
    
}

- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
    
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load WPURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses {
    
    return @[[WPHTTPMonitor class]];//如果需要导入其他的自定义NSURLProtocol请在这里增加，当然在使用NSURLSessionConfiguration时增加也可以
}


@end
