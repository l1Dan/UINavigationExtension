//
// NXNavigationBar.m
//
// Copyright (c) 2021 Leo Lee NXNavigationExtension (https://github.com/l1Dan/NXNavigationExtension)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NXNavigationBar.h"

@implementation NXNavigationBarAppearance

+ (NXNavigationBarAppearance *)standardAppearance {
    static NXNavigationBarAppearance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NXNavigationBarAppearance alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _tintColor = [UIColor systemBlueColor];
        if (@available(iOS 13.0, *)) {
            _backgorundColor = [UIColor systemBackgroundColor];
        } else {
            _backgorundColor = [UIColor whiteColor];
        }
    }
    return self;
}

#pragma mark - Getter

- (UIImage *)backImage {
    if (!_backImage) {
        NSString *backImageBase64 = @"iVBORw0KGgoAAAANSUhEUgAAACQAAAA/BAMAAAB6P3fzAAAAJ1BMVEUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADdEvm1AAAADHRSTlMA+KsWv9WainhiTDxlDsoeAAAA80lEQVQ4y43SPw4BURDH8QnibyUR/7KFAyhE6CVaHaXCARQOoHAABb1iFQ7gCCu7y27mUGY6837keeU3n7zkzTzyn/EqdEqjybmT7gG3AHECiNsWSeGlSVcpzdFnqX9HiUUM6AKohjedpcQW6U1zexOgqqKZQUdF5EF7KQ9TKoGkgQ8xoK2U1JSyoo0HFRTtTBpKef6DOnZ3ig7w4JTI3UsU2raW1rdpiqyoLEfGJ7ytZ9MEWXEhKbOshC8gZV0/03G8yDM0GC0wWBMs08MqyPD74P/Rc0RW/cFihwXwr+mCA6lJSghYTA4LOCPn3KIduWdEb+D7yB4mCTyrAAAAAElFTkSuQmCC";
        NSData *data = [[NSData alloc] initWithBase64EncodedString:backImageBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (data) {
            return [UIImage imageWithData:data scale:3.0];
        }
        return nil;
    }
    return _backImage;
}

@end

@implementation NXNavigationBar {
    CGRect _originalNavigationBarFrame;
    UIEdgeInsets _containerViewEdgeInsets;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _originalNavigationBarFrame = CGRectZero;
        _shadowImageView = [[UIImageView alloc] init];
        _shadowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _shadowImageView.clipsToBounds = YES;

        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;

        _containerView = [[UIView alloc] init];
        _containerViewEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);

        UIBlurEffect *effect;
        if (@available(iOS 13.0, *)) {
            effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
        } else {
            effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        }

        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _visualEffectView.hidden = YES;
        _backgroundImageView.image = [NXNavigationBarAppearance standardAppearance].backgorundImage;

        [self addSubview:self.backgroundImageView];
        [self addSubview:self.visualEffectView];
        [self addSubview:self.shadowImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateNavigationBarContentFrame];
}

- (void)setFrame:(CGRect)frame {
    _originalNavigationBarFrame = frame;
    
    // 重新设置 NavigationBar frame
    [super setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetMaxY(frame))];
    [self updateNavigationBarContentFrame];
}

#pragma mark - Private

- (void)updateNavigationBarContentFrame {
    CGRect navigationBarFrame = CGRectMake(0, 0, CGRectGetWidth(_originalNavigationBarFrame), CGRectGetMaxY(_originalNavigationBarFrame));
    self.visualEffectView.frame = navigationBarFrame;
    self.backgroundImageView.frame = navigationBarFrame;

    CGRect containerViewFrame = CGRectMake(0, CGRectGetMinY(_originalNavigationBarFrame), CGRectGetWidth(_originalNavigationBarFrame), CGRectGetHeight(_originalNavigationBarFrame));
    self.containerView.frame = UIEdgeInsetsInsetRect(containerViewFrame, _containerViewEdgeInsets);
    
    CGFloat shadowImageViewHeight = 1.0 / UIScreen.mainScreen.scale;
    self.shadowImageView.frame = CGRectMake(0, CGRectGetMaxY(_originalNavigationBarFrame) - shadowImageViewHeight, CGRectGetWidth(navigationBarFrame), shadowImageViewHeight);

    // 放在所有的 View 前面，防止 containerView 被遮挡
    if (self.superview && self.superview != self.containerView.superview) {
        [self.superview addSubview:self.containerView];
    }
    [self.superview bringSubviewToFront:self.containerView];
}

+ (NSMutableDictionary<NSString *, NXNavigationBarAppearance *> *)appearanceInfo {
    static NSMutableDictionary<NSString *, NXNavigationBarAppearance *> *appearanceInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appearanceInfo = [NSMutableDictionary dictionary];
    });
    return appearanceInfo;
}

#pragma mark - Public

- (void)enableBlurEffect:(BOOL)enabled {
    if (enabled) {
        self.backgroundColor = [UIColor clearColor];
        self.containerView.backgroundColor = [UIColor clearColor];
        self.backgroundImageView.hidden = YES;
        self.visualEffectView.hidden = NO;
    }
}

- (void)addContainerViewSubview:(UIView *)subview {
    [self.containerView addSubview:subview];
}

- (void)setContainerViewEdgeInsets:(UIEdgeInsets)edgeInsets {
    _containerViewEdgeInsets = edgeInsets;
    [self updateNavigationBarContentFrame];
}

+ (NXNavigationBarAppearance *)standardAppearanceForNavigationControllerClass:(Class)aClass {
    if (aClass) {
        return [NXNavigationBar appearanceInfo][NSStringFromClass(aClass)];
    }
    return nil;
}

+ (void)registerStandardAppearanceForNavigationControllerClass:(Class)aClass {
    if (!aClass) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NavigationClass can‘t be nil" userInfo:nil];
    }
    [NXNavigationBar appearanceInfo][NSStringFromClass(aClass)] = [NXNavigationBarAppearance standardAppearance];
}

@end
