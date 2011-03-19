#include <stdio.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

int main(int argc, char* argv[])
{
	printf("blarg\n");
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	NSURL* url = [NSURL fileURLWithPath:@"paperstrip_gray.png" isDirectory:NO];
	CGImageSourceRef paper_source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
	CGImageRef paper_gray = CGImageSourceCreateImageAtIndex(paper_source, 0, NULL);
	CFRelease(paper_source);
	if(paper_gray == NULL)
	{
		printf("Could not open paperstrip image\n");
		return 1;
	}
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmap = CGBitmapContextCreate(NULL,
	                                            CGImageGetWidth(paper_gray),
	                                            CGImageGetHeight(paper_gray),
	                                            8,
	                                            4*CGImageGetWidth(paper_gray),
	                                            rgbColorSpace,
	                                            kCGImageAlphaPremultipliedLast);
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

