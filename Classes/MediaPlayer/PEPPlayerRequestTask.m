//
//  PEPPlayerRequestTask.m
//  TestCoreText
//
//  Created by 李沛倬 on 2017/5/19.
//  Copyright © 2017年 PEP. All rights reserved.
//

#import "PEPPlayerRequestTask.h"
#import "PEPPlayer.h"

static NSInteger const MAX_BUFFER_SIZE = 30 * 1024;

@interface PEPPlayerRequestTask ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSFileHandle *filehandle;
@property (nonatomic, assign) BOOL once;

@property (nonatomic, strong) NSMutableData *bufferData;

@end

@implementation PEPPlayerRequestTask

#pragma mark - Life Cycle
-(instancetype)init {
    if (self = [super init]) {
        self.taskList = [NSMutableArray array];
        self.bufferData = [NSMutableData dataWithCapacity:MAX_BUFFER_SIZE];
        [self initTmpDirectory];
    }
    return self;
}

- (void)dealloc {
    
    [self.filehandle closeFile];
    PZLog(@"%@ Dead!", self);
}


#pragma mark - Init Config
- (void)initTmpDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    [fileManager createDirectoryAtPath:TMPPATH withIntermediateDirectories:true attributes:nil error:nil];
    if ([fileManager fileExistsAtPath:FILEPATH]) {
        [fileManager removeItemAtPath:FILEPATH error:nil];
    }
    [fileManager createFileAtPath:FILEPATH contents:nil attributes:nil];
    
}

- (void)updateFilePath {
    [self initTmpDirectory];
}

#pragma mark - Public Methods 
- (void)setURL:(NSURL *)URL offset:(NSInteger)offset {
    
    self.URL = URL;
    self.offset = offset;
    
    if (self.taskList.count >= 1) {
        [self initTmpDirectory];
    }
    
    self.downLoadingLength = 0;
    
    // 重置scheme
    URL = [self resetURLSchemeWithURL:URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    
    //  若非从头下载，且视频长度已知且大于零，则下载offset到mediaLength的范围（拼request参数）
    if (offset > 0 && self.mediaLength > 0) {
//        PZLog(@"%ld", offset + self.decodeOffset);
        
        NSInteger downloadOffset = [self getDownloadOffsetWithRequestOffset:offset];
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", downloadOffset, (self.mediaLength+self.decodeOffset)] forHTTPHeaderField:@"Range"];
    }
    
    [self resetConnectionWithRequest:request];
}

- (void)cancel {
    [self.connection cancel];
    [self.filehandle closeFile];
    [[NSFileManager defaultManager] removeItemAtPath:FILEPATH error:nil];
    
}



#pragma mark - Private Methods 
- (NSURL *)resetURLSchemeWithURL:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
    components.scheme = @"http";
    return components.URL;
}


- (void)resetConnectionWithRequest:(NSURLRequest *)request {
    [self.connection cancel];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:false];
    [self.connection setDelegateQueue:NSOperationQueue.mainQueue];
    [self.connection start];
}


- (NSInteger)getDownloadOffsetWithRequestOffset:(NSInteger)offset {
    NSInteger seek = 1024;
    NSInteger downloadOffset = 0;
    
//    if (offset > self.decodeOffset) {
        if (offset == 0 || offset % seek == 0) {
            downloadOffset = offset + self.decodeOffset;
            self.startLocationOffset = 0;
        } else {
            downloadOffset = offset / seek * seek + self.decodeOffset;
            self.startLocationOffset = offset % seek;
        }
//    }
    
//    self.startLocationOffset = offset - downloadOffset;
    return downloadOffset;
}


#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.isFinishLoad = false;
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) { return; }
    
    // 解析头部数据
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSMutableDictionary *allHeaderFields = [httpResponse.allHeaderFields mutableCopy];
    NSString *contentRange = allHeaderFields[@"Content-Range"];
    NSArray<NSString *> *contentAry = [contentRange componentsSeparatedByString:@"/"];
    NSInteger length = [contentAry.lastObject integerValue];
    
    // 拿到真实长度
//    PZLog(@"%@", allHeaderFields);
//    PZLog(@"%lld", httpResponse.expectedContentLength);
    NSInteger dataLength = length == 0 ? httpResponse.expectedContentLength : length;
    self.mediaLength = dataLength - self.decodeOffset;
    
    //数据格式
    self.mimeType = allHeaderFields[@"Content-Type"];
    
    if (self.mediaInfoHandler) {
        self.mediaInfoHandler(self, self.mediaLength, self.mimeType);
    }
    //  连接加入到任务数组中
    [self.taskList addObject:connection];
    //  初始化文件传输句柄
    self.filehandle = [NSFileHandle fileHandleForWritingAtPath:FILEPATH];
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
//    [self.bufferData appendData:data];
//    
//    if (self.bufferData.length >= MAX_BUFFER_SIZE) {
//        NSInteger cutCount = self.bufferData.length % 1024;
//        
//        NSData *writeData = [self.bufferData subdataWithRange:NSMakeRange(0, self.bufferData.length - cutCount)];
//        NSData *cutData = [self.bufferData subdataWithRange:NSMakeRange(self.bufferData.length - cutCount, cutCount)];
//        
//        [self.filehandle seekToEndOfFile];
//        [self.filehandle writeData:writeData];
//        
//        self.downLoadingLength += writeData.length;
//        
//        self.bufferData = [NSMutableData dataWithData:cutData];
//        
//        if (self.mediaDataHandler) {
//            self.mediaDataHandler(self);
//        }
//        
//    }
    
    
    [self.filehandle seekToEndOfFile];
    [self.filehandle writeData:data];
    
    self.downLoadingLength += data.length;
    
    if (self.mediaDataHandler) {
        self.mediaDataHandler(self);
    }
    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//    if (self.bufferData.length < MAX_BUFFER_SIZE) {
//        [self.filehandle seekToEndOfFile];
//        [self.filehandle writeData:self.bufferData];
//    }
    
    if (self.taskList.count < 2) {
        self.isFinishLoad = true;
        
        if (self.downLoadingLength == self.mediaLength + self.decodeOffset) {
            NSString *fileName = self.URL.lastPathComponent;
            NSString *movePath = [TMPPATH stringByAppendingPathComponent:(fileName ? : @"undefine")];
            
            [[NSFileManager defaultManager] removeItemAtPath:movePath error:nil];
            [[NSFileManager defaultManager] copyItemAtPath:FILEPATH toPath:movePath error:nil];
        }
    }
    
    if (self.mediaFinishedHandler) {
        self.mediaFinishedHandler(self);
    }
    
    [self.filehandle closeFile];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (self.mediaFailHandler) {
        self.mediaFailHandler(self, error);
    }
    
    [self.filehandle closeFile];
}


@end


































