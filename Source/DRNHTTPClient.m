// DRNHTTPClient.h
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

#import "DRNHTTPClient.h"
#import "DRNHTTPClient+Private.h"

#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import <DRNRACNetworkClient/DRNHTTPRequest.h>
#import <DRNRACNetworkClient/DRNHTTPClientResponse.h>
#import <DRNRACNetworkClient/DRNParser.h>

#import <DRNRACNetworkClient/DRNErrorFactory.h>

static NSTimeInterval const kDRNHTTPClientTimeoutRequests = 10.f;

@interface DRNHTTPClient ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *currentClient;

@property (nonatomic, copy, readonly) NSString *baseURL;

@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t completionQueue;

@end

@implementation DRNHTTPClient

- (instancetype)initWithBaseURL:(NSString *)baseURL
				   errorFactory:(id<DRNErrorFactory>)errorFactory
	 httpClientResponseProvider:(id<DRNHTTPClientResponseProvider>)httpClientResponseProvider
{
	NSParameterAssert(baseURL);
	NSParameterAssert(errorFactory);
	NSParameterAssert(httpClientResponseProvider);
	
	if (self = [super init]) {
		_baseURL = [baseURL copy];
		_errorFactory = errorFactory;
		_httpClientResponseProvider = httpClientResponseProvider;
		
		[self commonInit];
	}

	return self;
}

- (void)commonInit
{
	_completionQueue = dispatch_queue_create("com.drn.networkLayer.completionQueueDRNHTTPClient", DISPATCH_QUEUE_SERIAL);
	
	[self createClient];
}

- (NSURL *)entryPointURL
{	
	return [NSURL URLWithString:self.baseURL];
}

- (void)createClient
{
	_currentClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[self entryPointURL]];
	
	_currentClient.completionQueue = self.completionQueue;
	_currentClient.requestSerializer = [AFJSONRequestSerializer serializer];
	_currentClient.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method 
									  path:(NSString *)path 
								parameters:(NSDictionary *)parameters
{	
	NSURL *url = [NSURL URLWithString:path relativeToURL:self.currentClient.baseURL];
	
	return [self.currentClient.requestSerializer requestWithMethod:method
														 URLString:[url absoluteString]
														parameters:parameters
															 error:nil];
}

- (NSOperationQueue *)operationQueue
{
	return self.currentClient.operationQueue;
}

- (AFHTTPRequestOperation *)operationWithRequest:(DRNHTTPRequest *)httpRequest
										 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
										 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self buildURLRequestFromHTTPRequest:httpRequest];
    
	if ([request URL] == nil || [[request URL] isEqual:[NSNull null]]) {
		return nil;
	}
	
	return [self.currentClient 
			HTTPRequestOperationWithRequest:request
			success:^(AFHTTPRequestOperation *operation, id responseObject) {
				if (success)
					success(operation, responseObject);
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				if (failure)
					failure(operation, error);
			}];
}

#pragma mark - Requests related methods

- (RACSignal *)enqueueRequest:(DRNHTTPRequest *)request
{
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		AFHTTPRequestOperation *operation = 
		[self operationWithRequest:request
						   success:^(AFHTTPRequestOperation *operation, id responseObject) {
								
							   [subscriber sendNext:RACTuplePack(operation.response, responseObject)];
							   [subscriber sendCompleted]; 
							   
						   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
							   							   
							   [subscriber sendError:[self.errorFactory errorWithCode:error.code
																			 userInfo:error.userInfo]];
						   }];
		
		//TODO: Evaluate return callbacks
		[self.operationQueue addOperation:operation];

		return [RACDisposable disposableWithBlock:^{
			[operation cancel];
		}];
	}];
	
	return signal;
}

- (RACSignal *)enqueueRequest:(DRNHTTPRequest *)request objectResultsParser:(id<DRNParser>)resultObjectsParser
{
	@weakify(self);
	return [[[[self enqueueRequest:request] 
			reduceEach:^id(NSHTTPURLResponse *response, id responseObject) {
				return [[self 
						 parseResponseObject:responseObject withParser:request.resultObjectsParser]
						 map:^id(id parsedObject) {
							 @strongify(self);
							 return [self.httpClientResponseProvider clientResponseWithHTTPResponse:response
																					 responseObject:parsedObject];		
						}];
			 }]
			concat]
			replayLazily];
}

- (RACSignal *)parseResponseObject:(id)responseObject withParser:(id<DRNParser>)parser
{
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		
		if ([responseObject isKindOfClass:NSDictionary.class]) {
			id nextObject = parser ? [parser parseObjectFromObject:responseObject]
								   : responseObject;
			
			[subscriber sendNext:nextObject];
			[subscriber sendCompleted];			
		
		}else if (responseObject == nil) {
			[subscriber sendCompleted];
			
		} else {
			[subscriber sendError:[DRNErrorFactory HTTPResponseParsingError]];
		}
		
		return nil;
	}];
}

#pragma mark - Private methods

- (NSURLRequest *)buildURLRequestFromHTTPRequest:(DRNHTTPRequest *)httpRequest
{	    
    NSMutableURLRequest *request = [self requestWithMethod:httpRequest.requestMethod
													  path:httpRequest.path
												parameters:httpRequest.parametersDictionary];
		
    NSMutableDictionary *allHeaders = [request.allHTTPHeaderFields mutableCopy];
    [allHeaders addEntriesFromDictionary:httpRequest.requestHeaderFields];
    [request setAllHTTPHeaderFields:allHeaders];
	[request setTimeoutInterval:kDRNHTTPClientTimeoutRequests];

    return request;
}

@end


@implementation DRNHTTPClient (DRNHTTPRequests)

- (RACSignal *)makeRequest:(DRNHTTPRequest *)request
{
	return [self enqueueRequest:request objectResultsParser:request.resultObjectsParser];
}

@end
