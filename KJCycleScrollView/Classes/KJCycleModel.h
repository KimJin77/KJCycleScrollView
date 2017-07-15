//
//  KJCycleModel.h
//  Pods
//
//  Created by Kim on 2017/7/15.
//
//

#import <Foundation/Foundation.h>

typedef void(^TapHandler)();

@interface KJCycleModel : NSObject

/**
 If source is a web url, then this is the url
 */
@property (nonatomic, copy) NSString *imageURLString;

/**
 Local image name
 */
@property (nonatomic, copy) NSString *imageName;

/**
 Placeholder name
 */
@property (nonatomic, copy) NSString *placeholderImageName;

/**
 Action handler
 */
@property (nonatomic, copy) TapHandler tapHandler;

@end
