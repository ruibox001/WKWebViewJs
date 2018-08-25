//
//  NativeModel.h
//  WKWebViewJs
//
//  Created by 王声远 on 2018/8/25.
//  Copyright © 2018年 王声远. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#define classNameKey    @"className"
#define funcNameKey     @"functionName"
#define parameterKey    @"parameter"
#define callBackFuncKey @"callBackFunc"

@interface JSBase : NSObject

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *callBackFunc;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *functionName;

- (void)callBackJs:(NSDictionary *)parameter handler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler;

@end
