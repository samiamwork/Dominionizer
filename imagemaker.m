#include <stdio.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <string.h>

CGImageRef openImage(const char* path)
{
	CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL,
	                                                       (const UInt8*)path, strlen(path),
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

int main(int argc, char* argv[])
{
	printf("blarg\n");
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	CGImageRef paper_gray = openImage("paperstrip_gray.png");
	if(paper_gray == NULL)
	{
		return 1;
	}
	CGContextRef bitmap = createBitmapContext(CGImageGetWidth(paper_gray), CGImageGetHeight(paper_gray));
	CGContextDrawImage(bitmap,
	                   CGRectMake(0.0, 0.0, CGImageGetWidth(paper_gray), CGImageGetHeight(paper_gray)),
	                   paper_gray);
	CGImageRelease(paper_gray);

	CGImageRef bitmap_image = CGBitmapContextCreateImage(bitmap);
	NSURL* destURL = [NSURL fileURLWithPath:@"rowbackground.png" isDirectory:NO];
	CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL((CFURLRef)destURL, kUTTypePNG, 1, NULL);
	CGImageDestinationAddImage(imageDest, bitmap_image, NULL);
	CGImageDestinationFinalize(imageDest);
	CFRelease(imageDest);
	CGImageRelease(bitmap_image);

	CGContextRelease(bitmap);

	[pool release];
	return 0;
}

