//
//  EventDetailTableViewController.m
//  campuslife
//
//  Created by Super Student on 3/4/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "EventDetailTableViewController.h"
#import "MonthlyEvents.h"

@interface EventDetailTableViewController ()
{
    MonthlyEvents *events;
}

@end



@implementation EventDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    events = [MonthlyEvents getSharedInstance];
    
    [self setDay:[events getSelectedDay]];
    
    //self.tableView.separatorColor = [UIColor clearColor];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    
    if (section == 0)
    {
        rows = 3;
    }
    else if (section == 1)
    {
        rows = 4;
    }
    else
    {
        rows = 2;
    }
    
    return rows;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"standardInformationDisplay" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:1];
            title.text = @"Summary";
            UILabel *summary = (UILabel *)[cell viewWithTag:2];
            summary.text = [_eventDict objectForKey:@"summary"];
        }
        
        if (indexPath.row == 2)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"standardInformationDisplay" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:1];
            title.text = @"Location";
            UILabel *summary = (UILabel *)[cell viewWithTag:2];
            summary.text = [_eventDict objectForKey:@"location"];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"allDaySwitch" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:3];
            title.text = @"All Day Event";
            
            if ([[_eventDict objectForKey:@"start"] objectForKey:@"date"])
            {
                UISwitch *allDay = (UISwitch *)[cell viewWithTag:4];
                [allDay setOn:YES];
            }
        }
        
        if (indexPath.row == 2)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"dayAndTimePicker" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:5];
            title.text = @"Start";
            
            /*
             
             reformat the string. ex: Mar 18, 2014  1:00PM
             
             */
            UILabel *timeLbl = (UILabel *)[cell viewWithTag:6];
            if ([[_eventDict objectForKey:@"start"] objectForKey:@"date"])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                NSDate *date = [[NSDate alloc] init];
                date = [dateFormatter dateFromString:[[_eventDict objectForKey:@"start"] objectForKey:@"date"]];
                timeLbl.text = [dateFormatter stringFromDate:date];
                NSLog(@"\n\n\n dayLbl.text = %@ \n\n\n", timeLbl.text);
            }
            else
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                NSDate *date = [[NSDate alloc] init];
                date = [dateFormatter dateFromString:[[_eventDict objectForKey:@"start"] objectForKey:@"dateTime"]];
                timeLbl.text = [dateFormatter stringFromDate:date];
                NSLog(@"\n\n\n dayTimeLbl.text = %@ \n\n\n", timeLbl.text);
            }
        }
        
        if (indexPath.row == 3)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"dayAndTimePicker" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:5];
            title.text = @"End";
            
            UILabel *timeLbl = (UILabel *)[cell viewWithTag:6];
            if ([[_eventDict objectForKey:@"end"] objectForKey:@"date"])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                NSDate *date = [[NSDate alloc] init];
                date = [dateFormatter dateFromString:[[_eventDict objectForKey:@"end"] objectForKey:@"date"]];
                timeLbl.text = [dateFormatter stringFromDate:date];
                NSLog(@"\n\n\n dayLbl.text = %@ \n\n\n", timeLbl.text);
            }
            else
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                NSDate *date = [[NSDate alloc] init];
                date = [dateFormatter dateFromString:[[_eventDict objectForKey:@"end"] objectForKey:@"dateTime"]];
                NSLog(@"endPrintOut = %@", [[_eventDict objectForKey:@"end"] objectForKey:@"dateTime"]);
                NSLog(@"nsdatePrintOut = %@", date);
                timeLbl.text = [dateFormatter stringFromDate:date];
                NSLog(@"dayTimeLbl.text = %@", timeLbl.text);
            }
            
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"repeatDisplay" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:7];
            title.text = @"Repeat";
            UILabel *repState = (UILabel *)[cell viewWithTag:8];
            if ([_eventDict objectForKey:@"recurrence"]) {
                repState.text = @"Yes";
            } else {
                repState.text = @"No";
            }
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"description" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:9];
            title.text = @"Description";
            UITextView *descView = (UITextView *)[cell viewWithTag:10];
            descView.text = [_eventDict objectForKey:@"description"];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    
    return cell;
}



- (NSString *)twentyFourToTwelve:(NSString *)time
{
    NSRange stringHourRange = NSMakeRange(0, 2);
    NSString *stringHour = [time substringWithRange:stringHourRange];
    int hourInt = [stringHour intValue];
    
    NSRange stringMinRange = NSMakeRange(2, 3);
    NSString *restOfString = [time substringWithRange:stringMinRange];
    
    
    if (hourInt == 0)
    {
        time = [NSString stringWithFormat:@"%d%@ AM", 12, restOfString];
    }
    
    else if(hourInt < 10)
    {
        time = [NSString stringWithFormat:@"%d%@ AM", hourInt, restOfString];
    }
    
    else if (hourInt == 12)
    {
        time = [NSString stringWithFormat:@"%d%@ PM", 12, restOfString];
    }
    
    else if (hourInt >= 13)
    {
        time = [NSString stringWithFormat:@"%d%@ PM", hourInt - 12, restOfString];
    }
    
    return time;
}



@end
