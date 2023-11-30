//
//  PEPDecoder.m
//  JSBridge
//
//  Created by 李沛倬 on 2017/5/15.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "PEPDecoder.h"
#import <CommonCrypto/CommonCryptor.h>


typedef NS_ENUM(NSUInteger, PEPDecodeType) {
    PEPDecodeTypeUnknow,
    PEPDecodeTypeDefault    = 11,           // 11号加密规则：普通文件
    PEPDecodeTypeZIP        = 12,           // 12号加密规则：zip
};

static NSString *const DECODERKEY   = @"rjsz2012+$&#2017";
static NSString *const FILESIGN     = @"rjsz";
const Byte ivBytes[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};

@implementation PEPDecoder

#pragma mark - Public Methods
+ (BOOL)decodeDataWithEncodeFilePath:(NSString *)encodePath decodeFilePath:(NSString *)decodePath {
    NSData *decodeData = [self decodeDataWithEncodeFilePath:encodePath];
    return [decodeData writeToFile:decodePath atomically:true];
    
}

+ (NSData *)decodeDataWithEncodeFilePath:(NSString *)encodePath {
    NSData *encodeData = [NSData dataWithContentsOfFile:encodePath];
    
    if (encodeData.length == 0) { return nil; }
    
    return [self decodeWithData:encodeData];
}


+ (NSData *)decodeWithData:(NSData *)data {
    NSInteger pointer = 0;
    
    // 获取文件标识
    NSData *fileSignData = [data subdataWithRange:NSMakeRange(pointer, 4)];
    NSString *fileSignStr = [[NSString alloc] initWithData:fileSignData encoding:NSUTF8StringEncoding];
    if (![fileSignStr isEqualToString:FILESIGN]) { return data; }
    pointer += 4;
    
    
    // 判断加密规则
    NSData *algorithmData = [data subdataWithRange:NSMakeRange(pointer, 1)];
    PEPDecodeType type = *(PEPDecodeType*)(algorithmData.bytes);
    pointer += 1;
    
    // 获取描述长度
    NSData *descLengthData = [data subdataWithRange:NSMakeRange(pointer, 4)];
    NSInteger descLength = *(NSInteger*)(descLengthData.bytes);
    pointer += 4;
    // 打印描述内容并确定正文位置
//    NSData *descContentData = [data subdataWithRange:NSMakeRange(pointer, descLength)];
//    NSString *descContentStr = [[NSString alloc] initWithData:descContentData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", descContentStr);
    pointer += descLength;
    
    // 解密正文
    NSData *bodyData = [data subdataWithRange:NSMakeRange(pointer, data.length-pointer)];
    NSData *decodeData = [self decodeBodyData:bodyData type:type];
    
    return decodeData;
}



+ (NSData *)decodeBodyData:(NSData *)data type:(PEPDecodeType)type {
    
    NSInteger seek = 1024;
    NSInteger pointer = 0;
    NSMutableData *decodeData = [NSMutableData data];
    
    @autoreleasepool {
        if (pointer + seek < data.length) {
            if (type == PEPDecodeTypeDefault) {
                
                NSData *subData = [data subdataWithRange:NSMakeRange(pointer, seek)];
                NSData *subDecodeData = aesDecryptData(subData, [DECODERKEY dataUsingEncoding:NSUTF8StringEncoding]);
                [decodeData appendData: subDecodeData];
                pointer += seek;
                NSData *lastData = [data subdataWithRange:NSMakeRange(pointer, data.length-pointer)];
                [decodeData appendData:lastData];
                
            } else if (type == PEPDecodeTypeZIP) {
                
                while (pointer + seek <= data.length) {
                    NSData *subData = [data subdataWithRange:NSMakeRange(pointer, seek)];
                    NSData *subDecodeData = aesDecryptData(subData, [DECODERKEY dataUsingEncoding:NSUTF8StringEncoding]);
                    [decodeData appendData:subDecodeData];
                    pointer += seek;
                }
                
                NSData *lastData = [data subdataWithRange:NSMakeRange(pointer, data.length-pointer)];
                [decodeData appendData:lastData];
            }
            
        } else {
            [decodeData appendData:[data subdataWithRange:NSMakeRange(pointer, data.length-pointer)]];
        }
    }

    
    return decodeData;
}



#pragma mark - Private Methods
NSData * cipherOperation(NSData *contentData, NSData *keyData, CCOperation operation) {
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus cryptStatus = CCCryptorCreateWithMode(operation,
                                                          kCCModeCFB,
                                                          kCCAlgorithmAES128,
                                                          ccNoPadding,
                                                          ivBytes,
                                                          keyData.bytes,
                                                          keyData.length,
                                                          NULL,
                                                          0,
                                                          0,
                                                          kCCModeOptionCTR_BE,
                                                          &cryptor);
    NSMutableData *returnData = [NSMutableData data];
    NSMutableData *buffer = [NSMutableData data];
    [buffer setLength:CCCryptorGetOutputLength(cryptor, contentData.length, true)];
    
    size_t dataOutMoved;
    cryptStatus = CCCryptorUpdate(cryptor, contentData.bytes, contentData.length, buffer.mutableBytes, buffer.length, &dataOutMoved);
    
    if (cryptStatus == kCCSuccess) {
        [returnData appendData:[buffer subdataWithRange:NSMakeRange(0, dataOutMoved)]];
        cryptStatus = CCCryptorFinal(cryptor, buffer.mutableBytes, buffer.length, &dataOutMoved);
        
        if (cryptStatus == kCCSuccess) {
            [returnData appendData:[buffer subdataWithRange:NSMakeRange(0, dataOutMoved)]];
            CCCryptorRelease(cryptor);
        }
    }
    
    return [returnData copy];
}

NSString * aesEncryptString(NSString *content, NSString *key) {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encrptedData = aesEncryptData(contentData, keyData);
    return [encrptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

NSString * aesDecryptString(NSString *content, NSString *key) {
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decryptedData = aesDecryptData(contentData, keyData);
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

NSData * aesEncryptData(NSData *contentData, NSData *keyData) {
    return cipherOperation(contentData, keyData, kCCEncrypt);
}

NSData * aesDecryptData(NSData *contentData, NSData *keyData) {
    return cipherOperation(contentData, keyData, kCCDecrypt);
}





@end





















