//
//  EM_MenuView.h
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <AllPod/AllPlugInHeader.h>

@class EM_MenuView;

typedef void (^MenuCompletion)(int index, id object, EM_MenuView * menu);

@interface EM_MenuView : CustomIOS7AlertView

- (id)initWithMenu:(NSDictionary*)info;

- (id)initWithNotification:(NSDictionary*)info;

- (id)initWithDate:(NSDictionary*)info;

- (id)initWithPop:(NSDictionary*)info;

- (id)initWithLoc:(NSDictionary*)info;

- (EM_MenuView*)showWithCompletion:(MenuCompletion)_completion;

@property(nonatomic,copy) MenuCompletion menuCompletion;

@end

@interface NSMutableArray (Convenience)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
