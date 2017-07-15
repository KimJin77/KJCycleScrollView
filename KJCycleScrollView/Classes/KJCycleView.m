//
//  KJCycleScrollView.m
//  Pods
//
//  Created by Kim on 2017/7/15.
//
//

#import "KJCycleView.h"
#import "KJCycleModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSInteger kContentNum = 10000;
static NSInteger kImageViewTag = 20000;
static NSString *const kCollectionViewIdentifier = @"CycleScrollViewCellIdentifier";

@interface KJCycleView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, getter=isTimerRunning) BOOL timerRunning;
@end

@implementation KJCycleView

- (instancetype)init {
    self = [super init];
    if (self) {
        _loop = YES;
        _timerRunning = YES;
        _interval = 2.0f;
        [self startTimer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _loop = YES;
        _timerRunning = YES;
        _interval = 2.0f;
        [self startTimer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _loop = YES;
        _timerRunning = YES;
        _interval = 2.0f;
        [self startTimer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (![self.subviews containsObject:self.collectionView]) {
        [self addSubview:self.collectionView];
    }
}

// MARK: - Private

- (void)startTimer {
    if (self.interval == 0 || !self.isTimerRunning) {
        return;
    }
    
    dispatch_queue_t cycleQueue = dispatch_queue_create("CycleTimer", DISPATCH_QUEUE_SERIAL);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, cycleQueue);
    if (self.timer) {
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, self.interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(self.timer, ^{
            [weakSelf nextImage];
        });
        dispatch_resume(self.timer);
    }
}

- (void)nextImage {
    if (self.dataSource.count == 0) {
        return;
    }
    
    self.currentIndex++;
    if ([NSThread isMainThread]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionLeft
                                                animated:YES];
        });
    }
}

// MARK: - DataSource
// MARK: UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.isLoop ? self.dataSource.count * kContentNum : self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewIdentifier
                                                                           forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:kImageViewTag];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
    }
    imageView.image = nil;
    KJCycleModel *model = self.dataSource[indexPath.row % self.dataSource.count];
    if (model.imageURLString) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.imageURLString]
                     placeholderImage:[UIImage imageNamed:model.placeholderImageName]];
    } else if (model.imageName) {
        imageView.image = [UIImage imageNamed:model.imageName];
    } else {
        imageView.image = [UIImage imageNamed:model.placeholderImageName];
    }
    return cell;
}

// MARK: - Delegate
// MARK: UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KJCycleModel *model = self.dataSource[indexPath.row % self.dataSource.count];
    if (model.tapHandler) {
        model.tapHandler();
    }
}

// MARK: UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
        self.timerRunning = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 避免快速滑动时出现bug
    UICollectionViewCell *cell;
    if (self.collectionView.visibleCells.count >= 2) {
        cell = [self.collectionView visibleCells].lastObject;
    } else {
        cell = [self.collectionView visibleCells].firstObject;
    }
    self.currentIndex = [self.collectionView indexPathForCell:cell].row;
    if (!self.timer && !self.isTimerRunning) {
        self.timerRunning = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startTimer];
        });
    }
}

// MARK: - Custom Accessor

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = self.bounds.size;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:NSClassFromString(@"UICollectionViewCell")
            forCellWithReuseIdentifier:kCollectionViewIdentifier];
    }
    return _collectionView;
}

- (void)setLoop:(BOOL)loop {
    _loop = loop;
    [self.collectionView reloadData];
    self.currentIndex = 0;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

- (void)setDataSource:(NSMutableArray<KJCycleModel *> *)dataSource {
    
    _dataSource = dataSource;
    [self.collectionView reloadData];
    self.currentIndex = _dataSource.count * kContentNum / 2;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

- (void)setInterval:(CGFloat)interval {
    _interval = interval;
    
    dispatch_cancel(self.timer);
    
    self.timerRunning = YES;
    [self startTimer];
}

@end
