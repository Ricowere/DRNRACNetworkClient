// DRNParser.m
// Copyright (c) 2015 David Rico Nieto
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DRNParser.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation DRNParser

- (NSArray *)parseObjectsFromArray:(NSArray *)objects;
{
	RACSequence *sequence = objects.rac_sequence;
	
	return [sequence 
			map:^id(id value) {
				id mappedValue = [self parseObjectFromObject:value];
				
				NSParameterAssert(mappedValue);
				
				return mappedValue;
			}].array;
}

- (id)parseObjectFromObject:(id)object
{
	NSException *ex = [NSException exceptionWithName:@"Invalid call on abstract method"
											  reason:
					   [NSString stringWithFormat:@"Please give an implementation of method %@",NSStringFromSelector(_cmd)]
											userInfo:nil];
	[ex raise];

	return nil;
}

@end
