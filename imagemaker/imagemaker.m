#include <stdio.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <string.h>

CGImageRef openImage(const char* path)
{
	CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL,
	                                                       (const UInt8*)path,
	                                                       strlen(path),
	                                                       false);
	CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
	CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
	CFRelease(imageSource);
	CFRelease(url);

	if(image == NULL)
	{
		printf("Could not open %s\n", path);
	}
	return image;
}

CGContextRef createBitmapContext(size_t width, size_t height)
{
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
	                                                   width,
	                                                   height,
	                                                   8,
	                                                   4*width,
	                                                   rgbColorSpace,
	                                                   kCGImageAlphaPremultipliedLast);
	CFRelease(rgbColorSpace);

	return bitmapContext;
}

void writeBitmapContext(CGContextRef theContext, const char* path)
{
	CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL,
	                                                       (const UInt8*)path,
	                                                       strlen(path),
	                                                       false);
	CGImageRef image = CGBitmapContextCreateImage(theContext);
	CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
	CGImageDestinationAddImage(imageDest, image, NULL);
	CGImageDestinationFinalize(imageDest);

	CFRelease(imageDest);
	CGImageRelease(image);
	CFRelease(url);
}

void makeBackground(void)
{
	CGImageRef paper_gray = openImage("paperstrip_gray.png");
	if(paper_gray == NULL)
	{
		return;
	}
	CGContextRef bitmap = createBitmapContext(CGImageGetWidth(paper_gray), CGImageGetHeight(paper_gray));
	CGContextDrawImage(bitmap,
	                   CGRectMake(0.0, 0.0, CGImageGetWidth(paper_gray), CGImageGetHeight(paper_gray)),
	                   paper_gray);

	NSRect bounds = NSMakeRect(0.0, 0.0, CGImageGetWidth(paper_gray), CGImageGetHeight(paper_gray));
	NSGraphicsContext* graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:bitmap flipped:NO];
	[NSGraphicsContext setCurrentContext:graphicsContext];

	CGContextSaveGState(bitmap);
	CGContextSetBlendMode(bitmap, kCGBlendModeMultiply);
	NSGradient* gradient = [[NSGradient alloc] initWithColorsAndLocations:
	                           [NSColor colorWithDeviceRed:0.33 green:0.55 blue:0.70 alpha:1.0], 0.0,
	                           [NSColor colorWithDeviceRed:0.44 green:0.66 blue:0.82 alpha:1.0], 0.3,
	                           [NSColor colorWithDeviceRed:0.48 green:0.70 blue:0.86 alpha:1.0], 1.0,
	                           nil];
	[gradient drawInRect:bounds angle:90.0];
	CGContextRestoreGState(bitmap);

	// Bottom Line
	CGContextMoveToPoint(bitmap, 0.0, 0.0);
	CGContextAddLineToPoint(bitmap, bounds.size.width, 0.0);
	[[NSColor colorWithDeviceWhite:0.8 alpha:0.5] setStroke];
	CGContextSetLineWidth(bitmap, 4.0);
	CGContextStrokePath(bitmap);

	// Top Line
	CGContextMoveToPoint(bitmap, 0.0, bounds.size.height);
	CGContextAddLineToPoint(bitmap, bounds.size.width, bounds.size.height);
	[[NSColor colorWithDeviceWhite:0.2 alpha:0.5] setStroke];
	CGContextSetLineWidth(bitmap, 4.0);
	CGContextStrokePath(bitmap);

	[NSGraphicsContext restoreGraphicsState];
	CGImageRelease(paper_gray);
	writeBitmapContext(bitmap, "rowbackground.png");
	CGContextRelease(bitmap);
}

int main(int argc, char* argv[])
{
	printf("blarg\n");
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	makeBackground();

	[pool release];
	return 0;
}

