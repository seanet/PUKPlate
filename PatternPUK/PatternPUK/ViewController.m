//
//  ViewController.m
//  PatternPUK
//
//  Created by lmwl123 on 12/2/14.
//  Copyright (c) 2014 zhaoqihao. All rights reserved.
//

#import "ViewController.h"
#import "PUKShow.h"

@interface ViewController (){
    __weak IBOutlet PUKShow *show;
    __weak IBOutlet PUKPlate *plate;
    __weak IBOutlet UILabel *label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    plate.delegate=self;
}

- (IBAction)click:(id)sender {
    [plate reset];
    [show reset];
}

-(void)PUKPlateIsChangingPattern:(NSString *)password{
    [show setPatternCode:password];
}

-(void)PUKPlateDidChangePattern:(NSString *)password{
    [self shakeAnimationForView:label];
    [plate wrong];
    NSLog(@"%@",password);
}

#pragma mark shake animation
- (void)shakeAnimationForView:(UIView *)view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; //animated smoothly
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    [animation setDelegate:self];
    
    [viewLayer addAnimation:animation forKey:nil];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [plate reset];
    [show reset];
}

@end
