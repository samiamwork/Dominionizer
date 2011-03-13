#import <stdio.h>
#import <stdlib.h>
#import <Foundation/Foundation.h>

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
			[card setValue:[NSString stringWithCString:word encoding:NSUTF8StringEncoding] forKey:headers[headerIndex]];
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

