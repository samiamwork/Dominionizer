#import <stdio.h>
#import <stdlib.h>
#import <Foundation/Foundation.h>

NSString* coin_big_start   = @"<p class=\"coin_big\">";
NSString* coin_big_end     = @"</p>";
NSString* vp_big_start     = @"<p class=\"vp_big\">";
NSString* vp_big_end       = @"</p>";
NSString* coin_small_start = @"<span class=\"coin_small\">";
NSString* coin_small_end   = @"</span>";
NSString* vp_small_start   = @"<span class=\"vp_small\">";
NSString* vp_small_end     = @"</span>";

NSString* substitute(NSString* search, NSString* target, NSString* replacementStart, NSString* replacementEnd)
{
	NSRange foundRange;
	NSRange notFound = NSMakeRange(NSNotFound, 0);
	//NSCharacterSet* ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSCharacterSet* ws = [NSCharacterSet characterSetWithCharactersInString:@"\n\t +-_><[]"];
	while(!NSEqualRanges(notFound, (foundRange = [search rangeOfString:target])))
	{
		NSUInteger index = foundRange.location;
		// TODO: Fix text
		while(index > 0 && ![ws characterIsMember:[search characterAtIndex:index-1]])
		{
			index--;
		}
		// If we found a string to include
		if(index < foundRange.location)
		{
			NSRange valueRange = NSMakeRange(index, foundRange.location-index);
			NSString* value = [search substringWithRange:valueRange];
			NSRange fullRange = NSMakeRange(index, NSMaxRange(foundRange)-index);
			NSString* replacement = [NSString stringWithFormat:@"%@%@%@",
			                                  replacementStart,
			                                  value,
			                                  replacementEnd];
			search = [search stringByReplacingCharactersInRange:fullRange withString:replacement];
		}
		else
		{
			NSString* replacement = [NSString stringWithFormat:@"%@&nbsp;%@",
			                                  replacementStart,
			                                  replacementEnd];
			search = [search stringByReplacingCharactersInRange:foundRange withString:replacement];
		}
	}

	return search;
}

int main(int argc, char* argv[])
{
	char buffer[2*1024];
	const char* filename = argv[1];
	FILE* file = fopen(filename, "rb");
	if(file == NULL)
	{
		printf("Could not open file \"%s\"\n", filename);
		return 1;
	}

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray* rows = [[NSMutableArray alloc] init];
	char* word;
	char* last;
	NSString* headers[] = {
		@"card",
		@"set",
		@"type",
		@"cost",
		@"rules"
	};
	while(fgets(buffer, 2*1024, file))
	{
		NSMutableDictionary* card = [NSMutableDictionary dictionary];
		int headerIndex = 0;
		for(word = strtok_r(buffer, "\t", &last); word; word = strtok_r(NULL, "\t", &last))
		{
			NSString* value = [NSString stringWithCString:word encoding:NSUTF8StringEncoding];
			if([headers[headerIndex] isEqualToString:@"rules"])
			{
				value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"<br />\n"];
				value = [value stringByReplacingOccurrencesOfString:@"________" withString:@"<hr />\n"];
				// Make into HTML string
				value = substitute(value, @"<$>", coin_small_start, coin_small_end);
				value = substitute(value, @"<^$>", coin_big_start, coin_big_end);
				value = substitute(value, @"<VP>", vp_small_start, vp_small_end);
				value = substitute(value, @"<^VP>", vp_big_start, vp_big_end);
			}
			[card setValue:value forKey:headers[headerIndex]];
			headerIndex++;
		}
		[rows addObject:card];
	}
	NSString* inputFileName = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
	NSString* outputFileName = [[inputFileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
	[rows writeToFile:outputFileName atomically:YES];
	[rows release];
	fclose(file);

	[pool release];
	return 0;
}

