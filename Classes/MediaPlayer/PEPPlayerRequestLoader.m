//
//  PEPPlayerRequestLoader.m
//  TestCoreText
//
//  Created by 李沛倬 on 2017/5/18.
//  Copyright © 2017年 PEP. All rights reserved.
//

#import "PEPPlayerRequestLoader.h"
#import "PEPDecoder.h"
#import "PEPPlayer.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface PEPPlayerRequestLoader ()<AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest *> *requestList;

@property (nonatomic, assign) NSNumber *decodeOffset;

@property (nonatomic, assign) BOOL isFile;

@property (nonatomic, assign) NSInteger endOffset;

@end

@implementation PEPPlayerRequestLoader


#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        self.requestList = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    
    for (AVAssetResourceLoadingRequest *request in self.requestList) {
        [request finishLoading];
    }
    
    for (NSURLConnection *connection in self.task.taskList) {
        [connection cancel];
    }
    self.task = nil;
    
    PZLog(@"%@ Dead!", self);
}



#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
//    PZLog(@"%@", loadingRequest);
    
    if (self.isFile) {
        [self responseFileDataWithRequest:loadingRequest];
        
        return true;
    }
    
    // 添加到请求队列
    [self.requestList addObject:loadingRequest];
    // 处理请求
    [self handleWithLoadingRequest:loadingRequest];
    
    return true;
}


- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    [self.requestList removeObject:loadingRequest];
    
}



#pragma mark - Private Methods
- (void)handleWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *interceptedURL = loadingRequest.request.URL;
    NSRange range = NSMakeRange(loadingRequest.dataRequest.currentOffset, NSIntegerMax);
    if (self.task) {
        if (self.task.downLoadingLength > 0) {      // 如果该请求正在加载...
            [self processPendingRequests];
        }
        
        //  处理往回拖 & 拖到的位置大于已缓存位置的情况
        BOOL loadLastRequest = range.location < self.task.offset;   // 往回拖
        //  拖到的位置过大，比已缓存的位置还大300kb
        BOOL tmpResourceIsNotEnoughToLoad = self.task.offset + self.task.downLoadingLength + 1024*300 < range.location;
        if (loadLastRequest || tmpResourceIsNotEnoughToLoad) {
//            PZLog(@"%ld", range.location);
            self.task.decodeOffset = self.decodeOffset.integerValue;
            [self.task setURL:interceptedURL offset:range.location];
        }
        
    } else {
        PZWeakSelf;
        self.task = [[PEPPlayerRequestTask alloc] init];
        self.task.mediaDataHandler = ^(PEPPlayerRequestTask *task) {
            [weakSelf processPendingRequests];
        };
        
        self.task.mediaInfoHandler = ^(PEPPlayerRequestTask *task, NSInteger mediaLength, NSString *mimeType) {
            loadingRequest.contentInformationRequest.contentType = mimeType;
            loadingRequest.contentInformationRequest.contentLength = mediaLength;
        };
        
        self.task.mediaFinishedHandler = ^(PEPPlayerRequestTask *task) {
            if (weakSelf.finishLoadingHandler) {
                weakSelf.finishLoadingHandler(task);
                weakSelf.decodeOffset = nil;
            }
        };
        
        self.task.mediaFailHandler = ^(PEPPlayerRequestTask *task, NSError *error) {
            if (weakSelf.finishLoadingHandler) {
                weakSelf.finishLoadingHandler(task);
                weakSelf.decodeOffset = nil;
                PZLog(@"%@", error);
            }
        };
        
        [self.task setURL:interceptedURL offset:0];
    }
    
}

- (void)processPendingRequests {
    NSMutableArray<AVAssetResourceLoadingRequest *> *requestsCompleted = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *request in self.requestList) {
        BOOL didRespondCompletely = [self respondWithDataRequest:request.dataRequest];
        [self fillInContentInfomation:request.contentInformationRequest];
//        request.response = self.task.response;
        if (didRespondCompletely) {
            [requestsCompleted addObject:request];
            [request finishLoading];
        }
    }
    
    //  删除掉已经完成了的请求
    NSMutableArray *ary = [self.requestList mutableCopy];
    [self.requestList enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([requestsCompleted containsObject:obj]) {
            [ary removeObject:obj];
        }
    }];
    self.requestList = ary;
    
}

- (void)fillInContentInfomation:(AVAssetResourceLoadingContentInformationRequest *)contentInfomationRequst {
    [contentInfomationRequst setByteRangeAccessSupported:true];
    contentInfomationRequst.contentType = self.task.mimeType;
    contentInfomationRequst.contentLength = self.task.mediaLength;

}

- (BOOL)respondWithDataRequest:(AVAssetResourceLoadingDataRequest *)dataRequest {
    if (!dataRequest || !self.task) { return false; }
    
    NSInteger startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    //  如果请求的位置 + 已缓冲了的长度 比新请求的其实位置小 - 隔了一段
    if (self.task.offset + self.task.downLoadingLength - self.task.startLocationOffset < startOffset) {
        return false;
    } else if (startOffset < self.task.offset) { //  播放器要的起始位置，在下载器下载的起始位置之前
        return false;
    } else {
        @autoreleasepool {
            NSData *encodeData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:FILEPATH]];
            NSData *decodeData = [PEPDecoder decodeWithData:encodeData];
            
//            [self save:decodeData];
            
            // 解码偏移
            if (decodeData != encodeData) {
                self.decodeOffset = @(encodeData.length - decodeData.length);
            }
            
            if ([self.task.mimeType hasPrefix:@"audio/"]) { // 是音频媒体类型
                if (self.task.mediaLength > self.task.startLocationOffset + self.task.downLoadingLength) {  // 【媒体文件总长度（最终偏移位置）】大于【开始下载偏移】+【已下载长度】
                    decodeData = [decodeData subdataWithRange:NSMakeRange(0, decodeData.length / 1024 * 1024)];
                }
            }
            
            //  可以拿到的从startOffset之后的长度
            NSInteger unreadBytes = decodeData.length - (startOffset - self.task.offset) - self.task.startLocationOffset;
            //  应该能拿到的字节数
            NSInteger numberOfBytesToRespondWith = MIN(dataRequest.requestedLength, unreadBytes);
            //  应该从本地拿的数据范围
            NSInteger location = startOffset - self.task.offset + self.task.startLocationOffset;
            
            NSRange fetchRange = NSMakeRange(location, numberOfBytesToRespondWith);
            
            //  拿到响应数据
            NSData *responseData = [decodeData subdataWithRange:fetchRange];
            if (!responseData) { return false; }
            
            //  响应请求
            [dataRequest respondWithData:responseData];
            
            //  请求结束位置
            if (self.endOffset == 0) {
                self.endOffset = startOffset + dataRequest.requestedLength; // 请求结束位置
            }
            
            //  是否获取到完整数据
            BOOL didRespondFully = numberOfBytesToRespondWith + location >= self.endOffset;
            
            if (didRespondFully) { self.endOffset = 0; }
            
//            PZLog(@"%d", didRespondFully);
//            PZLog(@"请求开始位置：%ld --- 请求结束位置：%ld", startOffset, self.endOffset);
//            PZLog(@"数据开始位置：%ld --- 数据结束位置：%ld", location, numberOfBytesToRespondWith + location);
            
            return didRespondFully;
        }
    }
}


- (void)save:(NSData *)data {
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Media/decodeSubData.mp4"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    [data writeToFile:filePath atomically:true];
    
}


- (void)responseFileDataWithRequest:(AVAssetResourceLoadingRequest *)assetResourceLoadingRequest {
    NSURLComponents *components = [NSURLComponents componentsWithURL:assetResourceLoadingRequest.request.URL resolvingAgainstBaseURL:false];
    components.scheme = @"file";
    
    AVAssetResourceLoadingDataRequest *dataRequest = assetResourceLoadingRequest.dataRequest;
    
    NSInteger startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    NSData *encodeData = [NSData dataWithContentsOfURL:components.URL];
    NSData *decodeData = [PEPDecoder decodeWithData:encodeData];
    
    NSInteger requestLength = startOffset + dataRequest.requestedLength > decodeData.length ? decodeData.length - startOffset : dataRequest.requestedLength;
    
    NSRange fetchRange = NSMakeRange(startOffset, requestLength);
    
    NSData *responseData = [decodeData subdataWithRange:fetchRange];
//    PZLog(@"%@", NSStringFromRange(fetchRange));
    
    

    [assetResourceLoadingRequest.contentInformationRequest setByteRangeAccessSupported:true];
    assetResourceLoadingRequest.contentInformationRequest.contentType = [self getMimeTypeWithFilePath:assetResourceLoadingRequest.request.URL.relativePath];
    assetResourceLoadingRequest.contentInformationRequest.contentLength = decodeData.length;
    //  响应请求
    [dataRequest respondWithData:responseData];
    [assetResourceLoadingRequest finishLoading];

}


- (NSString *)getMimeTypeWithFilePath:(NSString *)filePath {
    
    CFStringRef UTi = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)([filePath pathExtension]), NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTi, kUTTagClassMIMEType);
    
    NSString *mimeType = (__bridge NSString *)(MIMEType);
    
    CFRelease(UTi);
    CFRelease(MIMEType);
    
    PZLog(@"媒体文件MIMEType：%@", mimeType);
    
    return mimeType.length == 0 ? @"video/mp4" : mimeType;
}


#pragma mark - Public Methods
- (NSURL *)exchangeSchemeWithURL:(NSURL *)url {
    if (!url) {return nil; }
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
    
    if ([urlComponents.scheme hasPrefix:@"file"]) {
        self.isFile = [urlComponents.scheme hasPrefix:@"file"];
        urlComponents.scheme = @"PEPStreaming";
    }
    
    return urlComponents.URL;
}

- (void)cancel {
    
    [self.task cancel];
    self.task = nil;
    
    for (AVAssetResourceLoadingRequest *request in self.requestList) {
        [request finishLoading];
    }
}

@end







