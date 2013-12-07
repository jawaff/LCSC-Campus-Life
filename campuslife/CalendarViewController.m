//
//  ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 10/29/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This is for checking to see if an ipad is being used.
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad


#import "CalendarViewController.h"
#import "MonthlyEvents.h"
#import "Preferences.h"
#import "Authentication.h"

@interface CalendarViewController ()


@property (nonatomic, setter=setSignedIn:) BOOL signedIn;

@property (nonatomic) BOOL firstEventsJSONReceived;

@property (nonatomic) MonthlyEvents *events;

@property (nonatomic) Authentication *auth;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"authorizing user");
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    _auth = [Authentication getSharedInstance];
    
    // Initialize the googleOAuth object.
    // Pay attention so as to initialize it with the initWithFrame: method, not just init.
    GoogleOAuth *googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    // Set self as the delegate.
    [googleOAuth setGOAuthDelegate:self];
    
    [googleOAuth authorizeUserWithClienID:@"408837038497.apps.googleusercontent.com"
                           andClientSecret:@"boEOJa_DKR9c06vLWbBdmC92"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/calendar"]];
    
    //Stores the authenticator so that it can be used
    [_auth setAuthenticator:googleOAuth];
    
    [self setSignedIn:NO];
    self.signInOutButton.title = @"Sign In";
    
    _firstEventsJSONReceived = NO;
    
    _events = [MonthlyEvents getSharedInstance];

    if (IDIOM == IPAD) {
        [_cat1Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat2Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat3Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat4Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat5Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
    }
    else {
        [_cat1Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                                     forState:UIControlStateSelected];
        [_cat2Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                            forState:UIControlStateSelected];
        [_cat3Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                            forState:UIControlStateSelected];
        [_cat4Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                                     forState:UIControlStateSelected];
        [_cat5Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                                     forState:UIControlStateSelected];
    }
    
    Preferences *prefs = [Preferences getSharedInstance];
    
    //Here we load the actual state of the selected buttons.
    [_cat1Btn setSelected:[prefs getPreference:1]];
    [_cat2Btn setSelected:[prefs getPreference:2]];
    [_cat3Btn setSelected:[prefs getPreference:3]];
    [_cat4Btn setSelected:[prefs getPreference:4]];
    [_cat5Btn setSelected:[prefs getPreference:5]];
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"view appeared");
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signOutOrSignIn:(id)sender {
    if (_signedIn) {
        // Revoke the access token.
        [[_auth getAuthenticator] revokeAccessToken];
        
        [self setSignedIn:NO];
        
        self.signInOutButton.title = @"Sign In";
        
        _addEventButton.title = @" ";
        _addEventButton.enabled = NO;
        
        [_collectionView reloadData];
        
        //NSLog(@"Signed out we did");
    }
    else {
        [[_auth getAuthenticator] authorizeUserWithClienID:@"408837038497.apps.googleusercontent.com"
                                           andClientSecret:@"boEOJa_DKR9c06vLWbBdmC92"
                                             andParentView:self.view
                                                 andScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/calendar"]];
        
        [self setSignedIn:NO];
        self.signInOutButton.title = @"Sign In";
        
        [_activityIndicator startAnimating];
        
        //NSLog(@"Signed in we did");
    }
}

- (IBAction)radioSelected:(UIButton *)sender {
    Preferences *prefs = [Preferences getSharedInstance];
    
    switch (sender.tag) {
        case 1:
            [prefs negatePreference:1];
            [_cat1Btn setSelected:[prefs getPreference:1]];
            break;
        case 2:
            [prefs negatePreference:2];
            [_cat2Btn setSelected:[prefs getPreference:2]];
            break;
        case 3:
            [prefs negatePreference:3];
            [_cat3Btn setSelected:[prefs getPreference:3]];
            break;
        case 4:
            [prefs negatePreference:4];
            [_cat4Btn setSelected:[prefs getPreference:4]];
            break;
        case 5:
            [prefs negatePreference:5];
            [_cat5Btn setSelected:[prefs getPreference:5]];
            break;
    }
    
    [_collectionView reloadData];
}

- (IBAction)backMonthOffset:(id)sender {
    [_activityIndicator startAnimating];
    
    [_events offsetMonth:-1];
    
    _monthLabel.text = [_events getMonthBarDate];
    
    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    
    //NSLog(@"went to previous month");
}

- (IBAction)forwardMonthOffset:(id)sender {
    [_activityIndicator startAnimating];
    
    [_events offsetMonth:1];
    
    _monthLabel.text = [_events getMonthBarDate];
    
    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    
    //NSLog(@"went to next month");
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    int cells;
    
    if (_signedIn) {
        cells = 35;
        
        //NSLog(@"The number of cells required:%d", [events getFirstWeekDay] + [events getDaysOfMonth]-1);
        
        if ([_events getFirstWeekDay] + [_events getDaysOfMonth]-1 >= 35) {
            cells = 42;
        }
    }
    else {
        cells = 0;
    }
    
    return cells;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    
    //NSLog(@"The first weekday is:%d", [events getFirstWeekDay]);
    
    //NSLog(@"Check to see if cell is for next month:%d >= %d", indexPath.row+1 - [events getFirstWeekDay], [events getDaysOfMonth]);
    
    //Check to see if this cell is for a day of the previous month
    if (indexPath.row+1 - [_events getFirstWeekDay] <= 0) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay] + [_events getDaysOfPreviousMonth]];
    }
    //Check to see if this cell is for a day of the next month
    else if (indexPath.row+1 - [_events getFirstWeekDay] > [_events getDaysOfMonth]) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];

        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay] - [_events getDaysOfMonth]];
    }
    else {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"CurrentDayCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay]];
        
        //Grab the squares for each category.
        UIView *cat1 = (UIView *)[cell viewWithTag:11];
        if (!cat1.hidden) {
            cat1.hidden = YES;
        }
        UIView *cat2 = (UIView *)[cell viewWithTag:12];
        if (!cat2.hidden) {
            cat2.hidden = YES;
        }
        UIView *cat3 = (UIView *)[cell viewWithTag:13];
        if (!cat3.hidden) {
            cat3.hidden = YES;
        }
        UIView *cat4 = (UIView *)[cell viewWithTag:14];
        if (!cat4.hidden) {
            cat4.hidden = YES;
        }
        UIView *cat5 = (UIView *)[cell viewWithTag:15];
        if (!cat5.hidden) {
            cat5.hidden = YES;
        }
        
        //This holds the preferences based on the legend at the top.
        Preferences *prefs = [Preferences getSharedInstance];
        
        //Showing relevant category by making the colorful squares not hidden anymore.
        NSArray *dayEvents = [_events getEventsForDay:(int)indexPath.row+1 - [_events getFirstWeekDay]];

        //Iterate through all events and determine categories that are present.
        for (int i=0; i<[dayEvents count]; i++) {
            //NSString *category = [[dayEvents objectAtIndex:i] objectForKey:@"category"];
            
            //NSLog(@"The event's colorId is %d", [[[dayEvents objectAtIndex:i] objectForKey:@"colorId"] intValue]);
            
            if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Entertainment"]) {
                if (cat1.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:1]) {
                        cat1.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Academics"]) {
                if (cat2.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:2]) {
                        cat2.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Activities"]) {
                if (cat3.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:3]) {
                        cat3.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Residence"]) {
                if (cat4.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:4]) {
                        cat4.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Athletics"]) {
                if (cat5.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:5]) {
                        cat5.hidden = NO;
                    }
                }
            }
        }
    }
    
    return cell;
}

-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Day_Event_ViewController *destViewController = (Day_Event_ViewController *)[segue destinationViewController];
        
        //[destViewController setDay:indexPath.row+1 - [events getFirstWeekDay] ];
        
        [_events setSelectedDay:(int)indexPath.row+1 - [_events getFirstWeekDay]];
        
        NSLog(@"The selected day is %d", (int)indexPath.row+1 - [_events getFirstWeekDay]);
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL canSegue = YES;
    
    if ([identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Check to see if this cell is for a day of the previous month
        if (indexPath.row+1 - [_events getFirstWeekDay] <= 0) {
            //Offset month if a previous month's cell is clicked
            [self backMonthOffset:nil];
            canSegue = NO;
        }
        //Check to see if this cell is for a day of the next month
        else if (indexPath.row+1 - [_events getFirstWeekDay] > [_events getDaysOfMonth]) {
            //Offset month if a future month's cell is clicked
            [self forwardMonthOffset:nil];
            canSegue = NO;
        }
    }
    return canSegue;
}


//This is strictly for locating things like Category: and ShortDesc: within
//  the summary of the.
- (int)getIndexOfSubstringInString:(NSString *)substring :(NSString *)string {
    BOOL substringFound = NO;

    int substringStartIndex = -1;

    //Iterate through the string to find the first character in the substring.
    for (int i=0; i<[string length]; i++) {
        //Check to see if the substring character has been found.
        if ([string characterAtIndex:i] == [substring characterAtIndex:0]) {
            //If the substring length is greater than the remaining characters in the string,
            //  there is no possible way that the substring exists there (and an exception will be thrown.)
            //Only search for the substring if the remaining chars is >= to the substring length.
            if ([string length] - i >= [substring length]) {
                //Check to see if the following characters in the string are also in the substring.
                //  This can start at 1 because the 0th index of the substring has already been determined
                //  to be in the string.
                for (int j=1; j<[substring length]; j++) {
                    //Check if one the following characters in the substring aren't within the string.
                    if ([string characterAtIndex:i+j] != [substring characterAtIndex:j]) {
                        //If this is true, then i isn't the index of the first character in the substring
                        //  within the string.
                        break;
                    }
                    else {
                        //If this was the very last character in the substring and it's in the string, the
                        //  substring has been found. (The loop stops when it finds a char in the substring that's
                        //  not in the string.)
                        if (j == [substring length]-1) {
                            substringFound = YES;
                            substringStartIndex = i;
                        }
                    }
                }
            }
            //If we've found the substring, we can stop the loop.
            if (substringFound) {
                break;
            }
        }
    }

    return substringStartIndex;
}


//This is meant for parsing the summary, pulling out a chunk of information and putting it back
//  into the dictionary under a new key.
//@param eventDict This dictionary represents a single event that was received from Google Calendar's
//  json that will be given to us. The summary exists within this under the "summary" key.
//@param newKey This will be the key for the information that is pulled out of the summary and
//  placed back into the dictionary.
//@param possibleKeys Since human error is bound to happen, these are all the possible keys for
//  the single chunk of information that we're pulling out of the summary and placing back into
//  the dictionary under a new key.
//@return eventDict will be returned, but it will possibly have a new key (or an altered object
//  for a key if the user has permission to change events.)
-(NSDictionary *)parseSummaryForKey:(NSDictionary *)eventDict :(NSString *)newKey :(NSArray *)possibleKeys {
    NSMutableDictionary *dCurrentEvent = [[NSMutableDictionary alloc] initWithDictionary:eventDict];
    
    NSString *summary = [dCurrentEvent objectForKey:@"summary"];
    
    BOOL substringFound = NO;
    int substringStartIndex = 0;
    //This is the length of the key that was found to exist in the summary.
    int foundKeyLength = 0;
    
    //Loop through each possible key looking for the substring.
    //Then we'll break out of the look when it's found.
    for (int i=0; i<[possibleKeys count]; i++) {
        substringStartIndex = [self getIndexOfSubstringInString:[possibleKeys objectAtIndex:i] :summary];
        
        //-1 means a substring wasn't found.
        if (substringStartIndex != -1) {
            substringFound = YES;
            foundKeyLength = [[possibleKeys objectAtIndex:i] length];
            break;
        }
    }
    
    if (substringFound) {
        //This block gets the first word after the "Category:", which is the category.
        NSString *infoWithExtraStuff = [summary substringWithRange:NSMakeRange(substringStartIndex+foundKeyLength,
                                                                                   [summary length] - (substringStartIndex+foundKeyLength))];
        NSString *info = [[infoWithExtraStuff componentsSeparatedByString:@";"] objectAtIndex:0];
        
        int trailingSpaces = 0;
        
        //Determine number of trailing spaces, so we can not include them in the category.
        for (int j=(int)[info length]-1; j>=0; j--) {
            if ([info characterAtIndex:j] != ';') {
                break;
            }
            else {
                trailingSpaces += 1;
            }
        }
        
        //Add the category item to the dictionary.
        [dCurrentEvent setObject:[info substringWithRange:NSMakeRange(0, [info length] - trailingSpaces)]
                          forKey:newKey];
    }
    else {
        //If none of the possible keys were valid, then we can just assume say that there's
        //  no category and move on essentially.
        [dCurrentEvent setObject:@"N/A" forKey:newKey];
    }
    
    return (NSDictionary *)dCurrentEvent;
}



- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:components];
}

- (NSString*)toStringFromDateTime:(NSDate*)dateTime {
    // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
    // Example: 2013-10-25T06:59:43.431Z
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    NSString* sDateTime = [dateFormatter stringFromDate:dateTime];
    return sDateTime;
}

- (void) getEventsForMonth:(NSInteger) month :(NSInteger) year {
    NSDate * firstDateOfMonth = [self returnDateForMonth:month year:year day:1];
    NSDate * lastDateOfMonth = [self returnDateForMonth:month+1 year:year day:0];
    
    //NSLog(@"Getting events for selected month, month:%@, year:%@", [self toStringFromDateTime:firstDateOfMonth], [self toStringFromDateTime:lastDateOfMonth]);
    
    // If user authorization is successful, then make an API call to get the event list for the current month.
    // For more infomation about this API call, visit:
    // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
    [[_auth getAuthenticator] callAPI:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events"
                       withHttpMethod:httpMethod_GET
                   postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                  postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:lastDateOfMonth], [self toStringFromDateTime:firstDateOfMonth], nil]];
}


#pragma mark - GoogleOAuth class delegate method implementation

-(void)authorizationWasSuccessful {
    //This is a dummy update that will be to see if the user is able to manage events.
    [[_auth getAuthenticator] callAPI:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events/6smpqs3orp11pm5kc6qubg8f38/move"
                       withHttpMethod:httpMethod_POST
                   postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                  postParameterValues:[NSArray arrayWithObjects:@"lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com", nil]];
    
    //NSLog(@"Getting the events for the current month");
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    NSError *error;
    
    //If we reach this point and the user is not signed in, that means the user just signed in or out.
    //The problem is that when we go to sign out, an empty json is sent after we've already set _signedIn to No.
    //  So we'll just ignore cases when we get an empty json file while we're signed out.
    //  This won't be triggered while we're signed in and getting empty json strings for empty months.
    if (!_signedIn) {
        
        //If the response json isn't empty, then we signed in.
        if (![responseJSONAsString isEqualToString:@""]) {
            [self setSignedIn:YES];
        
            self.signInOutButton.title = @"Sign Out";
            
            NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [NSDate date];
            
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
            NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
            
            [self getEventsForMonth:comps.month :comps.year];
        }
    }
    
    if ([responseJSONAsString rangeOfString:@"calendar#events"].location != NSNotFound) {
        // Get the JSON data as a dictionary.
        NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:responseJSONAsData options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            // This is the case that an error occured during converting JSON data to dictionary.
            // Simply log the error description.
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            if (!_firstEventsJSONReceived) {
                _firstEventsJSONReceived = YES;
                
                [_activityIndicator stopAnimating];
            }
            
            
            //Get the events as an array
            NSArray *eventsInfo = [eventsInfoDict objectForKey:@"items"];
            
            //NSLog(@"Putting the events into _calendarEvents.");
            
            [_events refreshArrayOfEvents];
            
            _monthLabel.text = [_events getMonthBarDate];
            
            //Loop through the events
            for (int i=0; i<[eventsInfo count]; i++) {
                NSInteger day;
                
                //Get the day from the event's dictionary
                if ([[[eventsInfo objectAtIndex:i] objectForKey:@"start"] objectForKey:@"dateTime"] != nil) {
                    day = [[[[[eventsInfo objectAtIndex:i]
                                        objectForKey:@"start"]
                                       objectForKey:@"dateTime"]
                                      substringWithRange:NSMakeRange(8, 2)]
                                     integerValue];
                }
                else {
                    day = [[[[[eventsInfo objectAtIndex:i]
                                        objectForKey:@"start"]
                                       objectForKey:@"date"]
                                      substringWithRange:NSMakeRange(8, 2)]
                                     integerValue];
                }
                
                //Now we must parse the summary and alter the dictionary so that it can be
                //  used in the rest of the program easier. So we'll call parseSummaryForKey in this class
                //  to pull info out of the Summary field in the Dictionary and place
                //  it back into the dictionary mapped to a new key.
                
                NSDictionary *currentEventInfo = [eventsInfo objectAtIndex:i];
                
                //Parse out the summary and add it into the dictionary with the key, "summary".
                currentEventInfo =  [self parseSummaryForKey:currentEventInfo
                                                            :@"description"
                                                            :[[NSArray alloc] initWithObjects:@"Detail:",
                                                                                              @"Detail: ",
                                                                                              @"detail:",
                                                                                              @"detail: ",
                                                                                              @"Details:",
                                                                                              @"Details: ",
                                                                                              @"details:",
                                                                                              @"details: ",nil]];
                
                //Parse out the location and add it into the dictionary with the key, "location".
                currentEventInfo =  [self parseSummaryForKey:currentEventInfo
                                                            :@"location"
                                                            :[[NSArray alloc] initWithObjects:@"Location:",
                                                                                              @"Location: ",
                                                                                              @"location:",
                                                                                              @"location: ", nil]];
                
                //Parse out the category and add it into the dictionary with the key, "category".
                currentEventInfo =  [self parseSummaryForKey:currentEventInfo
                                                            :@"category"
                                                            :[[NSArray alloc] initWithObjects:@"Category:",
                                                                                              @"Category: ",
                                                                                              @"category:",
                                                                                              @"category: ", nil]];
                
                //Parse out the summary and add it into the dictionary with the key, "summary".
                currentEventInfo =  [self parseSummaryForKey:currentEventInfo
                                                            :@"summary"
                                                            :[[NSArray alloc] initWithObjects:@"Abstract:",
                                                                                              @"Abstract: ",
                                                                                              @"abstract:",
                                                                                              @"abstract: ", nil]];
                
                
                NSLog(@"%@", currentEventInfo);
                
                //This then uses that day as an index and inserts the currentEvent into that indice's array.
                [_events AppendEvent:day :currentEventInfo];
            }
            //NSLog(@"These are our calendar events: %@",_calendarEvents);
            
            [_collectionView reloadData];
            
            [_activityIndicator stopAnimating];
        }
    }
    //This type of json is retrieved if an update was made to an event (currently only for authenticating.)
    else if ([responseJSONAsString rangeOfString:@"calendar#event"].location != NSNotFound) {
        [_auth setUserCanManageEvents:YES];
        NSLog(@"The user can manage events!");
        
        _addEventButton.title = @"Add Event";
        _addEventButton.enabled = YES;
    }
}

-(void)accessTokenWasRevoked{
    [_events refreshArrayOfEvents];
}


-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    // Just log the error messages.
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    // Just log the error message.
    NSLog(@"%@", errorMessage);
}

@end