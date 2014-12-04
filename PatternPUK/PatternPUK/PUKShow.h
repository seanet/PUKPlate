//
//  PUKShow.h
//  PatternPUK
//
//  Created by zhaoqihao on 12/3/14.
//  Copyright (c) 2014 zhaoqihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PUKSHOW_DOT_COLOR [UIColor purpleColor] //the dot border and background color

#define PUKSHOW_DOT_SPACE 4
#define PUKSHOW_DOT_SIZE 8

#define PUKSHOW_LINE_WIDTH 0.3

/*
 if you create it in xib,make sure the size of it >= SELF_SIZE,
 it will aligned center automatically in the view.
  */
@interface PUKShow : UIView

@property (nonatomic,strong)NSString *patternCode;

//you can just specify it's center's point,ignore its bounds.
-(id)initWithCenter:(CGPoint)position;

-(void)reset;

@end
