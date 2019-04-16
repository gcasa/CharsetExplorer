//
//  main.m
//  CharsetExplorer
//
//  Created by Gregory John Casamento on 4/8/19.
//  Copyright © 2019 Gregory John Casamento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyMethod)
- (NSString *) myStringByAddingPercentEncodingWithAllowedCharacters: (NSCharacterSet *)aSet;
@end

@implementation NSString (MyMethod)
- (NSString *) myStringByAddingPercentEncodingWithAllowedCharacters: (NSCharacterSet *)aSet
{
    NSData    *data = [self dataUsingEncoding: NSUTF8StringEncoding];
    NSString    *s = nil;
    
    if (data != nil)
    {
        unsigned char    *src = (unsigned char*)[data bytes];
        unsigned int    slen = [data length];
        unsigned char    *dst;
        unsigned int    spos = 0;
        unsigned int    dpos = 0;
        
        dst = (unsigned char*)NSZoneMalloc(NSDefaultMallocZone(), slen * 3);
        while (spos < slen)
        {
            unichar    c = src[spos++];
            unsigned int    hi;
            unsigned int    lo;
            
            if([aSet characterIsMember: c]) // if the character is in the allowed set, put it in
            {
                dst[dpos++] = c;
            }
            else // if not, then encode it...
            {
                dst[dpos++] = '%';
                hi = (c & 0xf0) >> 4;
                dst[dpos++] = (hi > 9) ? 'A' + hi - 10 : '0' + hi;
                lo = (c & 0x0f);
                dst[dpos++] = (lo > 9) ? 'A' + lo - 10 : '0' + lo;
            }
        }
        s = [[NSString alloc] initWithBytes: dst
                                     length: dpos
                                   encoding: NSUTF8StringEncoding];
        NSZoneFree(NSDefaultMallocZone(), dst);
    }
    return s;
}
@end

BOOL testUrlCharacterSetEncoding(NSString* decodedString, NSString* encodedString, NSCharacterSet* allowedCharacterSet)
{
    NSLog(@"String by adding percent");
    NSString* testString = [decodedString myStringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    NSLog(@"String by adding percent, done. test=%@ decoded=%@", testString, decodedString);
    return [encodedString isEqualToString: testString];
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
         0 - 9
         a - z
         A - Z
         ? / : @ - . _ ~ ! $ & ' ( ) * + , ; =
         */
        NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:
                              @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ?/:@-._~!$&'()*+,="];
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSCharacterSet *charSet = [NSCharacterSet URLHostAllowedCharacterSet];
        NSData *data = [charSet bitmapRepresentation];
        [data writeToFile:@"URLHostAllowedCharacterSet" atomically:YES];

        charSet = [NSCharacterSet URLPathAllowedCharacterSet];
        data = [charSet bitmapRepresentation];
        [data writeToFile:@"URLPathAllowedCharacterSet" atomically:YES];

        charSet = [NSCharacterSet URLUserAllowedCharacterSet];
        data = [charSet bitmapRepresentation];
        [data writeToFile:@"URLUserAllowedCharacterSet" atomically:YES];
        
        charSet = [NSCharacterSet URLFragmentAllowedCharacterSet];
        data = [charSet bitmapRepresentation];
        [data writeToFile:@"URLFragmentAllowedCharacterSet" atomically:YES];
        
        charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        data = [charSet bitmapRepresentation];
        [data writeToFile:@"URLQueryAllowedCharacterSet" atomically:YES];
        
        charSet = [NSCharacterSet URLPasswordAllowedCharacterSet];
        data = [charSet bitmapRepresentation];
        [data writeToFile:@"URLPasswordAllowedCharacterSet" atomically:YES];
        
        NSLog(@"Test2");
        NSString *urlDecodedString = @"https://www.microsoft.com/en-us/!@#$%^&*()_";
        NSString *urlEncodedString = @"https://www.microsoft.com/en-us/!@%23$%25%5E&*()_";
        NSCharacterSet *allowedCharacterSet = [NSCharacterSet URLFragmentAllowedCharacterSet];
        testUrlCharacterSetEncoding(urlDecodedString, urlEncodedString, cs);
        
        
        NSCharacterSet *theSet = [NSCharacterSet URLFragmentAllowedCharacterSet];
        NSString *setString = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ?/:@-._~!$&'()*+,=";
        NSUInteger i = 0;
        for(i = 0; i < [setString length]; i++)
        {
            char c = [setString characterAtIndex: i];
            NSString *msg = [NSString stringWithFormat: @"Checking URLFragmentAllowedCharacterSet for %c", c];
            if([theSet characterIsMember: c] == NO) // , [msg cStringUsingEncoding: NSUTF8Encoding]);
            {
                NSLog(@"%c is not in set", c);
            }
            else
            {
                NSLog(@"Success");
            }
        }
    }
    return 0;
}
