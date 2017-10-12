//
//  Constants.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 05/06/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

//Custom views Services

////Offset of "Use" and "Close" buttons from center of screen in preview
#define X_OFFSET_FROM_CENTER_OF_SCREEN 60
#define Y_OFFSET_FROM_BOTTOM_OF_SCREEN 120
////Vertical offset from bottom container view to buttons
#define Y_OFFSET_PREVIEW_TO_BUTTON 30
////Buttons' size: Use, close, previous and next
#define BUTTON_WIDTH 60
#define BUTTON_HEIGHT 60
////Ratio of preview to screen size
#define WIDTH_PREVIEW_RATIO 1.75
#define HEIGHT_PREVIEW_RATIO 1.29
////Corner radius of cells in collection view
#define CELL_CORNER_RADIUS 10


//Collection view Flow Layout

#define NB_CELLS_PER_ROW 3
////Space between cells in collection view
#define ITEM_SPACING 2
#define LINE_SPACING 2

#define HEADER_HEIGHT 15

//Set to 0 if we want to use document interaction controller instead of activity view controller
#define USE_ACTIVITY_VIEW_CONTROLLER 1

//Encryption services
#define MAXIMUM_IMAGE_SIZE 250000
//#define NUMBER_ELEMENTS 1000
//#define EXPO 5
#define NUMBER_ELEMENTS 20099
#define EXPO 101

#define TITLE_WIDTH 250
#define TITLE_HEIGHT 50

#endif /* Constants_h */
