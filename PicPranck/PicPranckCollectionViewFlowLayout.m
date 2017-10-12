//
//  PicPranckCollectionViewFlowLayout.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 15/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PicPranckCollectionViewFlowLayout.h"
#include "Constants.h"

@implementation PicPranckCollectionViewFlowLayout

- (CGSize)collectionViewContentSize {
    
    //Cell Size
    self.cellSize = [self getCellSize];
    
    //Scroll Direction
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    //Get number of items in section
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    _nbOfElements=numberOfItems;
    
    //Header settings
    self.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, HEADER_HEIGHT);
    self.sectionHeadersPinToVisibleBounds = YES;
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, (numberOfItems % NB_CELLS_PER_ROW)* self.cellSize+HEADER_HEIGHT);
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    attributes.frame = CGRectMake((indexPath.row%NB_CELLS_PER_ROW) * (double)(self.cellSize+ITEM_SPACING)+ITEM_SPACING,floor(indexPath.row/(double)NB_CELLS_PER_ROW)*(self.cellSize+LINE_SPACING)+HEADER_HEIGHT, self.cellSize, self.cellSize);
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    if(0<_nbOfElements) {
        
        for (NSUInteger index = 0; index <_nbOfElements; index++) {
            
            NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:(NSUInteger [2]){ 0, index } length:2];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    attributes.alpha = 0.0;
    
    return attributes;
}

-(CGFloat)getCellSize {
    CGSize cellSize = [PicPranckCollectionViewFlowLayout getCellSize];
    return cellSize.width;
}

+(CGFloat)getHeaderHeight {
    return HEADER_HEIGHT;
}

+(CGSize)getCellSize
{
    CGFloat cellSize=([UIScreen mainScreen].bounds.size.width-(NB_CELLS_PER_ROW+1)*ITEM_SPACING)/NB_CELLS_PER_ROW;
    return CGSizeMake(cellSize, cellSize);
}

@end
