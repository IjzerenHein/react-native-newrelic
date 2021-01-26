#import "RNNewRelicModule.h"
#import "RCTConvert.h"
#import "RCTExceptionsManager.h"

@implementation RNNewRelic

RCT_EXPORT_MODULE();

/**
 * Test a native crash
 */
RCT_EXPORT_METHOD(crashNow:(NSString *)message){
    [NewRelic crashNow:message];
}

/**
 * Track a method as an interaction
 */
RCT_EXPORT_METHOD(startInteraction:(NSString *)interactionName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSString* interactionId = [NewRelic startInteractionWithName:(NSString * _Null_unspecified)interactionName];
        resolve((NSString *)interactionId);
    } @catch (NSException *exception) {
        [NewRelic recordHandledException:exception];
        reject(@"interactionId", @"Start interaction false!", nil);
    }
}

/**
 * End an interaction
 * Required. The string ID for the interaction you want to end.
 * This string is returned when you use startInteraction().
 */
RCT_EXPORT_METHOD(endInteraction:(NSString *)interactionId) {
    [NewRelic stopCurrentInteraction:(NSString * _Null_unspecified)interactionId];
}

/**
 * VIEW_LOADING    Creating sub views, controls, and other related tasks
 * VIEW_LAYOUT    Inflation of layouts, resolving components
 * DATABASE    SQLite and other file I/O
 * IMAGE    Image loading and processing
 * JSON    JSON parsing or creation
 * NETWORK    Web service integration methods, remote resource loading
 * Create custom metrics
 */
RCT_EXPORT_METHOD(recordMetric:(NSString *)name category:(NSString *)category attrs:(NSDictionary *)attrs)
{
    NSNumber *value = attrs[@"totalValue"];
    NRMetricUnit *vUnits = attrs[@"valueUnit"];
    NRMetricUnit *cUnits = attrs[@"countUnit"];

    [NewRelic recordMetricWithName:(NSString * _Nonnull)name category:(NSString * _Nonnull)category value:(NSNumber * _Nonnull)value valueUnits:(NRMetricUnit * _Nullable)vUnits countUnits:(NRMetricUnit * _Nullable)cUnits];
}

/**
 * Create or update an attribute
 */
RCT_EXPORT_METHOD(setAttribute:(NSString *)name data:(NSDictionary *)data)
{
    id value = data[@"value"];
    [NewRelic setAttribute:(NSString * _Nonnull)name value:(id _Nonnull)value];
}

/**
 * Create or update multiple attributes
 */
RCT_EXPORT_METHOD(setAttributes:(NSDictionary *)attributes){
    for (NSString *key in attributes) {
        if ([[attributes valueForKey:key] isKindOfClass:[NSString class]] || [[attributes valueForKey:key] isKindOfClass:[NSNumber class]] || [[attributes valueForKey:key] isKindOfClass:[[NSNumber numberWithBool:YES] class]] || [[attributes valueForKey:key] isKindOfClass:[[NSNumber numberWithBool:YES] class]]) {
            [NewRelic setAttribute:(NSString * _Nonnull)key value:(id _Nonnull)[attributes valueForKey:key]];
        }
    }
}

/**
 * This method removes the attribute specified by the name string
 */
RCT_EXPORT_METHOD(removeAttribute:(NSString *)name) {
    [NewRelic removeAttribute:(NSString * _Nonnull)name];
}

/**
 * Set custom user ID for associating sessions with events and attributes
 */
RCT_EXPORT_METHOD(setUserId:(NSString *)userId){
  [NewRelic setUserId:(NSString * _Null_unspecified)userId];
}

/**
 * Track app activity that may be helpful for troubleshooting crashes
 */
RCT_EXPORT_METHOD(recordBreadcrumb:(NSString *)name attributes:(NSDictionary *)attributes){
    [NewRelic recordBreadcrumb:(NSString * _Nonnull)name attributes:(NSDictionary * _Nullable)attributes];
}

/**
 * Creates and records a custom event, for use in New Relic Insights
 *
 * IMPORTANT! considerations and best practices include:
 *
 * - You should limit the total number of event types to approximately five.
 * eventType is meant to be used for high-level categories.
 * For example, you might create an event type Gestures.
 *
 * - Do not use eventType to name your custom events.
 * Create an attribute to name an event or use the optional name parameter.
 * You can create many custom events; it is only event types that you should limit.
 *
 * - Using the optional name parameter has the same effect as adding a name key in the attributes dictionary.
 * name is a keyword used for displaying your events in the New Relic UI.
 * To create a useful name, you might combine several attributes.
 */
RCT_EXPORT_METHOD(recordCustomEvent:(NSString *)eventType eventName:(NSString *)eventName attrs:(NSDictionary *)attrs) {
    
    [NewRelic recordCustomEvent:(NSString * _Nonnull)eventType name:(NSString * _Nullable)eventName attributes:(NSDictionary * _Nullable)attrs];
}

/**
 * Record HTTP transactions at varying levels of detail
 */
RCT_EXPORT_METHOD(noticeNetworkRequest:(NSString *)url dict:(NSDictionary *)dict) {
    NSURL *requestUrl = [RCTConvert NSURL:url];
    NSString *method = [RCTConvert NSString:dict[@"httpMethod"]];
//    NSNumber *startTime = [RCTConvert NSNumber:dict[@"startTime"]];
//    NSNumber *endTime = [RCTConvert NSNumber:dict[@"endTime"]];
    NSDictionary *headers = [RCTConvert NSDictionary:dict[@"responseHeader"]];
    NSInteger statusCode = [RCTConvert NSInteger:dict[@"statusCode"]];
    NSUInteger bytesSent = [RCTConvert NSUInteger:dict[@"bytesSent"]];
    NSUInteger bytesReceived = [RCTConvert NSUInteger:dict[@"bytesReceived"]];
    NSDictionary *params = [RCTConvert NSDictionary:dict[@"params"]];
    
    NSData *jsonBody = [dict[@"responseBody"] dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error;
//    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonBody options:0 error:&error];
    
    NRTimer *timer = [NRTimer new];
    
    [NewRelic noticeNetworkRequestForURL:(NSURL * _Null_unspecified)requestUrl httpMethod:(NSString * _Null_unspecified)method withTimer:(NRTimer * _Null_unspecified)timer responseHeaders:(NSDictionary * _Null_unspecified)headers statusCode:(NSInteger)statusCode bytesSent:(NSUInteger)bytesSent bytesReceived:(NSUInteger)bytesReceived responseData:(NSData * _Null_unspecified)jsonBody andParams:(NSDictionary * _Nullable)params];
}

/*
 * Record network failures
 */
RCT_EXPORT_METHOD(noticeNetworkFailure:(NSString *)url dict:(NSDictionary *)dict) {
    NSURL *requestUrl = [RCTConvert NSURL:url];
    NSString *method = [RCTConvert NSString:dict[@"httpMethod"]];
    NSInteger statusCode = [RCTConvert NSInteger:dict[@"statusCode"]];
    NRTimer *timer = [NRTimer new];
    [NewRelic noticeNetworkFailureForURL:(NSURL * _Null_unspecified)requestUrl httpMethod:(NSString * _Null_unspecified)method withTimer:(NRTimer * _Null_unspecified)timer andFailureCode:(NSInteger)statusCode];
}

/**
 * Record js exception
 */
RCT_EXPORT_METHOD(reportJSException:(NSDictionary *)jsException) {
    NSString *message = [RCTConvert NSString:jsException[@"message"]];
    NSArray<NSDictionary *> *stack = [RCTConvert NSDictionaryArray:jsException[@"stack"]];
    NSString *description = [@"Unhandled JS Exception: " stringByAppendingString:message];
    NSDictionary *errorInfo = @{NSLocalizedDescriptionKey : description, RCTJSStackTraceKey : stack};
    NSError *error = [NSError errorWithDomain:RCTErrorDomain code:0 userInfo:errorInfo];
    
    NSString *name = [NSString stringWithFormat:@"%@: %@", RCTFatalExceptionName, error.localizedDescription];
    // Truncate the localized description to 175 characters to avoid wild screen overflows
    NSString *errMessage = RCTFormatError(error.localizedDescription, error.userInfo[RCTJSStackTraceKey], 175);
    // Attach an untruncated copy of the description to the userInfo, in case it is needed
    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
    [userInfo setObject:RCTFormatError(error.localizedDescription, error.userInfo[RCTJSStackTraceKey], -1)
                 forKey:@"RCTUntruncatedMessageKey"];
    
    [NewRelic recordHandledException:(NSException * _Nonnull)[[NSException alloc] initWithName:name reason:errMessage userInfo:userInfo]];
}

@end
