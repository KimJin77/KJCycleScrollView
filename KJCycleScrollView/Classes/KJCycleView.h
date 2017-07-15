//
//  KJCycleScrollView.h
//  Pods
//
//  Created by Kim on 2017/7/15.
//
//

#import <UIKit/UIKit.h>

@class KJCycleModel;


@interface KJCycleView : UIView

/**
 Whether loop. Default is YES
 */
@property (nonatomic, assign, getter=isLoop) BOOL loop;

/**
 Time interval that between two images display. Default is 2.0
 */
@property (nonatomic, assign) CGFloat interval;

/**
 Data source
 */
@property (nonatomic, strong) NSMutableArray<KJCycleModel *> *dataSource;

@end
