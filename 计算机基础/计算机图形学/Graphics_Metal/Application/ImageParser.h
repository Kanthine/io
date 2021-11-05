//
//  ImageParser.h
//  Graphics
//
//  Created by 苏莫离 on 2021/8/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TagImageParser : NSObject

// Initialize the image by loading a simple TGA file.
// This method doesn't load compressed, paletted, or color-mapped images.
-(nullable instancetype)initWithTGAFileAtLocation:(nonnull NSURL *)location;

// Initialize the image by loading an `NSData` object with tightly packed
// `BGRA8Unorm` data and dimensions.
-(nullable instancetype)initWithBGRA8UnormData:(nonnull NSData *)data
                                         width:(NSUInteger)width
                                        height:(NSUInteger)height;

// Save the image to a TGA file at the given location.
- (void)saveToTGAFileAtLocation:(nonnull NSURL *)location;

// The width of the image, in pixels.
@property (nonatomic, readonly) NSUInteger width;

// The height of the image, in pixels.
@property (nonatomic, readonly) NSUInteger height;

// The image data in 32-bits-per-pixel (bpp) BGRA form, which is equivalent
// to `MTLPixelFormatBGRA8Unorm`.
@property (nonatomic, readonly, nonnull) NSData *data;


@end


NS_ASSUME_NONNULL_END
