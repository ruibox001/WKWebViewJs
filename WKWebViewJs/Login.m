//
//  NativeModel.m
//  WKWebViewJs
//
//  Created by 王声远 on 2018/8/25.
//  Copyright © 2018年 王声远. All rights reserved.
//

#import "Login.h"

@implementation Login

- (void)loginLog:(NSDictionary *)data {
    NSLog(@"loginLog执行了，参数是： %@",data);
    
    NSDictionary *p = @{@"msg":@"Login执行完成回调JS",@"code":@"200"};
    [self callBackJs:p handler:nil];
}

@end
