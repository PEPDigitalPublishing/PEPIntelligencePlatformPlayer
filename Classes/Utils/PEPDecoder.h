//
//  PEPDecoder.h
//  JSBridge
//
//  Created by 李沛倬 on 2017/5/15.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PEPDecoder : NSObject


/**
 将传入的数据按照特定加密规则解密，如果不是该加密规则，则返回原始数据

 @param data 加密数据
 @return 解密数据
 */
+ (NSData *)decodeWithData:(NSData *)data;


/**
 从传入的encodePath路径下读取加密数据，返回解密数据

 @param encodePath 加密数据存储路径
 @return 解密数据
 */
+ (NSData *)decodeDataWithEncodeFilePath:(NSString *)encodePath;


/**
 从encodePath路径下读取加密数据，解密之后存入decodePath路径下

 @param encodePath 加密数据存储路径
 @param decodePath 解密数据存储路径
 @return 解密数据写入decodePath路径是否成功
 */
+ (BOOL)decodeDataWithEncodeFilePath:(NSString *)encodePath decodeFilePath:(NSString *)decodePath;


@end












