//
//  NativeModel.m
//  WKWebViewJs
//
//  Created by 王声远 on 2018/8/25.
//  Copyright © 2018年 王声远. All rights reserved.
//

#import "JSBase.h"

@implementation JSBase

- (void)callBackJs:(NSDictionary *)parameter handler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    NSString *p = [self convertToJsonData:parameter];
    [self runJs:[NSString stringWithFormat:@"%@(%@)",self.callBackFunc,p] handler:^(id _Nullable i, NSError * _Nullable error) {
        NSLog(@"finish callback: error=%@ obj=%@",error,i);
        if (completionHandler) {
            completionHandler(i,error);
        }
    }];
}

- (void)runJs:(NSString *)js handler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler{
    if (self.webView) {
        [self.webView evaluateJavaScript:js completionHandler:completionHandler];
    }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end
