//
//  PUKShow.m
//  PatternPUK
//
//  Created by zhaoqihao on 12/3/14.
//  Copyright (c) 2014 zhaoqihao. All rights reserved.
//

#import "PUKShow.h"
#import "Line.h"

//the view's shown size
//no matter what the actual size is,people can just see the fixed size
#define SELF_SIZE (PUKSHOW_DOT_SIZE*3+PUKSHOW_DOT_SPACE*2)

typedef enum {
    DotStatusUnChosen,
    DotStatusChosen
}DotStatus;

@interface Dot : UIView

@property (nonatomic,assign)DotStatus dotStatus;

//left-top point
-(id)initWithLocation:(CGPoint)location;

@end

@implementation PUKShow{
    NSMutableArray *dots;
    NSMutableArray *lines;
}
@synthesize patternCode=_patternCode;

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, SELF_SIZE, SELF_SIZE)];
    if(self){
        [self prepare];
    }
    
    return self;
}

-(id)initWithCenter:(CGPoint)position{
    return [self initWithFrame:CGRectMake(position.x-SELF_SIZE/2, position.y-SELF_SIZE/2, 0, 0)];
}

-(void)awakeFromNib{
    [self prepare];
}

-(void)prepare{
    self.backgroundColor=[UIColor whiteColor];
    
    dots=[[NSMutableArray alloc]init];
    lines=[[NSMutableArray alloc]init];
    
    int coordinateX=0;
    int coordinateY=0;
        
    if(self.bounds.size.width>SELF_SIZE)
        coordinateX=(self.bounds.size.width-SELF_SIZE)/2;
    if(self.bounds.size.height>SELF_SIZE)
        coordinateY=(self.bounds.size.height-SELF_SIZE)/2;
    
    for(int i=1;i<=9;i++){
        Dot *d=[[Dot alloc]initWithLocation:CGPointMake(coordinateX, coordinateY)];
        [self addSubview:d];
        [dots addObject:d];
        
        coordinateX+=PUKSHOW_DOT_SPACE+PUKSHOW_DOT_SIZE;
        if(i%3==0){
            coordinateX=0;
            coordinateY+=PUKSHOW_DOT_SPACE+PUKSHOW_DOT_SIZE;
            
            if(self.bounds.size.width>SELF_SIZE)
                coordinateX=(self.bounds.size.width-SELF_SIZE)/2;
        }
    }
}

-(void)setPatternCode:(NSString *)patternCode{
    if(!patternCode) return;
    if(patternCode.length>9) return;
    
    NSString *regex=@"\\d+";
    NSPredicate *pred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch=[pred evaluateWithObject:patternCode];
    if(!isMatch) return;
    
    [lines removeAllObjects];
    
    for(int i=0;i<patternCode.length-1;i++){
        NSRange startRange=NSMakeRange(i, 1);
        NSRange endRange=NSMakeRange(i+1, 1);
        NSString *startStr=[patternCode substringWithRange:startRange];
        NSString *endStr=[patternCode substringWithRange:endRange];

        Dot *startDot=[dots objectAtIndex:startStr.intValue];
        Dot *endDot=[dots objectAtIndex:endStr.intValue];
        
        startDot.dotStatus=DotStatusChosen;
        endDot.dotStatus=DotStatusChosen;
        
        Line *line=[[Line alloc]init];
        line.begin=startDot.center;
        line.end=endDot.center;
        
        [lines addObject:line];
    }
    
    if (patternCode.length==1) {
        Dot *d=[dots objectAtIndex:patternCode.intValue];
        d.dotStatus=DotStatusChosen;
    }
    
    [self setNeedsDisplay];
}

-(void)reset{
    for(Dot *d in dots)
        d.dotStatus=DotStatusUnChosen;
    
    [lines removeAllObjects];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    if (lines.count==0)
        return;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
//    CGFloat lengths[]={2,2};
//    CGContextSetLineDash(context, 0, lengths,2);
    CGContextSetLineWidth(context, PUKSHOW_LINE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    UIColor *lineColor=[UIColor colorWithCGColor:PUKSHOW_DOT_COLOR.CGColor];
    [lineColor set];

    for(Line *line in lines){
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
    }
}

@end

#define LAYER_WIDTH 0.6
#define RADIAN_SPACE M_PI/14

@implementation Dot
@synthesize dotStatus=_dotStatus;

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, PUKSHOW_DOT_SIZE, PUKSHOW_DOT_SIZE)];
    if(self){
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setCornerRadius:PUKSHOW_DOT_SIZE/2];
        
        for(int i=0;i<4;i++){
            CAShapeLayer *sl=[[CAShapeLayer alloc]init];
            [sl setBounds:self.bounds];
            [sl setPosition:CGPointMake(PUKSHOW_DOT_SIZE/2, PUKSHOW_DOT_SIZE/2)];
            [sl setFillColor:nil];
            [sl setLineCap:kCALineCapRound];
            
            sl.path=[[UIBezierPath bezierPathWithArcCenter:CGPointMake(PUKSHOW_DOT_SIZE/2, PUKSHOW_DOT_SIZE/2) radius:(self.bounds.size.width-LAYER_WIDTH)/2.0 startAngle:M_PI/2*i+RADIAN_SPACE endAngle:(i+1)*M_PI/2-RADIAN_SPACE clockwise:YES] CGPath];
            sl.lineWidth=LAYER_WIDTH;
            sl.strokeColor=[[PUKSHOW_DOT_COLOR colorWithAlphaComponent:0.6] CGColor];
            
            [self.layer addSublayer:sl];
        }
    }
    
    return self;
}

-(id)initWithLocation:(CGPoint)location{
    return [self initWithFrame:CGRectMake(location.x, location.y, 0, 0)];
}

-(void)setDotStatus:(DotStatus)dotStatus{
    _dotStatus=dotStatus;
    
    switch (dotStatus) {
        case DotStatusChosen:
            [self setBackgroundColor:PUKSHOW_DOT_COLOR];
            break;
        case DotStatusUnChosen:
            [self setBackgroundColor:[UIColor whiteColor]];
            break;
    }
    
    [self setNeedsDisplay];
}

@end
