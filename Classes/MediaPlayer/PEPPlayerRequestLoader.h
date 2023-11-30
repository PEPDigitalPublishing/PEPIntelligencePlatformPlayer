//
//  PEPPlayerRequestLoader.h
//  TestCoreText
//
//  Created by 李沛倬 on 2017/5/18.
//  Copyright © 2017年 PEP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PEPPlayerRequestTask.h"

typedef void(^FinishLoadingHandler)(PEPPlayerRequestTask *task);

@interface PEPPlayerRequestLoader : NSObject<AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) PEPPlayerRequestTask *task;

@property (nonatomic, copy) FinishLoadingHandler finishLoadingHandler;

- (NSURL *)exchangeSchemeWithURL:(NSURL *)url;

- (void)cancel;

@end
