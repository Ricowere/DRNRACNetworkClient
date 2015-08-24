// DRNHTTPRequest.m
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

#import "DRNHTTPRequest.h"

NSString * const kDRNHTTPRequestMethodGET = @"GET";
NSString * const kDRNHTTPRequestMethodPOST = @"POST";
NSString * const kDRNHTTPRequestMethodPUT = @"PUT";
NSString * const kDRNHTTPRequestMethodDELETE = @"DELETE";

@interface DRNHTTPRequest ()

@property (nonatomic, strong) NSMutableDictionary *mutableRequestHeaderFields;
@property (nonatomic, strong) NSMutableDictionary *mutableParametersDictionary;

@end

@implementation DRNHTTPRequest

#pragma mark - Init & dealloc methods

- (instancetype)initWithRequestMethodType:(DRNHTTPRequestMethod)method 
									 path:(NSString *)path
{
    if (self = [super init]) {
		NSParameterAssert(path);
		
        _path = path;		
				
		_mutableRequestHeaderFields = [NSMutableDictionary dictionary];
		_mutableParametersDictionary = [NSMutableDictionary dictionary];		
		
        _requestMethod = method;
    }
    return self;
}

- (NSDictionary *)parametersDictionary
{
	return [self.mutableParametersDictionary copy];
}

- (NSDictionary *)requestHeaderFields
{
	return [self.mutableRequestHeaderFields copy];
}

- (void)addHeaderValue:(id)value forKey:(NSString *)key
{
	self.mutableRequestHeaderFields[key] = value;
}

- (void)addParameterValue:(id)value forKey:(NSString *)key
{
	self.mutableParametersDictionary[key] = value;
}

- (void)addParametersFromDictionary:(NSDictionary *)parameters
{
	[self.mutableParametersDictionary addEntriesFromDictionary:parameters];
}

@end
