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

CGContextRef createBitmapContext(size_t width, size_t height, CGColorSpaceRef cs)
{
	CGColorSpaceRef colorSpace;
	if(cs == NULL)
	{
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	else
	{
		colorSpace = cs;
	}
	// HACK: assuming single component color space doesn't want alpha
	int components = CGColorSpaceGetNumberOfComponents(colorSpace);
	if(components > 1)
	{
		components++;
	}
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
	                                                   width,
	                                                   height,
	                                                   8,
	                                                   components*width,
	                                                   colorSpace,
	                                                   components > 1 ? kCGImageAlphaPremultipliedLast : 0);

	if(cs == NULL)
	{
		CFRelease(colorSpace);
	}

	return bitmapContext;
}

void writeImage(CGImageRef theImage, const char* path, CGColorSpaceRef cs)
{
	if(cs != NULL)
	{
		CGRect imageRect = CGRectMake(0.0, 0.0, CGImageGetWidth(theImage), CGImageGetHeight(theImage));
		CGContextRef bitmapContext = createBitmapContext(imageRect.size.width,
		                                                 imageRect.size.height,
		                                                 cs);
		CGContextDrawImage(bitmapContext,
		                   imageRect,
		                   theImage);
		theImage = CGBitmapContextCreateImage(bitmapContext);
		CFRelease(bitmapContext);
		if(theImage == NULL)
		{
			printf("error converting image to color space\n");
			return;
		}
	}
	CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL,
	                                                       (const UInt8*)path,
	                                                       strlen(path),
	                                                       false);
	CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
	CGImageDestinationAddImage(imageDest, theImage, NULL);
	CGImageDestinationFinalize(imageDest);

	CFRelease(imageDest);
	CFRelease(url);

	if(cs != NULL)
	{
		CGImageRelease(theImage);
	}
}

void writeBitmapContext(CGContextRef theContext, const char* path)
{
	CGImageRef image = CGBitmapContextCreateImage(theContext);
	writeImage(image, path, NULL);
	CGImageRelease(image);
}

void makeBackground(void)
{
	CGImageRef paper_gray = openImage("paperstrip_gray.png");
	if(paper_gray == NULL)
	{
		return;
	}
	CGContextRef bitmap = createBitmapContext(CGImageGetWidth(paper_gray), CGImageGetHeight(paper_gray), NULL);
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

void convertImageToColorSpace(const char* path, CGColorSpaceRef cs)
{
	char fileName[100];
	sprintf(fileName, "_%s", path);
	printf("writing to \"%s\"\n", fileName);
	CGImageRef theImage = openImage(path);
	if(theImage == NULL)
	{
		return;
	}
	writeImage(theImage, fileName, cs);
	CGImageRelease(theImage);
}

void makeGray(void)
{
	CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();

	convertImageToColorSpace("tear_mask1.png", grayColorSpace);
	convertImageToColorSpace("tear_mask1@2x.png", grayColorSpace);
	convertImageToColorSpace("tear_mask2.png", grayColorSpace);
	convertImageToColorSpace("tear_mask2@2x.png", grayColorSpace);
	convertImageToColorSpace("tear_mask3.png", grayColorSpace);
	convertImageToColorSpace("tear_mask3@2x.png", grayColorSpace);
	convertImageToColorSpace("tear_mask4.png", grayColorSpace);
	convertImageToColorSpace("tear_mask4@2x.png", grayColorSpace);

	CGColorSpaceRelease(grayColorSpace);
}

int main(int argc, char* argv[])
{
	printf("blarg\n");
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	//makeBackground();
	makeGray();

	[pool release];
	return 0;
}

