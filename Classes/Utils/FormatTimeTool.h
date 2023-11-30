//
//  FormatTimeTool.h
//  Player
//
//  Created by 李沛倬 on 2017/6/5.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface FormatTimeTool : NSObject

+ (NSString *)getFormatedTimeStringWithCurrentTime:(CMTime)currentTime duration:(CMTime)duration;

+ (CGFloat)getProgressWithCurrentTime:(CMTime)currentTime duration:(CMTime)duration;

+ (NSString *)formatterTimeWith:(CGFloat)seconds;

@end
