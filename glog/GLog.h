#define RLOG_IP_ADDRESS "10.0.0.99"
#define RLOG_PORT "5000"

BOOL writeToLogFile = YES;

void FSLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName1", formattedMessage);
    NSDateFormatter *dateFormatter = nil;
    NSFileManager *logManager = nil;
    NSString *logPath = @"/private/var/mobile/notiblock.txt" ; 
    NSFileHandle *logHandle = nil;
    NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName2", formattedMessage);

    if ( writeToLogFile ) {
        NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName3", formattedMessage);
        if ( !dateFormatter)
            dateFormatter = [[NSDateFormatter alloc] init];

        NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName4", formattedMessage);
        [dateFormatter setDateFormat:@"M/d/yy, h:mm:ss aa"];

        NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName5", formattedMessage);
        if ( !logManager )
            logManager = [NSFileManager defaultManager];

        NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName6", formattedMessage);
        if ( ![logManager fileExistsAtPath:logPath] ) {
            NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName6.1", formattedMessage);
            [[NSString stringWithFormat: @"%@ - %@\n", [[dateFormatter stringFromDate:[NSDate date]] lowercaseString], formattedMessage] writeToFile:logPath atomically:YES encoding: NSUTF8StringEncoding error:NULL];
        } else {
            NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName6.2", formattedMessage);
            logHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
            if (logHandle == nil)
                    NSLog(@"Failed to open file");

            [logHandle seekToEndOfFile];
            NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName6.3", formattedMessage);
            [logHandle writeData:[[NSString stringWithFormat: @"%@ - %@\n", [[dateFormatter stringFromDate:[NSDate date]] lowercaseString], formattedMessage] dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName6.4", formattedMessage);
            [logHandle closeFile];
            NSLog(@"QWERTYASDF FSLog %@: %@", @"TweakName6.5", formattedMessage);
        }
    }

    NSLog(@"QWERTYASDF ⛔ DONE ******* FSLog %@: %@", @"TweakName7", formattedMessage);
}


void RLogv(NSString* format, va_list args)
{
    NSString* log = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"QWERTYASDF Log: %@", log);

    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%s:%s/", RLOG_IP_ADDRESS, RLOG_PORT]];

    NSLog(@"QWERTYASDF RLogv:  URL %@", url);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
        cachePolicy:NSURLRequestUseProtocolCachePolicy
        timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];

    // Create a simple dictionary with numbers.
    NSDictionary *mapData;
    NSData *base64data = [log dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64string = [base64data base64EncodedStringWithOptions:0];
    mapData = @{ @"GLog" : base64string };
    
    NSLog(@"QWERTYASDF RLogv2:  URL %@", url);

    // Convert the dictionary into JSON data.
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];

    NSLog(@"QWERTYASDF RLogv3:  URL %@", url);

    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        // NSLog(@"QWERTYASDF 4: ****** RRRRRRRRRLOG ***** Request reply: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        // if(httpResponse.statusCode == 200)
        // {
            // NSLog(@"QWERTYASDF RLogv5: ⛔ The response is - %@",[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        // }
        // else
        // {
            // NSLog(@"QWERTYASDF RLogv6: ⛔ Status Code %@", @(httpResponse.statusCode));     
        // }
    }];
    [postDataTask resume];
    NSLog(@"QWERTYASDF RLogv7 ***** ⛔ FINISHED ***** :  URL %@", url);

    FSLog(@"QWERTYASDF FSLog: %@", log);
}


void RLog(NSString* format, ...)
{
    va_list args;
    va_start(args, format);
    RLogv(format, args);
    va_end(args);
}