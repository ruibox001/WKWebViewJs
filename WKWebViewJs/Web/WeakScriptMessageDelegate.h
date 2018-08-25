//
//  WeakScriptMessageDelegate.h
//  WKWebViewJs
//
//  Created by 王声远 on 2018/8/25.
//  Copyright © 2018年 王声远. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (weak, nonatomic) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
