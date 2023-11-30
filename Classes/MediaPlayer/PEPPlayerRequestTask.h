//
//  PEPPlayerRequestTask.h
//  TestCoreText
//
//  Created by 李沛倬 on 2017/5/19.
//  Copyright © 2017年 PEP. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TMPPATH     [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Media"]
#define FILEPATH    [TMPPATH stringByAppendingPathComponent:@"tmp"]

@class PEPPlayerRequestTask;

typedef void(^MediaInfoHandler)(PEPPlayerRequestTask *task, NSInteger mediaLength, NSString *mimeType);
typedef void(^MediaDataHandler)(PEPPlayerRequestTask *task);
typedef void(^MediaFinishedHandler)(PEPPlayerRequestTask *task);
typedef void(^MediaFailHandler)(PEPPlayerRequestTask *task, NSError *error);

@interface PEPPlayerRequestTask : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSMutableArray<NSURLConnection *> *taskList;

@property (nonatomic, copy) NSString *mimeType;

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger decodeOffset;
@property (nonatomic, assign) NSInteger downLoadingLength;
@property (nonatomic, assign) NSInteger startLocationOffset;
@property (nonatomic, assign) NSInteger mediaLength;
@property (nonatomic, assign) BOOL isFinishLoad;

@property (nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic, copy) MediaInfoHandler mediaInfoHandler;
@property (nonatomic, copy) MediaDataHandler mediaDataHandler;
@property (nonatomic, copy) MediaFinishedHandler mediaFinishedHandler;
@property (nonatomic, copy) MediaFailHandler mediaFailHandler;


- (void)setURL:(NSURL *)URL offset:(NSInteger)offset;

- (void)cancel;

@end









