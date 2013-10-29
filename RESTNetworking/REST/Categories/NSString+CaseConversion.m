//
//  NSString+CaseConversion.m
//  TMSMobile
//
//  Created by Robert Walker on 8/23/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import "NSString+CaseConversion.h"

@implementation NSString (NSString_CaseConversion)

- (NSString *)camelize
{
    return [self camelizeWithFirstLetterCapitialized:NO];
}

- (NSString *)camelizeWithFirstLetterCapitialized:(BOOL)capitializeFirstLetter
{
	NSMutableString *resultString = [NSMutableString stringWithCapacity:20];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSString *searchString = nil;
    NSCharacterSet *separatorChars = [NSCharacterSet characterSetWithCharactersInString:@"_-"];
	int last_location = 0;
	
	while (![scanner isAtEnd]) {
		// Remember the last location of the scanner (initially zero)
		last_location = [scanner scanLocation];
		
		// Scan up to the next (or first) hyphen into a temporary string
        [scanner scanUpToCharactersFromSet:separatorChars intoString:&searchString];
		
		// Append search string to result capitalizing words
		if (last_location == 0 && capitializeFirstLetter == NO)
			[resultString appendString:searchString];
		else
			[resultString appendString:[searchString capitalizedString]];
        
		// Advance the scanner one character past the separator we just found
		// unless the scanner is already at the end of the string
		if ([scanner scanLocation] < [self length]) {
			[scanner setScanLocation: [scanner scanLocation] + 1];
		}
	}
	
	return resultString;
}

- (NSString *)underscore
{
    return [self decamelizeWithSeparator:@"_"];
}

- (NSString *)dasherize
{
    return [self decamelizeWithSeparator:@"-"];
}

- (NSString *)decamelizeWithSeparator:(NSString *)theSeperator
{
	NSMutableString *resultString = [NSMutableString stringWithCapacity:20];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSString *searchString;
	
	// Make scanner case sensitive
	[scanner setCaseSensitive:YES];
	
	while (![scanner isAtEnd]) {
		searchString = nil;
		
		// Scan up to the next (or first) capital letter into a temporary string
		[scanner scanUpToCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet] intoString:&searchString];
		
		// Append search string to result converted to lower case
		if (searchString != nil) {
			[resultString appendString:[searchString lowercaseString]];
		}
		
		// Append the hyphen character and the character at current scan location converted to lowercase
		if (![scanner isAtEnd]) {
            // Don't add hyphen in first position of result string
			if ([scanner scanLocation] != 0) {
				[resultString appendString:theSeperator];
			}
			[resultString appendString:[[self substringWithRange:NSMakeRange([scanner scanLocation], 1)] lowercaseString]];
			
			// Advance the scanner one character past the hyphen we just found
			[scanner setScanLocation: [scanner scanLocation] + 1];
		}
	}
	
	return resultString;
}

- (NSString *)humanize
{
    NSMutableString *resultString = [NSMutableString stringWithCapacity:20];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSString *searchString;
    NSCharacterSet *uppperChars = [NSCharacterSet uppercaseLetterCharacterSet];
    NSCharacterSet *lowerChars = [NSCharacterSet lowercaseLetterCharacterSet];
    NSCharacterSet *underscoreAndDash = [NSCharacterSet characterSetWithCharactersInString:@"_-"];
    BOOL isCamelMode = NO;
    
    // Make scanner case sensitive
    [scanner setCaseSensitive:YES];
    
    // Set scanning mode
    if ([self rangeOfCharacterFromSet:underscoreAndDash].location == NSNotFound) {
        isCamelMode = YES;
    }
    
    while ([scanner isAtEnd] == NO) {
        searchString = nil;
        
        if (isCamelMode) {
            // Scan lower case characters 
            [scanner scanCharactersFromSet:lowerChars intoString:&searchString];
            
            if (searchString && [resultString length] == 0) {
                [resultString appendString:[searchString capitalizedString]];
            }
            else {
                if ([resultString length] > 0) {
                    [resultString appendString:@" "];
                }
                
                // Scan upper case characters
                searchString = nil;
                [scanner scanCharactersFromSet:uppperChars intoString:&searchString];
                if ([scanner scanLocation] < [self length]) {
                    if ([searchString length] > 1) {
                        // The last uppercase character in searchString starts a new word
                        [resultString appendString:
                         [searchString substringToIndex:[searchString length] - 2]];
                        [resultString appendFormat:@" %@",
                         [searchString substringWithRange:NSMakeRange([searchString length], 1)]];
                    }
                    else {
                        // The uppercase character starts the next word
                        [resultString appendFormat:@"%@", searchString];
                        searchString = nil;
                        [scanner scanCharactersFromSet:lowerChars intoString:&searchString];
                        if (searchString) {
                            [resultString appendString:searchString];
                        }
                    }
                }
            }
        }
        else {
            // Scan up to first separator
            [scanner scanUpToCharactersFromSet:underscoreAndDash intoString:&searchString];
            
            // Append the capitalized word
            if ([resultString length] > 0) {
                [resultString appendString:@" "];
            }
            [resultString appendString:[searchString capitalizedString]];
            
            // Advance the scanner one character past the separator we just found
            // unless the scanner is already at the end of the string
            if ([scanner scanLocation] < [self length]) {
                [scanner setScanLocation: [scanner scanLocation] + 1];
            }
        }
    }

    return resultString;
}

@end
