//
//  DRNHTTPClientResponseProvider.m
//  Pods
//
//  Created by David Rico Nieto on 24/8/15.
//
//

#import "DRNHTTPClientResponseProvider.h"

@implementation DRNHTTPClientResponseProvider

#pragma mark - DRNHTTPClientResponseProvider protocol methods

- (id<DRNHTTPClientResponse>)clientResponseWithHTTPResponse:(NSHTTPURLResponse *)httpResponse responseObject:(id)responseObject
{
	return [[DRNHTTPClientResponse alloc] initWithHTTPResponse:httpResponse responseObject:responseObject];
}

@end
