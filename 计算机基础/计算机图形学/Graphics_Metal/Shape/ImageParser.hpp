//
//  ImageParser.hpp
//  Graphics
//
//  Created by i7y on 2021/10/13.
//

#ifndef ImageParser_hpp
#define ImageParser_hpp

#include <stdio.h>

/// TGA 头包含的图像元数据
typedef struct __attribute__ ((packed)) TGAHeader {
    u_int8_t  IDSize;         // Size of ID info following header
    u_int8_t  colorMapType;   // 是否是一个 paletted 图像
    u_int8_t  imageType;      // type of image 0=none, 1=indexed, 2=rgb, 3=grey, +8=rle packed
    
    u_int16_t  colorMapStart;  // Offset to color map in palette
    u_int16_t  colorMapLength; // Number of colors in palette
    u_int8_t  colorMapBpp;    // Number of bits per palette entry
    
    u_int16_t xOrigin;        // X Origin pixel of lower left corner if tile of larger image
    u_int16_t yOrigin;        // Y Origin pixel of lower left corner if tile of larger image
    u_int16_t width;          // Width in pixels
    u_int16_t height;         // Height in pixels
    u_int8_t  bitsPerPixel;   // Bits per pixel 8,16,24,32
    union {
        struct
        {
            u_int8_t bitsPerAlpha : 4;
            u_int8_t topOrigin    : 1;
            u_int8_t rightOrigin  : 1;
            u_int8_t reserved     : 2;
        };
        u_int8_t descriptor;
    };
} TGAHeader;


class ImageParser {
    int width;
    int height;
    void *datas;
public:
    ImageParser(char *filePath);
};


#endif /* ImageParser_hpp */
