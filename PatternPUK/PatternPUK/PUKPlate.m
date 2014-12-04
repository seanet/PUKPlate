//
//  PUKPlate.m
//  PatternPUK
//
//  Created by zhaoqihao on 12/2/14.
//  Copyright (c) 2014 zhaoqihao. All rights reserved.
//

#import "PUKPlate.h"
#import "Line.h"

typedef enum{
    CircleStatusNormal,
    CircleStatusSelected,
    CircleStatusWrong
}CircleStatus;

@interface Circle : UIView<NSCopying,NSMutableCopying>

@property (nonatomic,assign)CircleStatus circleStatus;

-(id)initWithLocation:(CGPoint)point;

@end

//--------------------------- PUKPlate ---------------------------
#pragma mark ****PUKPlate

@interface PUKPlate(){
    NSMutableArray *completeLines;
    Line *lineInProcess;
    
    NSArray *originalCircles;
    NSMutableArray *circles;
    NSMutableSet *abandonedCircles;
    
    NSMutableString *password;
    
    BOOL switching;
    BOOL isWrong;
}

@end

@implementation PUKPlate
@synthesize delegate=_delegate;

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:CGRectMake(0, frame.origin.y, PLATE_SIZE, PLATE_SIZE)];
    if(self){
        [self prepare];
    }
    
    return self;
}

-(void)awakeFromNib{
    [self setFrame:CGRectMake(0, self.frame.origin.y, PLATE_SIZE, PLATE_SIZE)];
    [self prepare];
}

-(void)prepare{
    self.backgroundColor=[UIColor whiteColor];
    
    [self prepareCircles];
    [self prepareTouchEvents];
}

-(void)prepareCircles{
    CGFloat space=(PLATE_SIZE-EDGE_SPACE*2-CIRCLE_SIZE*3)/2.0;
    int coordinateX=EDGE_SPACE;
    int coordinateY=EDGE_SPACE;
    
    circles=[[NSMutableArray alloc]init];
    
    for(int i=1;i<=9;i++){
        Circle *c=[[Circle alloc]initWithLocation:CGPointMake(coordinateX, coordinateY)];
        [circles addObject:c];
        [self addSubview:c];
        
        coordinateX+=CIRCLE_SIZE+space;
        if(i%3==0){
            coordinateX=EDGE_SPACE;
            coordinateY+=CIRCLE_SIZE+space;
        }
    }
    
    originalCircles=[circles copy];
    abandonedCircles=[[NSMutableSet alloc]init];
}

-(void)prepareTouchEvents{
    switching=YES;
    completeLines =[[NSMutableArray alloc]init];
    
    [self setMultipleTouchEnabled:NO];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    UIColor *selectedColor;
    if(isWrong)
        selectedColor=[UIColor colorWithCGColor:WRONG_CGCOLOR];
    else
        selectedColor=[UIColor colorWithCGColor:SELECTED_CGCOLOR];
    [selectedColor set];
    
    for(Line *line in completeLines){
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
    }
    
    if(!lineInProcess)
        return;
    
    CGContextMoveToPoint(context, lineInProcess.begin.x, lineInProcess.begin.y);
    CGContextAddLineToPoint(context, lineInProcess.end.x, lineInProcess.end.y);
    CGContextStrokePath(context);
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

//find the index in the original circles
-(int)indexForCircle:(Circle *)c{
    return (int)[originalCircles indexOfObject:c];
}

//collision detection
-(int)collisionDetection:(CGPoint)point{
    for(int i=0;i<[circles count];i++){
        Circle *c=[circles objectAtIndex:i];
        float distance=[self distanceFromPointX:point ToPointY:c.center];
        if(distance<=CIRCLE_SIZE/2)
            return i;
    }
    
    return -1;
}

//calculate the distance with two points
-(float)distanceFromPointX:(CGPoint)start ToPointY:(CGPoint)end{
    float distance;
    CGFloat xDelta = fabsf(end.x - start.x);
    CGFloat yDelta = fabsf(end.y - start.y);
    distance = sqrt((xDelta * xDelta) + (yDelta * yDelta));
    
    return distance;
}

-(void)reset{
    [completeLines removeAllObjects];
    lineInProcess=nil;
    circles=[originalCircles mutableCopy];
    [abandonedCircles removeAllObjects];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    for(Circle *c in circles)
        c.circleStatus=CircleStatusNormal;
    
    [CATransaction commit];
    
    switching=YES;
    isWrong=NO;
    
    [self setNeedsDisplay];
}

-(void)wrong{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    for(Circle *c in abandonedCircles)
        c.circleStatus=CircleStatusWrong;
    
    [CATransaction commit];
    
    isWrong=YES;
    [self setNeedsDisplay];
}

#pragma mark - touch events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!switching)
        return;
    
    for (UITouch *t in touches){
        CGPoint loc=[t locationInView:self];
        int index=[self collisionDetection:loc];
        if(index==-1)
            return;
        
        lineInProcess=[[Line alloc]init];
        Circle *c=[circles objectAtIndex:index];
        
        lineInProcess.begin=c.center;
        lineInProcess.end=c.center;
        
        c.circleStatus=CircleStatusSelected;
        [circles removeObject:c];
        [abandonedCircles addObject:c];
        
        password=[[NSMutableString alloc]initWithFormat:@"%d",[self indexForCircle:c]];
        [self.delegate PUKPlateIsChangingPattern:password];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *t in touches){
        if(!lineInProcess)
            return;
        
        CGPoint loc=[t locationInView:self];
        int index=[self collisionDetection:loc];
        if(index==-1){
            lineInProcess.end=loc;
        }else{
            Circle *c=[circles objectAtIndex:index];
            Line *completeLine=lineInProcess;
            completeLine.end=c.center;
            
            c.circleStatus=CircleStatusSelected;
            [completeLines addObject:completeLine];
            [circles removeObject:c];
            [abandonedCircles addObject:c];
            
            lineInProcess=[[Line alloc]init];
            lineInProcess.begin=c.center;
            lineInProcess.end=loc;
            
            [password appendFormat:@"%d",[self indexForCircle:c]];
            [self.delegate PUKPlateIsChangingPattern:password];
        }
    }
    
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

-(void)endTouches:(NSSet *)touches
{
    if(!lineInProcess)
        return;
    
    lineInProcess=nil;
    switching=NO;
    [self setNeedsDisplay];
    
    if(password){
        [self.delegate PUKPlateDidChangePattern:password];
        password=nil;
    }
}

@end

//--------------------------- Circle ---------------------------
#pragma mark ****Circle

@interface Circle(){
    __weak CALayer *dotLayer;
}

@end

@implementation Circle
@synthesize circleStatus=_circleStatus;

-(id)initWithLocation:(CGPoint)point{
    return [self initWithFrame:CGRectMake(point.x, point.y, 0 , 0)];
}

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, CIRCLE_SIZE, CIRCLE_SIZE)];
    if(self){
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self.layer setCornerRadius:CIRCLE_SIZE/2];
        [self.layer setBorderColor:NORMAL_CGCOLOR];
        [self.layer setBorderWidth:1.4];
        
        CALayer *layer=[[CALayer alloc]init];
        [layer setBackgroundColor:SELECTED_CGCOLOR];
        [layer setPosition:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        [layer setBounds:CGRectMake(0, 0, DOT_SIZE, DOT_SIZE)];
        [layer setCornerRadius:DOT_SIZE/2];
        [layer setHidden:YES];
        [self.layer addSublayer:layer];
        dotLayer=layer;
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, CIRCLE_SIZE, CIRCLE_SIZE)];
}

-(void)setBounds:(CGRect)bounds{
    [super setBounds:CGRectMake(0, 0, CIRCLE_SIZE, CIRCLE_SIZE)];
}

-(void)setCircleStatus:(CircleStatus)circleStatus{
    switch (circleStatus) {
        case CircleStatusNormal:
            [self setBackgroundColor:[UIColor whiteColor]];
            [self.layer setBorderColor:NORMAL_CGCOLOR];
            [dotLayer setHidden:YES];
            break;
        case CircleStatusSelected:
            [self setBackgroundColor:HIGHLIGHT_BACKGROUND_COLOR];
            [self.layer setBorderColor:SELECTED_CGCOLOR];
            [dotLayer setBackgroundColor:SELECTED_CGCOLOR];
            [dotLayer setHidden:NO];
            break;
        case CircleStatusWrong:
            [self setBackgroundColor:HIGHLIGHT_BACKGROUND_COLOR];
            [self.layer setBorderColor:WRONG_CGCOLOR];
            [dotLayer setBackgroundColor:WRONG_CGCOLOR];
            [dotLayer setHidden:NO];
            break;
    }
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return self;
}

@end