//
//  PicPranckImage.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckImage : UIImage

//Attributes
@property (nonatomic) UIImageOrientation originalImageOrientation;

//Instanciation
-(instancetype)initWithImage:(UIImage *)iImage;
//Image scale
-(UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

@end
