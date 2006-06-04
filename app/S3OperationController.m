//
//  S3OperationController.m
//  S3-Objc
//
//  Created by Olivier Gutknecht on 4/8/06.
//  Copyright 2006 Olivier Gutknecht. All rights reserved.
//

#import "S3OperationController.h"
#import "S3Application.h"

#pragma mark -
#pragma mark The operation console/inspector itself


@implementation S3OperationController

+ (void) initialize
{
	[NSValueTransformer setValueTransformer:[[S3OperationSummarizer new] autorelease] forName:@"S3OperationSummarizer"];
}

-(void)awakeFromNib
{
	NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"OperationConsoleToolbar"] autorelease];
	[toolbar setDelegate:self];
	[toolbar setVisible:YES];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:NO];
	[toolbar setSizeMode:NSToolbarSizeModeSmall];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
	[[self window] setToolbar:toolbar];
}

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects: NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		@"Stop", @"Remove", @"Info", nil];
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects: @"Info", @"Remove", NSToolbarFlexibleSpaceItemIdentifier, @"Stop", nil]; 
}

- (BOOL) validateToolbarItem:(NSToolbarItem*)theItem
{
	if ([[theItem itemIdentifier] isEqualToString:@"Stop"])
	{	
		NSEnumerator* e = [[_operationsArrayController selectedObjects] objectEnumerator];
		S3Operation* op;
		while (op = [e nextObject]) 
		{
			if ([op active])
				return TRUE;
		}
		return FALSE;
	}

	return TRUE;
}

-(IBAction)stop:(id)sender;
{
	NSEnumerator* e = [[_operationsArrayController selectedObjects] objectEnumerator];
	S3Operation* op;
	while (op = [e nextObject]) 
	{
		if ([op active])
			[op stop:self];
	}	
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar:(BOOL) flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
	
	if ([itemIdentifier isEqualToString: @"Stop"])
	{
		[item setLabel: NSLocalizedString(@"Stop", nil)];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: @"stop.icns"]];
		[item setTarget:self];
		[item setAction:@selector(stop:)];
    }
	else if ([itemIdentifier isEqualToString: @"Remove"])
	{
		[item setLabel: NSLocalizedString(@"Remove", nil)];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: @"delete.icns"]];
		[item setTarget:_operationsArrayController];
		[item setAction:@selector(remove:)];
    }
	else if ([itemIdentifier isEqualToString: @"Info"])
	{
		[item setLabel: NSLocalizedString(@"Info", nil)];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: @"info.icns"]];
		[item setTarget:_infoPanel];
		[item setAction:@selector(orderFront:)];
    }
	
    return [item autorelease];
}
@end

#pragma mark -
#pragma mark Categories and transformers to facilitate bindings

@implementation S3OperationSummarizer
+ (Class) transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL) allowsReverseTransformation
{
	return NO;
}

- (id) transformedValue:(id)data
{
	NSString* s = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if (s==nil)
		s = @"";
	return [[[NSAttributedString alloc] initWithString:s] autorelease];		
}

@end

@interface NSHTTPURLResponse (Logging)
-(NSString*)httpStatus;
-(NSArray*)headers;
@end

@implementation NSHTTPURLResponse (Logging)

-(NSString*)httpStatus
{
	return [NSString stringWithFormat:@"%d (%@)",[self statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[self statusCode]]];
}

-(NSArray*)headers
{
	NSMutableArray* a = [NSMutableArray array];
	NSEnumerator* e = [[self allHeaderFields] keyEnumerator];
	NSString* k;
	while (k = [e nextObject])
	{
		[a addObject:[NSDictionary dictionaryWithObjectsAndKeys:k,@"key",[[self allHeaderFields] objectForKey:k],@"value",nil]];
	}
	return a;
}

@end


@interface NSURLRequest (Logging)
-(NSArray*)headers;
@end 

@implementation NSURLRequest (Logging)

-(NSArray*)headers
{
	NSMutableArray* a = [NSMutableArray array];
	NSEnumerator* e = [[self allHTTPHeaderFields] keyEnumerator];
	NSString* k;
	while (k = [e nextObject])
	{
		[a addObject:[NSDictionary dictionaryWithObjectsAndKeys:k,@"key",[[self allHTTPHeaderFields] objectForKey:k],@"value",nil]];
	}
	return a;
}

@end


