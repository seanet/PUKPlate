//
//  PUKPlate.h
//  PatternPUK
//
//  Created by zhaoqihao on 12/2/14.
//  Copyright (c) 2014 zhaoqihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PUKPlatePasswordDelegate <NSObject>

@optional
-(void)PUKPlateIsChangingPattern:(NSString *)password;
@optional
-(void)PUKPlateDidChangePattern:(NSString *)password;

@end

#define CIRCLE_SIZE 60.0 //single circle size
#define EDGE_SPACE 30.0  //the space between the plate's edge and the outer circles
#define PLATE_SIZE [[UIScreen mainScreen]bounds].size.width

#define LINE_WIDTH 10.0

//if the circle is selected,the circle's border color and the dot's (the center of the circle) background color
//and the line color
#define SELECTED_CGCOLOR [[UIColor colorWithRed:135/255 green:206/255 blue:250/255 alpha:0.5] CGColor]

//if you trigger the wrong state,this color represent the circle's border color,the dot's background color,
//and the line color
#define WRONG_CGCOLOR [[UIColor colorWithRed:255/255 green:99/255 blue:71/255 alpha:1] CGColor]

#define DOT_SIZE 20

//normal state circle border color
#define NORMAL_CGCOLOR [[UIColor lightGrayColor] CGColor]

//highlight state (selected and wrong),the circle background color
#define HIGHLIGHT_BACKGROUND_COLOR [UIColor colorWithWhite:1.0 alpha:1.0]

/*
 the plate's frame's X coordinate should be 0,you can specify any Y coordinate.
 you can ignore its width and height,it can be assigned automatically.
 
 note:-->
    if you use autolayout in the xib,do not add the equal width or equal height constraints,
    or the plate can not assign its width or height automatically.

 */
@interface PUKPlate : UIView

@property (nonatomic,weak)id<PUKPlatePasswordDelegate>delegate;

-(void)reset;
-(void)wrong;

@end